<!-- workbench:delivery-pipeline:begin -->
<!-- workbench v1.2.0 -->
<!-- Thin pointer by design: full rules live in the delivery-pipeline skill
     (single source of truth). Composes with any orchestration layer present:
     stages describe WHAT happens in what order; orchestration governs HOW
     work is delegated, approved, and verified within each stage. -->
## Delivery Pipeline (reusable across projects)

Feature work runs through the eight-stage pipeline, one slash command per stage:

/grill-me → /prototype* → /to-spec → /to-architecture* → /to-ticket
→ /implement → /code-review → /ship

- Stages marked * are conditional — announce the skip out loud, never
  skip silently.
- The full stage rules (design-system ownership, component promotion,
  artifact locations, flow/instrumentation requirements) live in the
  **delivery-pipeline skill**. Before acting on any stage command, load
  that skill — do not improvise stage behavior from this summary alone.
- When a referenced skill is absent from the current project, fulfill the
  stage's intent manually; never skip a stage for lack of tooling.
<!-- workbench:delivery-pipeline:end -->
