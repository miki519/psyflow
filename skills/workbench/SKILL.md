---
name: workbench
description: Load the workbench delivery flow and run the current stage.
  Use when the user invokes any workbench stage command (/setup, /discover,
  /design, /spec, /tickets, /build, /accept, /release), or when the user
  asks how the delivery workflow is organized.
---

# Workbench Flow

/setup → /discover → /design* → /spec → /tickets → /build → /accept → /release

The flow is designed from the perspective of one person wearing three hats —
product originator, PM, and full-stack engineer. Each stage says WHAT must be
produced and WHICH mature skills to invoke as engines; the engines say HOW.

`*` = conditional stage: when its condition is absent, say so explicitly and
skip — never skip silently.

## Driving rule — always manual

The user drives every stage by typing its command. Complete exactly the stage
that was invoked, then hand control back with one line: what the next stage is
and what it will produce. Never run ahead to the next stage uninvited, and
never offer an "auto mode". `/discover` is the sole entry point for feature
work (`/setup` runs once per project before it).

## Ownership rule — this skill only adds, never restates

Each engine's base behavior belongs to its own skill (grilling, prototype,
tdd, codebase-design, code-review, to-architecture, the design kit's skills).
Load and follow THAT skill for how the engine works; what follows is only what
the flow adds on top. If an engine skill is absent in this project, fulfill
the stage's intent manually — never skip a stage for lack of tooling.

## Stages

### 0. /setup — project initialization (once per project)

- Check git first: `git rev-parse --is-inside-work-tree`. Not a repo →
  run `git init` (and report it); already a repo → say so and move on.
- Check Docker: `docker info` (daemon reachable, not just the binary).
  Missing or not running → report it as a blocker for /release (deploys
  are Docker-based); do not fail the rest of /setup over it.
- Check GitHub CLI login: `gh auth status`. Not logged in → ask the user
  to run `gh auth login` themselves (it is interactive; never run it
  headless or store credentials on their behalf), then re-check.
- Verify `node`/`npx`, then: UI project → `npx ux-ui-agent-skills init`;
  all projects → `code-review-graph install --platform claude-code`
  (no `build` yet — the project is still empty). Diagnose failures, never
  skip silently. Report what was installed.
- File one out-of-flow infra ticket: wire the design-qa / CI gates once the
  project has code (design-qa is infrastructure, not a stage).

### 1. /discover — requirement grilling (sole entry; diverge → converge)

- Core engine: **grilling** — one question at a time, each with a recommended
  answer, the user rules on each.
- On first contact with a new domain: run **domain-modeling** once (copy and
  code identifiers share one vocabulary).
- Need evidence? → **research**. Existing codebase? → **explore-codebase**
  (code-review-graph) to ground questions in what is already there.
- If the user drops a reference image, judge out loud whether it is a
  FEATURE reference (what it does → stays in /discover) or a VISUAL
  reference (how it looks → carried into /design via image-to-code).
- Output: rulings + scope. Routing duty at the end, announced in one line:
  UI touched → "next: /design"; logic-only → "skip /design → next: /spec".
- Observations filed in `docs/research/` by earlier /release rounds are
  standing evidence here — this is how the flow closes into a loop.

### 2. /design* — UI/UX discussion (condition: a visible screen/interaction)

- Engines: **grilling** for design rulings; **prototype** (Matt) frames the
  question the prototype must answer; the design kit's **prototype** ladder
  delivers an interactive HTML page for hands-on play.
- **apply-aesthetic** for direction; **design-tokens** for candidate values —
  values explored here are NOT yet tokens.
- Conditional engines: **brandkit** (new brand), **redesign** (existing UI),
  **ux-writing** (copy-heavy screens), **a11y-audit** (on demand);
  **design-review** only for large screens, not every widget.
- Every number measured, never asserted: run the kit's gates on anything
  rendered (contrast, states), and LOOK at the render.
- Output: the user-approved prototype (定稿). Advance only when the user is
  satisfied.

### 3. /spec — consolidate and freeze

- Re-present the consolidated result of /discover + /design for one final
  confirmation, THEN freeze it as the spec.
- **This is the only stage that writes the design system**: **design-tokens**
  turns approved candidate values into tokens; **design-component** writes
  8-state component specs. Modifying an EXISTING token/component goes through
  **governance** (impact analysis: components → screens → flows → breaking or
  not → migration note).
- Crossing a module, service, API, or data boundary → run **to-architecture**
  (delegates module thinking to codebase-design; records ADRs +
  machine-checkable contracts). Contained logic → announce the skip.
