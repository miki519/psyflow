---
description: "Workbench stage 2 — UI/UX discussion and interactive prototype"
---

Load the `workbench` skill with the Skill tool for the cross-stage rules,
then execute stage 2 (/design — UI/UX discussion, conditional on a visible
screen or interaction) by the stage rules below. If the current work has no
visible screen or interaction, announce the skip out loud and point the
user to /spec instead.

## Stage rules

- Engines: **grilling** for design rulings; **prototype** (Matt) frames the
  question the prototype must answer; the design kit's **prototype** ladder
  delivers an interactive HTML page for hands-on play.
- **ui-ux-pro-max** (if installed) retrieves style/palette/typography
  candidates first (`--design-system`, tune with `--variance/--motion/
  --density`; persist the chosen direction with `--persist --output-dir
  <project-root>` → `design-system/<slug>/MASTER.md`); **apply-aesthetic**
  converges direction from those candidates (or from scratch when the
  engine is absent); **design-tokens** for candidate values — values
  explored here are NOT yet tokens.
- Conditional engines: **brandkit** (new brand), **redesign** (existing UI),
  **ux-writing** (copy-heavy screens), **a11y-audit** (on demand);
  **design-review** only for large screens, not every widget.
- Every number measured, never asserted: run the kit's gates on anything
  rendered (contrast, states), and LOOK at the render.
- Output: the user-approved prototype (定稿). Advance only when the user is
  satisfied.

Additional context from the user: $ARGUMENTS
