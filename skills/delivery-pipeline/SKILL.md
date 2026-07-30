---
name: delivery-pipeline
description: Load the eight-stage delivery pipeline and run the current task
  through it. Use when starting feature work, when the user invokes any
  pipeline stage (/grill-me, /prototype, /to-spec, /to-architecture,
  /to-ticket, /implement, /code-review, /ship), or when the user asks how the
  delivery workflow is organized.
---

# Delivery Pipeline

/grill-me → /prototype* → /to-spec → /to-architecture* → /to-ticket
→ /implement → /code-review → /ship

Stages marked * are conditional: when their condition is absent, say so
explicitly and skip — never skip silently.

## Why this pipeline exists: cross-discipline collaboration

The pipeline's purpose is to let UI/UX work, frontend, and backend
collaborate through **contract artifacts** instead of memory or chat
history. Every discipline handoff has a machine-checkable artifact; once
the contracts exist, work parallelizes.

```
  UX / design                     frontend            backend
  /prototype (look & feel) ─┐
  flow section (behavior)  ─┤
                            ├─ /to-spec ──→ tokens + component specs
                            │                  │ consumed by frontend
                            └─ /to-architecture ──→ API contract (schema)
                                               │ coded against by BOTH
  /implement: frontend and backend build IN PARALLEL against the
              contracts — neither waits for the other's code
  /code-review: contract drift fails review on either side
```

Handoff rules:

- **design → frontend**: tokens and component specs are the interface.
  Frontend never invents a visual value; a missing token or spec goes back
  to /to-spec, never gets hardcoded.
- **backend ↔ frontend**: the API contract is the interface. Frontend mocks
  against the schema while backend implements it; changing the contract is
  a new /to-architecture decision (superseding ADR), never an inline edit
  in one side's code.
- **UX → both sides**: the spec's flow section (success / failure /
  recovery) binds screen states and API error semantics to the same three
  paths — the UI's error screen and the API's error envelope are two views
  of one flow, not two inventions.
- **product → everyone**: the instrumentation section names the events
  once; frontend fires them, backend records them, /code-review checks
  they exist.

## Ownership rule — this skill only adds, never restates

Each stage's base behavior belongs to its own skill (grilling, prototype,
tdd, codebase-design, code-review, to-architecture, the design kit's
gate/ship). Load and follow THAT skill for how the stage works; what follows
is only what the pipeline adds on top. If a stage's skill is absent in this
project, fulfill the stage's intent manually — never skip a stage for lack
of tooling (the two conditional skips above are the only exceptions).

## Pipeline additions per stage

1. **/grill-me** — On first contact with a new domain, run /domain-modeling
   once (copy and code identifiers share one vocabulary). If a design
   knowledge base is present, its standards (a11y, taste, contrast) back the
   recommended answers. Observations filed in `docs/research/` are standing
   evidence for the next round — this is how the pipeline closes into a loop.
2. **/prototype*** — Condition: the deliverable has a visible screen or
   interaction. Deliver an interactive HTML page for hands-on play; consume
   the design kit's tokens and run its gates when present — every number
   measured, never asserted. Candidate values explored here are not yet
   tokens. Advance only when the user is satisfied.
3. **/to-spec** — Specs containing UI must include: token mapping,
   interaction-state table, a11y acceptance criteria. Every feature spec
   includes a **flow section** (success / failure / recovery) and an
   **instrumentation section** (what to measure after release). **This is
   the only stage that writes the design system**: tokens and component
   specs are created or modified here only; modifying an existing token or
   component requires an impact analysis (components → screens → flows →
   breaking or not → migration note). The design-foundation spec owns
   `foundations.md` (grid, navigation model, iconography, motion grammar,
   writing style — project-specific choices only).
4. **/to-architecture*** — Condition: the ticket crosses a module, service,
   API, or data boundary. Full procedure in the to-architecture skill.
5. **/to-ticket** — Tickets must not straddle a boundary /to-architecture
   just drew.
6. **/implement** — UI code consumes established tokens and component specs;
   anything missing goes back to /to-spec — never hardcode or hand-roll a
   one-off copy. Implement the spec's instrumentation along with the
   feature. Shared components ship with a states harness (all variants ×
   states in one HTML).
7. **/code-review** — Additionally check: were the instrumentation events
   implemented? If the ticket touched UI, run the design acceptance pass
   (gates with a real N/N result + design review, harness rendered and
   inspected — gates pass while pixels can still be wrong); if not, say the
   design items are skipped. Tiering is automatic.
8. **/ship** — After release, file observations (metrics, errors, feedback)
   into `docs/research/` for the next /grill-me — improvement is not a
   stage, it is this routing rule.

## Standing rules

- **Component promotion**: first appearance lives in its page; second
  appearance across pages promotes it to the shared library via /to-spec
  (full 8-state spec, call sites converge). Day-one site-wide primitives
  ship with the design-foundation ticket. No speculative components.
- **Four layers of design documentation**: tokens → component specs →
  foundations → flows. The first two alone are not a design system.
- **Artifact locations** (default, adapt to host project): human-facing
  artifacts in `docs/` (`domain-model.md`, `decisions/`, `prototypes/`,
  `specs/` with `tickets.md`, `research/`); token source in
  `packages/design-tokens/src/` (generated `dist/` never hand-edited);
  shared components live with spec + harness + tests in one folder;
  contracts in `packages/`. Boundary: toolchain-reachable → `packages/` /
  `apps/`; imported-by-nothing → `docs/`.
- Event-driven skills (research, debugging, merge-conflict resolution) stay
  out of the main pipeline.
