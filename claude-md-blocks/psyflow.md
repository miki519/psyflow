<!-- psyflow:pipeline:begin -->
<!-- psyflow v2.0.0 -->
<!-- Thin pointer by design: cross-stage rules live in the psyflow skill,
     each stage's own rules in its slash command (single source of truth —
     content lives in exactly one place).
     Composes with any orchestration layer present:
     stages describe WHAT happens in what order; orchestration governs HOW
     work is delegated, approved, and verified within each stage. -->
## Psyflow Flow (reusable across projects)

Feature work runs through the eight-stage psyflow flow, one slash command
per stage, always driven manually by the user:

/setup → /discover → /design* → /spec → /tickets → /build → /accept → /release

- Installed as the `psyflow` plugin: stages are invoked as
  `/psyflow:<stage>` (e.g. `/psyflow:discover`); the short names above are
  the flow's logical names.
- /discover is the sole entry point for feature work; /setup runs once per
  project. /release requires a passed /accept.
- Stages marked * are conditional — announce the skip out loud, never
  skip silently.
- Each stage's own rules (engine skills, outputs, gates) live in that
  stage's slash command; the cross-stage rules (driving, ownership,
  handoffs, standing rules) live in the **psyflow skill**. On any stage
  command, follow the command's stage rules and load that skill — do not
  improvise stage behavior from this summary alone.
- When a referenced engine skill is absent from the current project, fulfill
  the stage's intent manually; never skip a stage for lack of tooling.
<!-- psyflow:pipeline:end -->
