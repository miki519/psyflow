---
description: "Workbench stage 6 — acceptance review (no deployment)"
---

Load the `workbench` skill with the Skill tool for the cross-stage rules,
then execute stage 6 (/accept — acceptance) by the stage rules below. This
stage never deploys anything.

## Stage rules

- **code-review** (Standards + Spec axes) + **review-changes**
  (code-review-graph) on everything since the flow started.
- Scenario coverage is mechanical: extract IDs from the frozen spec, grep
  the test code, the difference must be empty and all green. Human review
  covers only what Given/When/Then cannot express (visuals, feel).
- UI touched → design acceptance: run the kit's gates with a REAL N/N result,
  **design-review**, and render-and-inspect (gates pass while pixels can
  still be wrong). Not touched → say the design items are skipped.
- Conditional: **a11y-audit**, **performance** when the work warrants them.
- Finish with one independent fresh-context verification of the acceptance
  claim (verifier role when available).
- Output: an acceptance report. Pass → "next: /release". Fail → fix, re-run.

Additional context from the user: $ARGUMENTS
