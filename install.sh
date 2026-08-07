#!/usr/bin/env bash
# psyflow installer — idempotent, safe to re-run.
# Installs the parts the plugin system cannot carry:
#   1. CLAUDE.md blocks (marker-based: re-running replaces our blocks only)
#   2. CLI tools it can install non-interactively (code-review-graph)
# The flow itself (eight stage commands + psyflow/to-architecture skills)
# ships as the `psyflow` PLUGIN — installed INSIDE Claude Code; this script
# prints the exact commands at the end. Third-party skills are likewise
# never vendored: their marketplace is their update channel.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
CLAUDE_MD="${CLAUDE_DIR}/CLAUDE.md"
SKILLS_DIR="${CLAUDE_DIR}/skills"
COMMANDS_DIR="${CLAUDE_DIR}/commands"
BLOCKS_DIR="${REPO_DIR}/claude-md-blocks"

say()  { printf '\n==> %s\n' "$*"; }
note() { printf '    %s\n' "$*"; }

# Remove one marker-delimited block from CLAUDE.md (both markers required).
remove_block() {
  local begin="$1" end="$2" label="$3"
  if grep -qF "$begin" "$CLAUDE_MD"; then
    if ! grep -qF "$end" "$CLAUDE_MD"; then
      note "WARNING $label: begin marker found but end marker missing."
      note "        Skipping to avoid deleting user content — fix by hand."
      return 1
    fi
    awk -v b="$begin" -v e="$end" '
      index($0,b){skip=1}
      !skip{print}
      index($0,e){skip=0}
    ' "$CLAUDE_MD" > "${CLAUDE_MD}.tmp"
    mv "${CLAUDE_MD}.tmp" "$CLAUDE_MD"
    note "removed block: $label"
  fi
}

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
# core work (CLAUDE.md blocks).
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
  note "note: neither uv nor pipx found — step 2 (code-review-graph) will be"
  note "      skipped. Install uv first: https://docs.astral.sh/uv/"
fi

mkdir -p "$CLAUDE_DIR"
[ -f "$CLAUDE_MD" ] || touch "$CLAUDE_MD"

# Backup once per run.
backup="${CLAUDE_MD}.psyflow-backup.$(date +%Y%m%d%H%M%S)"
cp "$CLAUDE_MD" "$backup"
note "Backed up CLAUDE.md -> $backup"

# ------------------------------------------------- 0b. legacy cleanup
# v1.x: "delivery-pipeline" block + skill. v2.0: "workbench" blocks + skills
# + commands copied into ~/.claude. v2.1 renamed the flow to "psyflow" and
# moved commands/skills into the psyflow PLUGIN — remove every older copy so
# it doesn't shadow or duplicate the plugin-installed versions.
say "Cleaning up legacy installs"
remove_block "<!-- workbench:delivery-pipeline:begin -->" \
             "<!-- workbench:delivery-pipeline:end -->" "delivery-pipeline" || true
for id in pipeline code-review-graph conventions; do
  remove_block "<!-- workbench:${id}:begin -->" \
               "<!-- workbench:${id}:end -->" "workbench:${id}" || true
done
for skill in delivery-pipeline workbench to-architecture; do
  if [ -d "$SKILLS_DIR/$skill" ]; then
    rm -rf "$SKILLS_DIR/$skill"
    note "removed legacy personal skill: $skill (now plugin-shipped)"
  fi
done
for cmd_file in "$REPO_DIR"/commands/*.md; do
  name="$(basename "$cmd_file")"
  if [ -f "$COMMANDS_DIR/$name" ]; then
    rm -f "$COMMANDS_DIR/$name"
    note "removed legacy personal command: /${name%.md} (now plugin-shipped)"
  fi
done

# ------------------------------------------------- 1. CLAUDE.md blocks
# Each file in claude-md-blocks/ is wrapped in
#   <!-- psyflow:<id>:begin --> ... <!-- psyflow:<id>:end -->
# Re-running removes the old block (by marker) and appends the new one.
say "Installing CLAUDE.md blocks"
for block in "$BLOCKS_DIR"/*.md; do
  id="$(head -1 "$block" | sed -n 's/.*psyflow:\(.*\):begin.*/\1/p')"
  if [ -z "$id" ]; then
    note "SKIP $(basename "$block"): no psyflow marker on first line"
    continue
  fi
  begin="<!-- psyflow:${id}:begin -->"
  end="<!-- psyflow:${id}:end -->"
  if grep -qF "$begin" "$CLAUDE_MD"; then
    remove_block "$begin" "$end" "$id" || continue
    note "replacing block: $id"
  else
    note "adding block: $id"
  fi
  printf '\n' >> "$CLAUDE_MD"
  cat "$block" >> "$CLAUDE_MD"
done

# ------------------------------------------------- 2. CLI tools
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

# ------------------------------------------------- 3. print the in-app steps
say "Done with the filesystem layer. Finish inside Claude Code:"
cat <<'EOF'

  Paste these commands in any Claude Code session:

    /plugin marketplace add miki519/psyflow
    /plugin install psyflow@psyflow

  Stage commands install namespaced: /psyflow:setup, /psyflow:discover, ...
  Updating later: /plugin marketplace update psyflow

  Third-party plugins (their marketplace is their update channel):

    /plugin marketplace add mattpocock/skills

  (Also install the Karpathy guidelines and any other marketplaces you use —
   see README.md for the full stack and versions verified.)

  Per-project setup: just run /psyflow:setup inside each new project — it
  installs the per-project tools (design kit for UI projects, optional
  style-search engine, code-review-graph) with its own checks.

EOF
say "Re-running this script is safe: blocks are replaced in place."
