# SETUP.md — Installation Manual for AI Agents

> This document is written for Claude Code (or any AI assistant) to read.
> The user will paste something like "Read SETUP.md in this repo and set up
> my environment accordingly" — then you execute it. Work step by step,
> verify each step, stop and report on failure. Never skip ahead.

## The environment you are building

A Claude Code working environment centered on the eight-stage Workbench
flow (/setup → /discover → /design* → /spec → /tickets → /build →
/accept → /release):

| Component | Layer | Install method |
|---|---|---|
| Workbench flow (this repo) | global CLAUDE.md + personal skill + slash commands | `install.sh` |
| pilotfish | global CLAUDE.md block + `~/.claude/agents/` | upstream agent-driven install, user approves the merge plan |
| code-review-graph | CLI + per-project MCP | `install.sh` installs the CLI |
| Matt Pocock skills | plugin | user installs inside Claude Code |
| Karpathy guidelines | plugin | user installs inside Claude Code |
| ux-ui-agent-skills | per-project | `npx init` in each UI project |

## Steps

### 1. Run the filesystem-layer installer

```bash
git clone https://github.com/miki519/claude-workbench
cd claude-workbench
./install.sh
```

Verify:
- `~/.claude/CLAUDE.md` now contains the `workbench:pipeline:begin` marker
  (and NO legacy `workbench:delivery-pipeline` marker — the installer removes it)
- `~/.claude/skills/workbench/SKILL.md` and
  `~/.claude/skills/to-architecture/SKILL.md` exist
- `~/.claude/commands/` contains the eight stage commands
  (setup, discover, design, spec, tickets, build, accept, release)
- `code-review-graph --version` produces output. It is a Python (PyPI)
  package installed via `uv tool install` (pipx as fallback) — NOT npm.
  If the install was skipped for lack of uv/pipx, install uv first
  (https://docs.astral.sh/uv/), then re-run `install.sh`; report failures,
  do not skip silently.

### 2. Guide the user through plugin installation

Plugin installation is an interactive in-app command — you cannot run it on
the user's behalf. List the commands, wait for the user to run them, then
verify:

```
/plugin marketplace add mattpocock/skills
/plugin marketplace add forrestchang/andrej-karpathy-skills
```

(This repo's own skills need no plugin — `install.sh` already placed them in
`~/.claude/skills/`.)

Verify: ask the user to open `/plugin` and check the installed list, or test
directly whether `/grill-me` (from mattpocock), the
`andrej-karpathy-skills:karpathy-guidelines` skill, and `/discover` (from
install.sh) appear among the available commands/skills.

### 3. Guide the user through pilotfish installation

pilotfish (multi-model orchestration: the main session plans, cheaper role
agents execute, fresh contexts verify) has its own upstream agent-driven
installer with an explicit approval gate — it writes into the user's global
CLAUDE.md and `~/.claude/agents/`. NEVER bypass that gate, and never copy
its files by hand.

First check whether it is already installed: `~/.claude/agents/scout.md`
exists and `~/.claude/CLAUDE.md` contains an orchestration (pilotfish)
block. If yes, report so and move on.

If not, clone the pinned verified version (see README's version table)
and follow the upstream runbook:

```bash
git clone --branch v1.3.5 --depth 1 https://github.com/Nanako0129/pilotfish.git
```

Read `install/AGENT-INSTALL.md` from that checkout and follow it: show the
user the full plan of changes and get explicit approval BEFORE writing
anything. (Alternatively the user can run it in a fresh session from the
checkout, per the pilotfish README.)

Verify (after the user restarts the session): `~/.claude/agents/` contains
the eight role files (scout, Explore, executor, mech-executor,
plan-verifier, verifier, security-reviewer, security-executor) and the
CLAUDE.md orchestration block is present.

### 4. Explain the per-project steps (do not run them now)

Tell the user that for every new project:

```bash
# UI projects only:
npx ux-ui-agent-skills init
# All projects:
code-review-graph install --platform claude-code
code-review-graph build
```

### 5. Self-check and report

When done, report a checklist to the user:

- [ ] CLAUDE.md workbench blocks (pipeline / code-review-graph / conventions)
- [ ] Personal skills: workbench, to-architecture
- [ ] Slash commands: the eight stage commands in ~/.claude/commands/
- [ ] CLI: code-review-graph
- [ ] Plugins: mattpocock skills + Karpathy guidelines (installed
      interactively by the user, verified by you)
- [ ] pilotfish: orchestration block + eight role agents (installed via the
      upstream runbook with the user's approval)
- [ ] Per-project steps explained

If any item failed: report the cause and the impact honestly. Never mark a
failed item as done.

## Notes

- **This manual doubles as the update procedure.** When the user asks to
  update (rather than install), run the same steps: pull the latest repo
  (or re-clone) and re-run `install.sh`; offer to update third-party
  marketplaces too (`/plugin marketplace update <name>`, run by the user).
  If working inside a project, also offer to update project tools
  (`uv tool upgrade code-review-graph` — it is a PyPI package, not npm —
  then re-run `code-review-graph build`; major versions can invalidate the
  old graph). Third-party upstream
  changes may drift from the README teaching — mention the verified-versions
  table if the user hits inconsistencies. Everything is designed to be
  re-run safely. Report what was updated at the end.
- `install.sh` is idempotent and safe to re-run (marker-based blocks are
  replaced in place; CLAUDE.md is backed up automatically each run).
  User customizations OUTSIDE the workbench marker blocks are never touched;
  anything inside the markers is replaced — warn the user if you detect
  hand-edits inside a workbench block before replacing it.
- Never copy third-party skill content into the user's directories — their
  marketplace is their update channel; a copy strands the user on a stale
  version forever.
- Community marketplaces do NOT auto-update by default. If the user wants to
  track upstream, point them to `/plugin` → Marketplaces → Enable
  auto-update, or a periodic `/plugin marketplace update <name>`.
