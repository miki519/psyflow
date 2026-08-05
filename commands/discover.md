---
description: "Workbench stage 1 — requirement grilling (sole entry point)"
---

Load the `workbench` skill with the Skill tool for the cross-stage rules,
then execute stage 1 (/discover — requirement grilling, diverge → converge)
by the stage rules below, including the routing announcement at the end.

## Stage rules

- Core engine: **grilling**.
- On first contact with a new domain: run **domain-modeling** once (copy and
  code identifiers share one vocabulary).
- Need evidence? → **research**. Existing codebase? → **explore-codebase**
  (code-review-graph) to ground questions in what is already there.
- If the user drops a reference image, judge out loud whether it is a
  FEATURE reference (what it does → stays in /discover) or a VISUAL
  reference (how it looks → carried into /design via image-to-code).
- Output: rulings + scope + an **example ledger**: every behavioral rule
  carries at least one one-line concrete example; examples no one can
  answer yet are filed as open questions. Only behavioral rules need
  examples — ADRs, process rules, and design axes (tokens, aesthetics)
  never do. No scenario IDs here — examples may still die or merge.
  Routing duty at the end, announced in one line:
  UI touched → "next: /design"; logic-only → "skip /design → next: /spec".
- Observations filed in `docs/research/` by earlier /release rounds are
  standing evidence here — this is how the flow closes into a loop.

What the user wants to explore: $ARGUMENTS
