---
description: "Workbench stage 4 — cut the frozen spec into tickets"
---

Load the `workbench` skill with the Skill tool for the cross-stage rules,
then execute stage 4 (/tickets — cut the spec into tickets) by the stage
rules below.

## Stage rules

- Each ticket independently completable; no ticket straddles a boundary
  /spec's architecture decisions just drew.
- Each ticket's acceptance criteria = the scenario IDs it covers; a ticket
  covering no scenario states its acceptance criteria explicitly instead.
  No ticket is cut without acceptance criteria.
- **explore-codebase** for impact when the project has code.
- 5 or more tickets → run one independent plan-readiness review before
  starting (use a fresh-context reviewer role when the environment provides
  one, e.g. plan-verifier).

Additional context from the user: $ARGUMENTS
