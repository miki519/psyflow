---
name: workbench
description: Load the workbench delivery flow's cross-stage rules.
  Use when the user invokes any workbench stage command (/setup, /discover,
  /design, /spec, /tickets, /build, /accept, /release), or when the user
  asks how the delivery workflow is organized.
---

# Workbench Flow — cross-stage rules

/setup → /discover → /design* → /spec → /tickets → /build → /accept → /release

The flow is designed from the perspective of one person wearing three hats —
product originator, PM, and full-stack engineer. Each stage's own rules live
in that stage's command file (`commands/<stage>.md` in the repo, installed as
the slash command) — the command says WHAT the stage must produce and WHICH
mature skills to invoke as engines; the engines say HOW. This skill holds
only the rules that span stages.

`*` = conditional stage: when its condition is absent, say so explicitly and
skip — never skip silently.

## Driving rule — always manual

The user drives every stage by typing its command. Complete exactly the stage
that was invoked, then hand control back with one line: what the next stage is
and what it will produce. Never run ahead to the next stage uninvited, and
never offer an "auto mode". `/discover` is the sole entry point for feature
work (`/setup` runs once per project before it).

## Ownership rule — stage rules only add, never restate

Each engine's base behavior belongs to its own skill (grilling, prototype,
tdd, codebase-design, code-review, to-architecture, the design kit's skills).
Load and follow THAT skill for how the engine works; stage rules only add
what the flow requires on top. If an engine skill is absent in this project,
fulfill the stage's intent manually — never skip a stage for lack of tooling.

## Handoff rules — contract artifacts over memory

The flow lets UI/UX work, frontend, and backend collaborate through contract
artifacts instead of memory or chat history:

- **design → frontend**: tokens and component specs are the interface. A
  missing token or spec goes back to /spec, never gets hardcoded.
- **backend ↔ frontend**: the API contract is the interface. Frontend mocks
  against the schema while backend implements it; changing the contract is a
  new architecture decision (superseding ADR), never an inline edit.
- **UX → both sides**: the spec's scenario section binds screen states and
  API error semantics to the same scenarios (success / failure / recovery
  coverage).
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
- **Human-only steps become wizards**: whenever progress blocks on steps
  only the human can perform — provisioning credentials, third-party
  dashboards, CI secrets, one-off migrations with manual confirmation —
  invoke **wizard** to generate a guided script instead of dictating the
  steps in chat; never for steps the agent can run itself. Secrets travel
  through the wizard's hidden input into `.env`/CI, never through the
  conversation. Repeatable paths (a new environment or teammate will run
  it again) → commit under `scripts/` and link from the README; one-off
  cutovers → scratch, delete after running.
- **CLAUDE.md is an index, not a manual**: the project's CLAUDE.md holds
  only pointers (where the tokens live, which skills to load, where specs
  are) — never rule bodies, design manuals, or checklists. Anything
  always-loaded is paid for in every session and every subagent; bulk
  content belongs in skills or `docs/`, loaded on demand. If a tool or
  installer wants to write a manual into CLAUDE.md, redirect it.
- **Artifact locations** (default, adapt to host project): human-facing
  artifacts in `docs/` (`domain-model.md`, `decisions/`, `prototypes/`,
  `specs/` with `tickets.md`, `research/`); token source in
  `packages/design-tokens/src/` (generated `dist/` never hand-edited);
  shared components live with spec + harness + tests in one folder;
  design-direction records from the ui-ux-pro-max engine (when used) in
  `design-system/<slug>/` (MASTER.md + per-page overrides — direction
  input to /design, not a substitute for tokens or component specs).
  Boundary: toolchain-reachable → `packages/` / `apps/`;
  imported-by-nothing → `docs/`.
