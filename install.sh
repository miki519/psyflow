#!/usr/bin/env bash
# claude-workbench installer — idempotent, safe to re-run.
# Installs the filesystem-level parts of the workbench:
#   1. CLAUDE.md blocks (marker-based: re-running replaces our blocks only)
#   2. Personal skills (~/.claude/skills/) + slash commands (~/.claude/commands/)
#   3. CLI tools it can install non-interactively
# Plugin-level parts (Matt Pocock skills, Karpathy guidelines) are installed
# INSIDE Claude Code — this script prints the exact commands at the end.
# We deliberately never vendor or copy third-party skills: their marketplace
# is their update channel.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
CLAUDE_MD="${CLAUDE_DIR}/CLAUDE.md"
SKILLS_DIR="${CLAUDE_DIR}/skills"
COMMANDS_DIR="${CLAUDE_DIR}/commands"
BLOCKS_DIR="${REPO_DIR}/claude-md-blocks"

say()  { printf '\n==> %s\n' "$*"; }
note() { printf '    %s\n' "$*"; }

# ---------------------------------------------------------------- 0. checks
say "Checking prerequisites"
# Hard requirement: git only (everything this script writes needs no runtime).
if command -v git >/dev/null 2>&1; then
  note "git: $(command -v git)"
else
  note "MISSING: git — install it first, then re-run."
  exit 1
fi
# Advisory checks — used by LATER per-project steps, not by this script's
# core work (CLAUDE.md blocks + skills). Their absence must not block those.
#   node/npm — npx ux-ui-agent-skills (per-project design kit)
#   uv/pipx  — code-review-graph is a Python (PyPI) package, NOT on npm
for cmd in node npm; do
  if command -v "$cmd" >/dev/null 2>&1; then
    note "$cmd: $(command -v "$cmd")"
  else
    note "note: $cmd not found — needed later for 'npx ux-ui-agent-skills'"
    note "      (per-project design kit). Install Node.js LTS when you need it."
  fi
done
if command -v uv >/dev/null 2>&1; then
  note "uv: $(command -v uv)"
elif command -v pipx >/dev/null 2>&1; then
  note "pipx: $(command -v pipx)"
else
  note "note: neither uv nor pipx found — step 3 (code-review-graph) will be"
  note "      skipped. Install uv first: https://docs.astral.sh/uv/"
fi

mkdir -p "$CLAUDE_DIR" "$SKILLS_DIR"
[ -f "$CLAUDE_MD" ] || touch "$CLAUDE_MD"

# Backup once per run.
backup="${CLAUDE_MD}.workbench-backup.$(date +%Y%m%d%H%M%S)"
cp "$CLAUDE_MD" "$backup"
note "Backed up CLAUDE.md -> $backup"

# ------------------------------------------------- 0b. legacy cleanup
# v1.x installed a "delivery-pipeline" block + skill; v2 renamed the flow to
# "workbench". Remove the old artifacts so they don't shadow the new ones.
legacy_begin="<!-- workbench:delivery-pipeline:begin -->"
legacy_end="<!-- workbench:delivery-pipeline:end -->"
if grep -qF "$legacy_begin" "$CLAUDE_MD"; then
  if grep -qF "$legacy_end" "$CLAUDE_MD"; then
    awk -v b="$legacy_begin" -v e="$legacy_end" '
      index($0,b){skip=1}
      !skip{print}
      index($0,e){skip=0}
    ' "$CLAUDE_MD" > "${CLAUDE_MD}.tmp"
    mv "${CLAUDE_MD}.tmp" "$CLAUDE_MD"
    note "removed legacy block: delivery-pipeline"
  else
    note "WARNING: legacy delivery-pipeline block has no end marker — remove it by hand."
  fi
fi
if [ -d "$SKILLS_DIR/delivery-pipeline" ]; then
  rm -rf "$SKILLS_DIR/delivery-pipeline"
  note "removed legacy skill: delivery-pipeline"
fi