- **ux-writing** finalizes interface copy from the domain vocabulary.
- Every feature spec includes a **flow section** (success / failure /
  recovery) and an **instrumentation section** (what to measure after
  release). UI specs include token mapping, an interaction-state table, and
  a11y acceptance criteria.

### 4. /tickets — cut the spec into tickets

- Each ticket independently completable; no ticket straddles a boundary
  /spec's architecture decisions just drew.
- **explore-codebase** for impact when the project has code.
- 5 or more tickets → run one independent plan-readiness review before
  starting (use a fresh-context reviewer role when the environment provides
  one, e.g. plan-verifier).

### 5. /build — implement, ticket by ticket

- Logic: **tdd**. UI: **design-code** — consume frozen tokens and component
  specs only; anything missing goes BACK to /spec, never hardcoded.
- **karpathy-guidelines** stay loaded for all code. **token-build** compiles
  tokens into platform artifacts here. **refactor-safely** before touching
  existing structures.
- Implement the spec's instrumentation along with the feature. Shared
  components ship with a states harness (all variants × states in one HTML).
- Event-driven engines (invoked when the event occurs, never stages):
  **diagnosing-bugs**, **resolving-merge-conflicts**, **performance**.

### 6. /accept — acceptance (no deployment here)

- **code-review** (Standards + Spec axes) + **review-changes**
  (code-review-graph) on everything since the flow started.
- UI touched → design acceptance: run the kit's gates with a REAL N/N result,
  **design-review**, and render-and-inspect (gates pass while pixels can
  still be wrong). Not touched → say the design items are skipped.
- Conditional: **a11y-audit**, **performance** when the work warrants them.
- Finish with one independent fresh-context verification of the acceptance
  claim (verifier role when available).
- Output: an acceptance report. Pass → "next: /release". Fail → fix, re-run.

### 7. /release — staged rollout (precondition: /accept passed)

- If /accept has not passed for this round of work, stop and require it —
  never deploy silently.
- Pre-flight checklist (migrations, env vars, rollback plan), then deploy to
  **staging** (Docker) → verify on staging → the user confirms → deploy to
  **production** (Docker). Two environments, always in that order.
- After release: file observations (metrics, errors, feedback) into
  `docs/research/` for the next /discover — improvement is not a stage, it
  is this routing rule.

## Why this flow exists: cross-discipline collaboration

The flow lets UI/UX work, frontend, and backend collaborate through
**contract artifacts** instead of memory or chat history:

```
  UX / design                      frontend            backend
  /design (look & feel)  ─┐
  flow section (behavior)─┤
                          ├─ /spec ──→ tokens + component specs
                          │              │ consumed by frontend
                          └─ /spec (to-architecture) ──→ API contract
                                         │ coded against by BOTH
  /build:  frontend and backend build IN PARALLEL against the contracts
  /accept: contract drift fails acceptance on either side
```

Handoff rules:

- **design → frontend**: tokens and component specs are the interface. A
  missing token or spec goes back to /spec, never gets hardcoded.
- **backend ↔ frontend**: the API contract is the interface. Frontend mocks
  against the schema while backend implements it; changing the contract is a
  new architecture decision (superseding ADR), never an inline edit.
- **UX → both sides**: the spec's flow section binds screen states and API
  error semantics to the same three paths (success / failure / recovery).
- **product → everyone**: the instrumentation section names the events once;
  frontend fires them, backend records them, /accept checks they exist.

## Standing rules

- **Emergency hotfix escape hatch**: a production incident may enter
  through the event-driven engines (diagnosing-bugs) and, once fixed, go
  straight to /accept → /release — announce the skipped stages out loud.
  The /accept → /release gate itself is never skipped: /accept shrinks to
  "this fix verified, nothing else broken"; /release still runs staging →
  confirm → production. If the root cause exposes a design gap, file a
  follow-up /discover round — the escape hatch puts out the fire, it does
  not fix the fire hazard.
- **Component promotion**: first appearance lives in its page; second
  appearance across pages promotes it to the shared library via /spec
  (full 8-state spec, call sites converge). No speculative components.
- **Four layers of design documentation**: tokens → component specs →
  foundations → flows. The first two alone are not a design system.
- **Artifact locations** (default, adapt to host project): human-facing
  artifacts in `docs/` (`domain-model.md`, `decisions/`, `prototypes/`,
  `specs/` with `tickets.md`, `research/`); token source in
  `packages/design-tokens/src/` (generated `dist/` never hand-edited);
  shared components live with spec + harness + tests in one folder.
  Boundary: toolchain-reachable → `packages/` / `apps/`;
  imported-by-nothing → `docs/`.
