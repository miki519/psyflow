---
description: "Psyflow stage 3 — consolidate rulings and freeze the spec"
---

Load the `psyflow` skill with the Skill tool for the cross-stage rules,
then execute stage 3 (/spec — consolidate and freeze) by the stage rules
below: re-present the consolidated result for final confirmation before
freezing anything.

## Stage rules

- Re-present the consolidated result of /discover + /design for one final
  confirmation, THEN freeze it as the spec.
- **This is the only stage that writes the design system**: **design-tokens**
  turns approved candidate values into tokens; **design-component** writes
  8-state component specs. Modifying an EXISTING token/component goes through
  **governance** (impact analysis: components → screens → flows → breaking or
  not → migration note). Modifying a frozen scenario is a spec change
  through the same governance (impact: which tickets and tests reference
  the ID). IDs are never reused or renumbered; a dead scenario is marked
  superseded, never deleted.
- Crossing a module, service, API, or data boundary → run **to-architecture**
  (delegates module thinking to codebase-design; records ADRs +
  machine-checkable contracts). Contained logic → announce the skip.
- **ux-writing** finalizes interface copy from the domain vocabulary.
- Every feature spec includes a **scenario section** — ledger examples are
  promoted to Given/When/Then scenarios, each with a stable ID (e.g.
  `EXP-EXPORT-03`) issued only here; the set must cover success / failure /
  recovery. Each scenario's When clause **names the user-visible entry
  point it drives** (HTTP route, CLI command, or screen action) as part of
  the frozen text; a scenario that genuinely has none instead carries a
  `unit waiver: <one-line reason>` line (changing either later goes through
  governance like any spec change). One or two boundary-revealing scenarios
  per rule — no exhaustive enumeration, obvious CRUD paths stay out.
  Scenarios freeze with the spec — and an **instrumentation section** (what
  to measure after release). UI specs include token mapping, an
  interaction-state table, and a11y acceptance criteria.
- Before freezing, run the known-failure checklist against the spec: every
  new function/endpoint has a caller landing in this same round; every
  referenced token exists; every migration is actually reversible; every
  piece of work has an owner including its test files. (Project-specific
  failure modes flow back via /release observations, not this list.)

Additional context from the user: $ARGUMENTS
