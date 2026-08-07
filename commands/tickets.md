---
description: "Psyflow stage 4 — cut the frozen spec into tickets"
---

Load the `psyflow` skill with the Skill tool for the cross-stage rules,
then execute stage 4 (/tickets — cut the spec into tickets) by the stage
rules below.

## Stage rules

- Each ticket independently completable; no ticket straddles a boundary
  /spec's architecture decisions just drew.
- Each ticket's acceptance criteria = the scenario IDs it covers; a ticket
  covering no scenario states its acceptance criteria explicitly instead.
  No ticket is cut without acceptance criteria.
- After cutting, transcribe the mapping table `scenario ID → entry point
  (from the frozen spec's When clause, or its unit waiver) → owning ticket`
  into the tickets document. Any blank cell = cutting is not finished; do
  not enter /build. The direction is always scenario → ticket, never
  "which files does each ticket touch" — a path can be unowned while every
  file is covered. Tickets added mid-/build update this table first.
- **explore-codebase** for impact when the project has code.
- 5 or more tickets → run one independent plan-readiness review before
  starting (use a fresh-context reviewer role when the environment provides
  one, e.g. plan-verifier).

Additional context from the user: $ARGUMENTS
