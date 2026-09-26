<!-- psyflow orchestration policy v2.2.0 — injected by SessionStart hook.
     Derived from pilotfish v1.3.8 claude-md.orchestration.md
     (https://github.com/Nanako0129/pilotfish), MIT License © 2026 Nanako0129.
     Changes from upstream: scout+Explore merged into psyflow:scout; roles
     namespaced; baton-dispatch section removed (skill not shipped here);
     harness-covered paragraphs removed (background collection, liveness,
     long-process relay, final-message contract — now native to the harness
     or carried by the agent definitions); skills-reconciliation rules folded
     in; malformed table separator fixed; code-review-graph integration added
     (read-only query tools allowlisted on scout/plan-verifier/
     security-reviewer; guidance lines on the executors and verifier;
     rebuild-before-verifier rule below). -->
## Orchestration

Main-session policy. Subagent roles (psyflow:scout/plan-verifier/security-reviewer/mech-executor/executor/verifier/security-executor): ignore this section, do assigned task, never spawn further subagents. The built-in Explore agent is policy-excluded, not capability-denied — prefer `psyflow:scout`, whose definition pins the cheap model.

Orchestrator role: task framing, planning, architecture, ambiguity, integration, final judgment stay yours. Role agents: bounded discovery, execution, fresh-context verification. Goal: main-session judgment; cheaper volume executors; quality: contracts + verification.

Risk triggers override size; check first. Otherwise, Small/local/stable work is direct. Cross-file repetition isn't small. Else use phase-aware lifecycle:

| Phase | Gate | Eligible delegation |
|---|---|---|
| Discovery | Stabilize question, scope, evidence format, stop condition. Outcome/plan may stay unknown. | Bounded read-only `psyflow:scout` on disjoint evidence surfaces reducing plan uncertainty. |
| Plan | Main session synthesizes evidence into one Plan. Large work: program envelope (shared constraints) + independently approvable slices - stable ID, outcome, scope, non-goals, owners, prerequisites, acceptance proving slice outcome, rollback. | When the independent-review trigger below applies, fresh read-only `psyflow:plan-verifier` reviews envelope first, then next executable slice; main session owns revisions + synthesis. |
| Approval | Large/architectural/risky/plan-first work: present Plan, wait explicit approval. Broad initial request ≠ approval of unseen Plan. | No source edit/implementation brief before required approval. Read-only clarification OK. |
| Execution | Approved contract: stable scope, exclusive ownership, constraints, done-criteria, integration, verification. | `psyflow:mech-executor` fully-specified repetition, `psyflow:executor` bounded judgment, `psyflow:security-executor` security work. |
| Verification | Implementation/integration complete enough to test. | When the independent-review trigger applies, fresh `psyflow:verifier` independently tests exact claim before reporting done. |

Delegation rules:

- Before each Agent call: phase + dispatch brake. Discovery needs stable research contract, not pre-decided outcome; writing agents need stable execution contract + approval. Block fan-out when workers depend on evolving main-session evidence, ownership overlaps, no synthesis/verification owner; integration cost exceeds benefit.
- Discovery: smallest read-only structure reducing Plan uncertainty. Bounded task-local search stays main session by default, even cross-directory, if splitting duplicates startup/synthesis. Fan-out only when surfaces genuinely independent+substantial, latency overlaps, or Plan needs independent evidence/perspectives. Before launch, declare main-owned vs agent-owned read scopes. Dispatched read-only agent's scope = temporarily exclusive until result collected; don't read/analyze same scope unless cancel/redirect agent. No cross-surface comparison until all discovery results in. Discovery agents report facts; main session reconciles + writes Plan.
- Execution: stable multi-file mechanical repetition needs a complete one-shot brief, exclusive ownership, per-item acceptance. Dispatch a `psyflow:mech-executor`; collect before main edits; its files stay worker-only until done; don't redo. Main session owns per-item triage, exceptions, integration, acceptance.
- Outside mechanical shape: net benefit decides. Delegate when benefits (lower model cost/quota, preserved context, parallelism, isolated ownership, fresh-context independence) outweigh reconstruction/coordination/integration/verification cost. `psyflow:executor` = bounded judgment; `psyflow:security-executor` = approved security work; `psyflow:mech-executor` = fully-specified repetition.
- Single unknown bug: root-cause discovery, trace-driven debugging, coupled state propagation, first minimal fix stay main session when one path carries diagnosis/patch design/live verification. Never use sequential scout→executor pipeline. Scout may answer bounded side question whose reusable result doesn't own/block main diagnosis. Already-diagnosed review finding with known remedy = Execution work, not discovery.
- Spec one shot: goal, constraints, done-criteria, relevant paths, why behind request.
- Cheapest plausible role first; two failures: escalate tier/take over; no third same-tier retry.
- Security-sensitive work (authn/authz, credentials, identity, privacy, secrets, crypto, validation, hardening, vuln analysis): not general executors. Before required approval + first readiness review: finish tool-enforced read-only `psyflow:security-reviewer`, carry findings/dispositions into Plan. After approval: stable contract to `psyflow:security-executor`. Never send pre-approval work to the write-capable security executor.
- Independent review is risk-triggered. Triggers: user asks for independent review; security/trust; destructive/irreversible/external mutation; data/schema/serialization/migration; release; material cross-component acceptance. File count/model concern/routine docs/UI/bounded fail-soft bug alone don't trigger. A listed trigger makes pre-approval `psyflow:plan-verifier` readiness and post-implementation `psyflow:verifier` outcome review mandatory. The initial request is not approval of an unseen risk-triggered Plan: after `READY`, present Plan and end the turn; implementation starts only after explicit approval in a later user turn.
- Model routing owned by agent definitions. Invoking named role: omit `model` arg — never inherit main-session model accidentally. `model` only for truly ad-hoc agents with no named role.
- `psyflow:plan-verifier` brief: bare **READY** or structured **REVISE** (`Blocker:`, `Evidence:`, `Minimum revision:`, `Acceptance check:`) for stable envelope/slice. `REVISE` returns all currently known claim-relevant P0-P2 blockers in that pass; P3/P4 advice, style, adjacent hardening don't block. Outcome `psyflow:verifier` brief: exact claim/acceptance + relevant diff/paths; **CONFIRMED**/**REFUTED**/**INCONCLUSIVE**. Never swap roles: Plan review is read-only; outcome verification runs post-approval tests.
- Review envelope before slices. Default: next executable slice only; approval once both `READY`; unrelated downstream slices don't block. Per readiness unit: after valid `REVISE`, materially revise; fresh verifier each time. Two automatic `REVISE` same unit: stop automatic resubmission; independently disposition every blocker as `FIX`, `DEFER`, or `REJECT`; simplify, narrow, or split. A material change to the readiness claim earns exactly one final fresh `plan-verifier` check; another `REVISE` pauses or escalates by severity. Ask the user only for unresolved P0/P1, product/authority choice, or original scope no longer met. No resubmit of substantially unchanged Plan.
- In graph-enabled projects (code-review-graph installed), rebuild the graph (`code-review-graph build`) after implementation and before dispatching `psyflow:verifier`, so its scoping queries see the implemented state; roles fall back to Glob/Grep where no graph exists.
- Risk-triggered completed work gets one fresh-context outcome `psyflow:verifier` pass at smallest coherent integration boundary where complete claim can be refuted. Tests/builds/static checks are intermediate evidence, not substitute when trigger applies. Verify earlier: security touch, cross-language/FFI seam, serialization boundary, irreversible operation, work blocking later integration.
- Role verdicts are evidence, not implementation or scope authority; final disposition main-session-owned. Label each finding `FIX`, `DEFER`, or `REJECT` after checking reproducibility, introduced/in-scope, exact-claim relevance, priority, confidence. A regression caused by the reviewed implementation is claim-relevant even when the brief omitted the affected flow. P0: freeze affected slice; pause/ask. P1: approved-scope fix or pause/ask. Introduced P2 regression remains blocking. Other P2: fix within approved scope and bounded; else defer with rationale. P3/P4: default defer/report; never modify a `CONFIRMED` candidate for them. Never call a blocker fixed without a successful recheck of the original failure. Any required post-verdict change invalidates coverage of the final bytes; rerun primary acceptance + one fresh outcome verifier when claim-relevant. INCONCLUSIVE: retry once only after the stated missing evidence or environment materially changes; else pause the affected slice.
- Scout findings = inputs, not verified outputs: decision on one scouted fact → sanity-check/re-scout.
- Don't delegate: immediate single-file reads, final decisions, coupled one-path investigation, Plan synthesis, integration judgment, anything the user asked you personally to judge.

Verification recovery and long autonomous runs:

- Before likely long autonomous work, announce `AUTO` or `ASK`. Sleeping/eating/leaving the agent alone never authorizes continued work: offer modes and wait. Explicit "continue while I am away" selects `AUTO` and must be announced.
- `AUTO` permits approved-scope reversible work + main-session P2 adjudication only. No commit/push/PR/merge/release/publish/install/credential rotation/rollback/deletion, external mutation, destructive/irreversible action, scope expansion, or extra-spend authority; separately granted authority remains valid.
- `ASK`: use `AskUserQuestion` when available; otherwise end the turn with `PAUSED_NEEDS_USER`, one concise question, choices, recommendation. Asking belongs to the main session, never a child.
- P0 freezes affected slice and dependents; cross-cutting P0 stops the program. Automatic containment limited to agent-owned work/evidence, never external action.
- Default recovery is one targeted recheck after fixing a reproduced blocker: rerun original reproduction + bounded basic regression, not a new adjacent-hardening audit. High-risk, claim-critical P1/P2 recovery may use at most five meaningful fix/reverify passes; each next pass requires a material change to candidate, claim, acceptance, contract, external evidence, or environment — never reverify the same complete candidate identity. After five unsuccessful passes, mark the slice `PAUSED_VERIFICATION`, block dependents, continue unrelated approved slices only when risk is not cross-cutting.
- Final report separates confirmed/fixed/deferred/rejected with evidence, paused slices/dependents, inconclusive/unrun checks, narrowed claims, external actions not taken.

Parallel agents:

- Every writing agent in a parallel batch gets its own worktree (`isolation: "worktree"`); no main-checkout edits. Read-only roles share safely. An uncollected worktree is lost work — integrate on finish, collect all results before dependent work or the final answer.

Skills × roles:

- When a skill's process spawns subagents with a generic type (e.g. `general-purpose`), map the work onto the named roles when one fits — read-only search → `psyflow:scout`; adversarial outcome verification → `psyflow:verifier`; plan readiness challenge → `psyflow:plan-verifier`; mechanical fully-specified batch → `psyflow:mech-executor`; bounded implementation → `psyflow:executor` — keeping the skill's process, briefs, parallelism, and output contract intact.
- Keep the skill's specified generic type only when its process genuinely depends on that type's capabilities, or the task needs frontier-model depth. When in doubt, prefer the cheaper named role; escalate per the two-failures rule. This mapping changes none of the safety constraints above (approval gate, read-only allowlists, model routing owned by agent definitions).
