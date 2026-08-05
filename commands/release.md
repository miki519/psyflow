---
description: "Workbench stage 7 — staged rollout: staging, confirm, production"
---

Load the `workbench` skill with the Skill tool for the cross-stage rules,
then execute stage 7 (/release — staged rollout) by the stage rules below.
Precondition: /accept has passed for this round of work — if it has not,
stop and require it before deploying anything.

## Stage rules

- If /accept has not passed for this round of work, stop and require it —
  never deploy silently.
- Pre-flight checklist (migrations, env vars, rollback plan), then deploy to
  **staging** (Docker) → verify on staging → the user confirms → deploy to
  **production** (Docker). Two environments, always in that order.
- After release: file observations (metrics, errors, feedback) into
  `docs/research/` for the next /discover — improvement is not a stage, it
  is this routing rule.

Additional context from the user: $ARGUMENTS
