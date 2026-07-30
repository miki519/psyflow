# SETUP.md — Installation Manual for AI Agents

> This document is written for Claude Code (or any AI assistant) to read.
> The user will paste something like "Read SETUP.md in this repo and set up
> my environment accordingly" — then you execute it. Work step by step,
> verify each step, stop and report on failure. Never skip ahead.

## The environment you are building

A Claude Code working environment centered on the eight-station Delivery
Pipeline:

| Component | Layer | Install method |
|---|---|---|
| Delivery Pipeline (this repo) | global CLAUDE.md + personal skill | `install.sh` |
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
- `~/.claude/CLAUDE.md` now contains the `workbench:delivery-pipeline:begin` marker
- `~/.claude/skills/to-architecture/SKILL.md` exists
- `code-review-graph --version` produces output (if the global npm install
  failed, report it and offer an alternative — do not skip silently)

### 2. Guide the user through plugin installation

Plugin installation is an interactive in-app command — you cannot run it on
the user's behalf. List the commands, wait for the user to run them, then
verify:

```
/plugin marketplace add mattpocock/skills
/plugin marketplace add miki519/claude-workbench
/plugin install delivery-pipeline@claude-workbench
```

Verify: ask the user to open `/plugin` and check the installed list, or test
directly whether `/to-architecture` and `/grill-me` appear among the
available skills.

### 3. Explain the per-project steps (do not run them now)

Tell the user that for every new project:

```bash
# UI projects only:
npx ux-ui-agent-skills init
# All projects:
code-review-graph install --platform claude-code
code-review-graph build
```

### 4. Self-check and report

When done, report a checklist to the user:

- [ ] CLAUDE.md workbench blocks (delivery-pipeline / code-review-graph / conventions)
- [ ] Personal skill: to-architecture
- [ ] CLI: code-review-graph
- [ ] Plugins: mattpocock skills, delivery-pipeline (installed interactively
      by the user, verified by you)
- [ ] Per-project steps explained

If any item failed: report the cause and the impact honestly. Never mark a
failed item as done.

## Notes

- `install.sh` is idempotent and safe to re-run (marker-based blocks are
  replaced in place; CLAUDE.md is backed up automatically each run).
- Never copy third-party skill content into the user's directories — their
  marketplace is their update channel; a copy strands the user on a stale
  version forever.
- Community marketplaces do NOT auto-update by default. If the user wants to
  track upstream, point them to `/plugin` → Marketplaces → Enable
  auto-update, or a periodic `/plugin marketplace update <name>`.
