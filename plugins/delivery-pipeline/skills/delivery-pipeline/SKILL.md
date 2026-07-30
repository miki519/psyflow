---
name: delivery-pipeline
description: Load the eight-station delivery pipeline and run the current task
  through it. Use when starting feature work, when the user invokes any
  pipeline station (/grill-me, /prototype, /to-spec, /to-architecture,
  /to-ticket, /implement, /code-review, /ship), or when the user asks how the
  delivery workflow is organized.
---

# Delivery Pipeline — the full workflow

Eight stations, each invoked as a slash command. Each command auto-mounts
whatever supporting skills exist in the current project. Stations marked *
are conditional: when their condition is absent, say so explicitly and skip —
never skip silently.

/grill-me → /prototype* → /to-spec → /to-architecture* → /to-ticket
→ /implement → /code-review → /ship

## The stations

1. **/grill-me** — Interview question by question, one recommended answer per
   question, decisions locked one at a time. On first contact with a new
   domain, run /domain-modeling once to fix the vocabulary (ubiquitous
   language: copy and code identifiers share one source). If the project
   carries a design knowledge base (e.g. ux-ui-agent-skills), its standards
   (a11y, taste, contrast) back every recommended answer. Post-release
   observations filed in `docs/research/` are standing evidence for the next
   round — this is how the pipeline closes into a loop.

2. **/prototype*** — Condition: the deliverable has a visible screen or
   interaction ("no UI in this ticket, skipping prototype"). When it runs:
   first state the question this prototype must answer (throwaway-prototype
   thinking), then deliver an interactive HTML page for hands-on play. If a
   design kit is present, consume its tokens and run its gates (contrast
   etc.); every number is measured, never asserted. Candidate values explored
   here are not yet tokens. Advance only when the user is satisfied — before
   they can see it, no interview extracts the real requirement.

3. **/to-spec** — Turn locked decisions into a spec. Any spec containing UI
   must include: token mapping, interaction-state table (default / hover /
   focus / selected / disabled), and a11y acceptance criteria. Every feature
   spec includes a **flow section** with three paths — success, failure, and
   **recovery** (how the user gets back onto the success path) — and an
   **instrumentation section** (what to measure after release; implemented in
   /implement, checked in /code-review). **This is the only station that
   writes the design system**: tokens are created or modified here (SemVer
   per governance) and component specs are born here (anatomy, variants, the
   8 states, token mapping, ARIA/keyboard model). Modifying an existing token
   or component requires an **impact analysis**: which components → which
   screens → which flows → breaking or not → migration note. The
   design-foundation spec additionally owns **foundations.md** — layout grid,
   navigation model, iconography, motion grammar, writing style —
   project-specific choices only.

4. **/to-architecture*** — Condition: the ticket crosses a module, service,
   API, or data boundary ("no architectural decision in this ticket,
   skipping"). Delegates module/service boundary design to /codebase-design
   when available; itself owns the recording (ADRs in `docs/decisions/`,
   machine-checkable contracts in `packages/`) and the non-module dimensions:
   API contracts, state management, data/event flow, cache and integration
   strategy. See the companion /to-architecture skill for the full procedure.

5. **/to-ticket** — Cut the spec (and its architecture decisions) into
   tickets. Tickets should not straddle a boundary /to-architecture just drew.

6. **/implement** — Logic features go test-first (/tdd where available); UI
   code consumes the established tokens and component specs — a missing token
   or component spec goes back to /to-spec; never hardcode values or
   hand-roll a one-off component copy inline. Implement the spec's
   instrumentation section along with the feature. Shared components ship
   with a states harness (all variants × states in one HTML) for gates to
   target.

7. **/code-review** — Always run the two-axis review (Standards + Spec —
   including: were the instrumentation events actually implemented?). If the
   ticket touched UI, additionally run the design acceptance pass (design-kit
   gates with a real N/N result + a six-dimension design review, harness
   rendered and inspected — gates pass while pixels can still be wrong); if
   no UI was touched, skip the design items and say so.

8. **/ship** — Pre-release gate. Use the project's release skill when present;
   otherwise fulfill the intent manually (tests green, changelog, version,
   deploy steps). After release, observations (metrics, errors, user
   feedback) are filed into `docs/research/` as evidence for the next
   /grill-me — improvement is not a station, it is this routing rule.

## Standing rules

**Component promotion**: a pattern lives inside its page at first appearance;
on its second appearance across pages it is promoted to the shared component
library via /to-spec (full 8-state spec, both call sites converge on one
implementation). Exception: core primitives known to be site-wide from day
one ship with the design-foundation ticket. No speculative component building.

**Four layers of design documentation**: tokens (the values), component specs
(the blocks), foundations (how blocks compose), flows (how screens connect).
Tokens and components alone are not a design system.

**Artifact locations** (default layout, adapt to the host project):
- `docs/` — human-facing artifacts: `domain-model.md`, `decisions/`
  (rulings + ADRs), `prototypes/` (throwaway but kept as evidence), `specs/`
  (each with its `tickets.md`; design-foundation also holds `foundations.md`),
  `research/` (investigations + post-release observations).
- `packages/design-tokens/src/` — DTCG token source of truth;
  `packages/design-tokens/dist/` — generated artifacts, never hand-edited.
- Shared components live with their spec, states harness, and tests in one
  folder. API/event contracts live in `packages/`.
- Boundary rule: a file the build/toolchain reaches belongs in
  `packages/`/`apps/`; a file nothing imports belongs in `docs/`.

**Principle — fixed stations, flexible mounting**: when a command or skill is
absent from the current project, fulfill the station's intent manually; never
skip a station for lack of tooling (the two conditional stations' announced
skips are the only exceptions). Event-driven skills (research, debugging,
merge-conflict resolution) stay out of the main pipeline.
