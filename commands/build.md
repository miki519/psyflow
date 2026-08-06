---
description: "Workbench stage 5 — implement, ticket by ticket"
---

Load the `workbench` skill with the Skill tool for the cross-stage rules,
then execute stage 5 (/build — implement) by the stage rules below.

## Stage rules

- Logic: **tdd**. UI: **design-code** — consume frozen tokens and component
  specs only; anything missing goes BACK to /spec, never hardcoded.
- **karpathy-guidelines** stay loaded for all code. **token-build** compiles
  tokens into platform artifacts here. **refactor-safely** before touching
  existing structures.
- Definition of done per ticket: every covered scenario ID has a test whose
  name contains the ID verbatim (greppable), all green — plain test
  framework, no step-definition layer — plus the spec's instrumentation
  implemented, and the states harness for shared components (all variants ×
  states in one HTML). Unless the ID carries a `unit waiver`, the claiming
  test's file must also contain the scenario's entry point verbatim (crude
  file-level string match is enough — a unit test on a pure function cannot
  claim an entry-point scenario, and code nothing calls cannot go green).
- Evidence discipline: rebuild artifacts before any e2e run (stale builds
  test old code and produce false signals). Record each ticket's green run
  in its document as one line — test command, result, commit hash — for
  later stages to cite.
- Verification is tiered by what the diff actually touches, never by the
  ticket's title: schema / migrations / API contracts / security /
  irreversible operations → full independent falsification; pure UI, copy,
  or style diffs → the kit's gates only, no agent re-reading code;
  narrative docs and comments → no verification (contract artifacts — spec,
  ADRs, schemas — are never "docs" for this purpose).
- Event-driven engines (invoked when the event occurs, never stages):
  **diagnosing-bugs**, **resolving-merge-conflicts**, **performance**.

Which ticket(s) to work on, per the user: $ARGUMENTS
