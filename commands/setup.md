---
description: "Workbench stage 0 — initialize this project's working environment"
---

Load the `workbench` skill with the Skill tool for the cross-stage rules,
then execute stage 0 (/setup — project initialization, once per project)
by the stage rules below.

## Stage rules

- Check git first: `git rev-parse --is-inside-work-tree`. Not a repo →
  run `git init` (and report it); already a repo → say so and move on.
- Check Docker: `docker info` (daemon reachable, not just the binary).
  Missing or not running → report it as a blocker for /release (deploys
  are Docker-based); do not fail the rest of /setup over it.
- Check GitHub CLI login: `gh auth status`. Not logged in → ask the user
  to run `gh auth login` themselves (it is interactive; never run it
  headless or store credentials on their behalf), then re-check.
- Verify `node`/`npx`, then: UI project → `npx ux-ui-agent-skills init`;
  all projects → `code-review-graph install --platform claude-code`
  (no `build` yet — the project is still empty). Diagnose failures, never
  skip silently. Report what was installed.
- File one out-of-flow infra ticket: wire the design-qa / CI gates once the
  project has code (design-qa is infrastructure, not a stage).

Additional context from the user: $ARGUMENTS
