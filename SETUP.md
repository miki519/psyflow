# SETUP.md — Installation Manual for AI Agents

> This document is written for Claude Code (or any AI assistant) to read.
> The user will paste something like "Read SETUP.md in this repo and set up
> my environment accordingly" — then you execute it. Work step by step,
> verify each step, stop and report on failure. Never skip ahead.

## The environment you are building

A Claude Code working environment centered on the eight-stage Psyflow
flow (/setup → /discover → /design* → /spec → /tickets → /build →
/accept → /release), installed as the `psyflow` plugin and invoked
namespaced: `/psyflow:setup`, `/psyflow:discover`, …

| Component | Layer | Install method |
|---|---|---|
| psyflow flow (this repo) | plugin (eight stage commands + psyflow / to-architecture skills) | user installs inside Claude Code |
| psyflow CLAUDE.md blocks | global CLAUDE.md (pointer + conventions) | `install.sh` |
| pilotfish | global CLAUDE.md block + `~/.claude/agents/` | upstream agent-driven install, user approves the merge plan |
| code-review-graph | CLI + per-project MCP | `install.sh` installs the CLI |
| Matt Pocock skills | plugin | user installs inside Claude Code |
| Karpathy guidelines | plugin | user installs inside Claude Code |
| ux-ui-agent-skills | per-project | `/psyflow:setup` in each UI project (selective `add`, never `init` — skips the `claude` area) |
| ui-ux-pro-max (optional) | per-project | `/psyflow:setup` offers `npx uipro-cli init --ai claude` for UI projects |

## Steps

### 1. Run the filesystem-layer installer

```bash
git clone https://github.com/miki519/psyflow
cd psyflow
./install.sh
```

Verify:
- `~/.claude/CLAUDE.md` now contains the `psyflow:pipeline:begin` marker
  (and NO legacy `workbench:*` or `workbench:delivery-pipeline` markers —
  the installer removes them, along with any workbench-era copies in
  `~/.claude/skills/` and `~/.claude/commands/`)
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
/plugin marketplace add miki519/psyflow
/plugin install psyflow@psyflow
/plugin marketplace add mattpocock/skills
/plugin marketplace add forrestchang/andrej-karpathy-skills
```

Verify: ask the user to open `/plugin` and check the installed list, or test
directly whether `/psyflow:discover` (this repo's plugin), `/grill-me`
(from mattpocock), and the `andrej-karpathy-skills:karpathy-guidelines`
skill appear among the available commands/skills.

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

### 4. Explain the per-project step (do not run it now)

Tell the user that for every new project they just run `/psyflow:setup`
inside the project — it installs everything per-project (the design kit for
UI projects via selective `add`, the optional ui-ux-pro-max engine, and
code-review-graph) with its own checks and failure diagnosis. No manual
commands to memorize; the exact commands live in the setup stage command
itself.

### 5. Self-check and report

When done, report a checklist to the user:

- [ ] CLAUDE.md psyflow blocks (pipeline / code-review-graph / conventions)
- [ ] Plugin: psyflow (eight stage commands + psyflow / to-architecture
      skills, installed interactively by the user, verified by you)
- [ ] No legacy workbench-era copies left in `~/.claude/skills/` or
      `~/.claude/commands/`
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
  (or re-clone) and re-run `install.sh` for the CLAUDE.md blocks; the flow
  itself updates via `/plugin marketplace update psyflow` (run by the
  user), and offer to update third-party marketplaces the same way
  (`/plugin marketplace update <name>`). If working inside a project, also
  offer to update project tools (`uv tool upgrade code-review-graph` — it
  is a PyPI package, not npm — then re-run `code-review-graph build`;
  major versions can invalidate the old graph). Third-party upstream
  changes may drift from the README teaching — mention the
  verified-versions table if the user hits inconsistencies. Everything is
  designed to be re-run safely. Report what was updated at the end.
- `install.sh` is idempotent and safe to re-run (marker-based blocks are
  replaced in place; CLAUDE.md is backed up automatically each run).
  User customizations OUTSIDE the psyflow marker blocks are never touched;
  anything inside the markers is replaced — warn the user if you detect
  hand-edits inside a psyflow block before replacing it.
- Never copy third-party skill content into the user's directories — their
  marketplace is their update channel; a copy strands the user on a stale
  version forever.
- Community marketplaces do NOT auto-update by default. If the user wants to
  track upstream, point them to `/plugin` → Marketplaces → Enable
  auto-update, or a periodic `/plugin marketplace update <name>`.
