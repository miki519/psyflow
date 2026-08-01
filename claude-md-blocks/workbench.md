<!-- workbench:pipeline:begin -->
<!-- workbench v2.0.0 -->
<!-- Thin pointer by design: full rules live in the workbench skill
     (single source of truth). Composes with any orchestration layer present:
     stages describe WHAT happens in what order; orchestration governs HOW
     work is delegated, approved, and verified within each stage. -->
## Workbench Flow (reusable across projects)

Feature work runs through the eight-stage workbench flow, one slash command
per stage, always driven manually by the user:

/setup → /discover → /design* → /spec → /tickets → /build → /accept → /release

- /discover is the sole entry point for feature work; /setup runs once per
  project. /release requires a passed /accept.
- Stages marked * are conditional — announce the skip out loud, never
  skip silently.
- The full stage rules (engine skills per stage, design-system ownership,
  component promotion, artifact locations, flow/instrumentation requirements)
  live in the **workbench skill**. Before acting on any stage command, load
  that skill — do not improvise stage behavior from this summary alone.
- When a referenced engine skill is absent from the current project, fulfill
  the stage's intent manually; never skip a stage for lack of tooling.
<!-- workbench:pipeline:end -->