# ------------------------------------------------- 1. CLAUDE.md blocks
# Each file in claude-md-blocks/ is wrapped in
#   <!-- workbench:<id>:begin --> ... <!-- workbench:<id>:end -->
# Re-running removes the old block (by marker) and appends the new one.
say "Installing CLAUDE.md blocks"
for block in "$BLOCKS_DIR"/*.md; do
  id="$(head -1 "$block" | sed -n 's/.*workbench:\(.*\):begin.*/\1/p')"
  if [ -z "$id" ]; then
    note "SKIP $(basename "$block"): no workbench marker on first line"
    continue
  fi
  begin="<!-- workbench:${id}:begin -->"
  end="<!-- workbench:${id}:end -->"
  if grep -qF "$begin" "$CLAUDE_MD"; then
    # Safety: only remove when BOTH markers are present. With the end marker
    # missing (e.g. lost in a hand edit), the awk below would delete from the
    # begin marker to end-of-file, taking user content with it.
    if ! grep -qF "$end" "$CLAUDE_MD"; then
      note "WARNING $id: begin marker found but end marker missing in CLAUDE.md."
      note "        Skipping this block to avoid deleting user content."
      note "        Restore the '<!-- workbench:${id}:end -->' line (or remove"
      note "        the whole block by hand), then re-run."
      continue
    fi
    # Remove existing block (inclusive of markers).
    awk -v b="$begin" -v e="$end" '
      index($0,b){skip=1}
      !skip{print}
      index($0,e){skip=0}
    ' "$CLAUDE_MD" > "${CLAUDE_MD}.tmp"
    mv "${CLAUDE_MD}.tmp" "$CLAUDE_MD"
    note "replaced block: $id"
  else
    note "added block: $id"
  fi
  printf '\n' >> "$CLAUDE_MD"
  cat "$block" >> "$CLAUDE_MD"
done

# ------------------------------------------------- 2. personal skills
say "Installing personal skills"
# The CLAUDE.md block is a thin pointer that tells the agent to load the
# workbench skill for the full stage rules — all skills install as personal
# skills so the pointer always resolves. No plugin/marketplace packaging:
# this script IS the distribution channel for this repo.
for skill_dir in "$REPO_DIR"/skills/*/; do
  name="$(basename "$skill_dir")"
  mkdir -p "$SKILLS_DIR/$name"
  cp "$skill_dir/SKILL.md" "$SKILLS_DIR/$name/SKILL.md"
  note "installed skill: $name -> $SKILLS_DIR/$name"
done

# ------------------------------------------------- 2b. slash commands
say "Installing slash commands"
# The eight stage commands (/setup /discover /design /spec /tickets /build
# /accept /release) are Claude Code custom commands — each carries its own
# stage rules and loads the workbench skill for the cross-stage rules.
mkdir -p "$COMMANDS_DIR"
for cmd_file in "$REPO_DIR"/commands/*.md; do
  cp "$cmd_file" "$COMMANDS_DIR/$(basename "$cmd_file")"
  note "installed command: /$(basename "$cmd_file" .md)"
done

# ------------------------------------------------- 3. CLI tools
say "Installing CLI tools"
# code-review-graph is a Python (PyPI) package — there is no npm package of
# this name. Install as an isolated tool via uv (preferred) or pipx.
if command -v code-review-graph >/dev/null 2>&1; then
  note "code-review-graph already installed: $(command -v code-review-graph)"
elif command -v uv >/dev/null 2>&1; then
  note "installing code-review-graph via uv tool..."
  uv tool install code-review-graph \
    || note "uv tool install failed — install manually and re-run"
elif command -v pipx >/dev/null 2>&1; then
  # pipx itself runs on the system Python; uv needs no Python at all (it
  # downloads a managed one). If this fails, switching to uv is the fix.
  note "installing code-review-graph via pipx..."
  pipx install code-review-graph \
    || note "pipx install failed — install uv instead (https://docs.astral.sh/uv/) and re-run"
else
  note "SKIPPED code-review-graph: requires uv or pipx."
  note "Install uv (https://docs.astral.sh/uv/), then re-run this script."
fi

# ------------------------------------------------- 4. print the in-app steps
say "Done with the filesystem layer. Finish inside Claude Code:"
cat <<'EOF'

  Paste these commands in any Claude Code session (third-party plugins —
  their marketplace is their update channel):

    /plugin marketplace add mattpocock/skills

  (Also install the Karpathy guidelines and any other marketplaces you use —
   see README.md for the full stack and versions verified.)

  Per-project setup (run when starting each new project):

    npx ux-ui-agent-skills init                        # design kit, UI projects only
    code-review-graph install --platform claude-code   # no 'build' yet — run it
                                                       # later once code exists

EOF
say "Re-running this script is safe: blocks are replaced in place."
