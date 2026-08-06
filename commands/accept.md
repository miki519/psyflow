---
description: "Workbench stage 6 — acceptance review (no deployment)"
---

Load the `workbench` skill with the Skill tool for the cross-stage rules,
then execute stage 6 (/accept — acceptance) by the stage rules below. This
stage never deploys anything.

## Stage rules

- FIRST action, before dispatching any reviewer: gather the round's
  deferred-decision list (choices /build parked for acceptance, known
  ticketed defects, recorded trade-offs) and hand it to the Standards and
  Spec reviewers with the instruction "do not re-derive these; flag only if
  new facts change a conclusion".
- **code-review** (Standards + Spec axes) + **review-changes**
  (code-review-graph) on everything since the flow started. Scope the
  Standards and Spec axes through review-changes' reference chains from the
  diff — never whole-file reads of untouched code; group the Spec axis by
  scenario (each reviewer takes scenario IDs plus every file those
  scenarios involve, so cross-file drift stays visible). The security
  review, when the work warrants one, reads the full diff and gets NO
  deferred-decision list — its value is independent cross-file reasoning.
  Every reviewer report separates "confirmed by reading the code path"
  from "speculative, needs runtime verification"; conclusions stay concise
  (a few hundred words), findings themselves are never dropped for length.
- Cite /build's recorded green runs instead of re-running everything —
  valid only while the recorded commit hash matches current HEAD; after
  any fix, re-run the affected tests, never trust stale evidence.
- Scenario coverage is mechanical: extract IDs from the frozen spec, grep
  the test code, the difference must be empty and all green. Human review
  covers only what Given/When/Then cannot express (visuals, feel).
- UI touched → design acceptance: run the kit's gates with a REAL N/N result,
  **design-review**, and render-and-inspect (gates pass while pixels can
  still be wrong). Not touched → say the design items are skipped.
- Conditional: **a11y-audit**, **performance** when the work warrants them.
- Finish with one independent fresh-context verification of the acceptance
  claim (verifier role when available), scoped by what the round's diff
  touches: schema / migrations / API contracts / security / irreversible
  operations get full falsification; a purely UI/copy round relies on the
  gates plus render-and-inspect instead.
- Output: an acceptance report. Pass → "next: /release". Fail → fix, re-run.

Additional context from the user: $ARGUMENTS
