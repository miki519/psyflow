#!/usr/bin/env bash
# claude-workbench installer — idempotent, safe to re-run.
# Installs the filesystem-level parts of the workbench:
#   1. CLAUDE.md blocks (marker-based: re-running replaces our blocks only)
#   2. Personal skills (~/.claude/skills/)
#   3. CLI tools it can install non-interactively
# Plugin-level parts (Matt Pocock skills, Karpathy guidelines, this repo's
# delivery-pipeline plugin) are installed INSIDE Claude Code — this script
# prints the exact commands at the end. We deliberately never vendor or copy
# third-party skills: their marketplace is their update channel.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
CLAUDE_MD="${CLAUDE_DIR}/CLAUDE.md"
SKILLS_DIR="${CLAUDE_DIR}/skills"
BLOCKS_DIR="${REPO_DIR}/claude-md-blocks"

say()  { printf '\n==> %s\n' "$*"; }
note() { printf '    %s\n' "$*"; }

# ---------------------------------------------------------------- 0. checks
say "Checking prerequisites"
missing=""
for cmd in git node npm; do
  if command -v "$cmd" >/dev/null 2>&1; then
    note "$cmd: $(command -v "$cmd")"
  else
    missing="$missing $cmd"
  fi
done
if [ -n "$missing" ]; then
  note "MISSING:$missing — install them first, then re-run."
  exit 1
fi

mkdir -p "$CLAUDE_DIR" "$SKILLS_DIR"
[ -f "$CLAUDE_MD" ] || touch "$CLAUDE_MD"

# Backup once per run.
backup="${CLAUDE_MD}.workbench-backup.$(date +%Y%m%d%H%M%S)"
cp "$CLAUDE_MD" "$backup"
note "Backed up CLAUDE.md -> $backup"

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
for skill_dir in "$REPO_DIR"/plugins/delivery-pipeline/skills/*/; do
  name="$(basename "$skill_dir")"
  # delivery-pipeline (the pipeline overview) is optional as a personal skill:
  # people who install the plugin get it there. to-architecture is the one
  # with no other home, so it always goes in.
  if [ "$name" = "to-architecture" ]; then
    mkdir -p "$SKILLS_DIR/$name"
    cp "$skill_dir/SKILL.md" "$SKILLS_DIR/$name/SKILL.md"
    note "installed skill: $name -> $SKILLS_DIR/$name"
  fi
done

# ------------------------------------------------- 3. CLI tools
say "Installing CLI tools"
if command -v code-review-graph >/dev/null 2>&1; then
  note "code-review-graph already installed: $(command -v code-review-graph)"
else
  note "installing code-review-graph via npm..."
  npm install -g code-review-graph || note "npm install failed — install manually and re-run"
fi

# ------------------------------------------------- 4. print the in-app steps
say "Done with the filesystem layer. Finish inside Claude Code:"
cat <<'EOF'

  Paste these commands in any Claude Code session:

    /plugin marketplace add mattpocock/skills
    /plugin marketplace add miki519/claude-workbench
    /plugin install delivery-pipeline@claude-workbench

  (Also install the Karpathy guidelines and any other marketplaces you use —
   see README.md for the full stack and versions verified.)

  Per-project setup (run when starting each new project):

    npx ux-ui-agent-skills init          # design kit, UI projects only
    code-review-graph install --platform claude-code && code-review-graph build

EOF
say "Re-running this script is safe: blocks are replaced in place."
