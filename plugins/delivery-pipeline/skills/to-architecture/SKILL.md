---
name: to-architecture
description: Turn a locked spec into architecture decisions before ticketing.
  Use after /to-spec when the work crosses a module, service, API, or data
  boundary. Produces ADRs and machine-checkable contracts. For logic contained
  in one module, announce the skip instead.
---

# /to-architecture — Architecture Decision Stage

Sits between /to-spec and /to-ticket in the delivery pipeline. The spec says
WHAT the product does; this stage decides HOW the system is shaped to do it,
before the work is cut into tickets.

## Step 0 — Condition check (mandatory, out loud)

Run this stage only when the ticket crosses at least one of: module
boundary, service boundary, external API surface, data/schema ownership,
event flow, cache layer, third-party integration. Otherwise state explicitly
"no architectural decision in this ticket, skipping /to-architecture" and
hand over to /to-ticket. Never skip silently; never run ceremonially.

## Step 1 — Read the inputs

The locked spec (including its flow and instrumentation sections), existing
ADRs in `docs/decisions/`, existing contracts in `packages/`, and the current
module map. Architecture decisions must extend the existing shape, not
restart it.

## Step 2 — Decide, one boundary at a time

Work through only the dimensions the ticket actually touches:

- **Module / service boundary** — do NOT reason about this here: invoke
  /codebase-design and apply its deep-module vocabulary to decide what
  belongs together and where the seams go. This stage only RECORDS the
  outcome as an ADR; the design thinking belongs to that skill. It is also
  the follow-up tool when a later refactor revisits the boundary.
- **API contract** — endpoints, request/response schemas, error envelope,
  versioning stance. Contract-first: the schema file is the decision.
- **State management** — where state lives (server / client / URL / cache),
  who is source of truth, invalidation strategy.
- **Data & event flow** — who writes, who reads, ordering and idempotency
  requirements, what is transactional.
- **Cache strategy** — what is cached, keyed how, invalidated when.
- **Integration boundary** — third-party seams, failure modes, retry policy
  (align with the spec's recovery paths).

For each decision record the alternatives considered and why they lost.
A decision with no rejected alternative is a description, not a decision.

## Step 3 — Produce the artifacts

- **ADR** → `docs/decisions/NNN-<slug>.md`: context, decision, alternatives
  considered, consequences (including what becomes harder). One ADR per
  decision, numbered, append-only — superseding beats editing.
- **Contracts** → `packages/` (e.g. OpenAPI spec, event schema, shared
  types): machine-checkable, imported by implementations, versioned with the
  code. A contract that only exists in prose is not a contract.

## Step 4 — Hand off

Summarize the decisions in one screen for the user, list the ADR/contract
files produced, and state what /to-ticket should now slice along (tickets
should not straddle a boundary you just drew). Architecture decisions here
are subject to the same approval discipline as any plan: present, get the
nod, then ticket.

## Guardrails

- Decide only what the current ticket needs — no speculative architecture
  for features that do not exist yet (YAGNI applies to boundaries too).
- Never contradict an existing ADR silently: supersede it with a new one
  that names what changed and why.
- This stage writes `docs/decisions/` and contract files only — no
  implementation code, no token files, no component specs.
