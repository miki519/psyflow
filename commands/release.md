---
description: "Psyflow stage 7 — staged rollout: staging, confirm, production"
---

Load the `psyflow` skill with the Skill tool for the cross-stage rules,
then execute stage 7 (/release — staged rollout) by the stage rules below.
Precondition: /accept has passed for this round of work — if it has not,
stop and require it before deploying anything.

## Stage rules

- If /accept has not passed for this round of work, stop and require it —
  never deploy silently.
- Deployment is decoupled from rounds. An **S** round that has passed
  /accept may be queued into the release batch (`docs/release-queue.md`:
  round, accept report, commit hash) instead of deployed at once; one
  /release ships every queued round together, running staging → confirm
  → production exactly once for the batch — every queued round's /accept
  hash must still be an ancestor of the deployed commit, otherwise that
  round is dropped from the batch and re-accepted. M / L rounds, or the
  user asking, release immediately.
- Pre-flight checklist (migrations, env vars, rollback plan), then deploy to
  **staging** (Docker) → verify on staging → the user confirms → deploy to
  **production** (Docker). Two environments, always in that order.
- Staging verification is deployment-layer only: migration results plus a
  smoke run that walks the core user path once end to end (login, primary
  flow) — it proves the deployed configuration actually activates the
  feature, the class of bug /accept's environment cannot surface. A batch
  of S rounds touching no deployment layer (no migration, env, or config
  change) shrinks the smoke run to that single core path. Do NOT
  re-verify the feature layer: cite /accept's passed report while its
  commit hash matches what was deployed (for a batch: is an ancestor of
  it); on mismatch, stop and require /accept again.
- After release: file observations (metrics, errors, feedback) into
  `docs/research/` for the next /discover — improvement is not a stage, it
  is this routing rule.

Additional context from the user: $ARGUMENTS
