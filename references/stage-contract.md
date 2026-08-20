# Stage contract — single source of workflow truth

This table is authoritative for prerequisites, owned output, blocking conditions, and routing.
Skill descriptions, command tooltips, templates, checker, README, and USER-GUIDE must not contradict
it. Update this file first, then run `tests/regression.sh` to detect contract drift.

`Requires` marked **(preferred)** means the stage runs standalone and self-analyzes the ticket
directly when that artifact is absent — it does not hard-block. Everything else in `Requires` is a
genuine blocker. Worklog artifact filenames renamed with the stage: `03-clarify-report.md`,
`03-clarify-README.md` (formerly `03-conflict-*`).

| Stage | Requires | Owns/produces | Blocks on | Next |
|---|---|---|---|---|
| decompose | epic-shaped request (spans >1 service/repo, mixes ticket Type, or independently shippable parts) | `epic-map.md` (project-level): child tickets + Type/Risk estimate + dependencies + epic-level Q&A, one confirm | any epic-level question unanswered | first unblocked child's spec/start |
| learning | locale + project brief/path | domain knowledge with provenance; opens a coaching ticket per unclear function purpose instead of blocking | unknown business facts | coaching (async, per ticket) or spec |
| coaching | existing knowledge + (explicit user correction or an answer to an open coaching ticket) | before/after delta, impacted consumers, changelog; self-closes the ticket when the answer doesn't conflict with recorded knowledge | unconfirmed delta/impact | spec or clarify |
| spec (G1) | G0 + ticket input | Type, Risk, AC/NEG/PERM/EDGE, UI oracle | missing type/risk/source; ambiguous requirement | clarify (self-chained) |
| clarify (G2/G5) | G1 + Type (preferred — self-classifies if absent) | type-specific evidence map, claims, Q&A | NO/UNCLEAR without decision | confirm |
| confirm (G3) | G2/G5 decisions visible | exact human phrase/provenance | missing/unauthorized/ambiguous decision | plan |
| plan (G4) | G3 (preferred — self-analyzes ticket if absent) | runnable task/DoD/test mapping | uncovered AC/claim; unresolvable command | build |
| build (G6) | G5 (preferred — calls plan, which self-analyzes, if absent) | per-task RED→GREEN evidence, code, coverage map, SHA | red test for wrong reason; scope drift; uncovered id | review |
| review (G7) | G6 + actual diff | independent findings + AC/side-effect evidence | no diff; OPEN P0/P1; missing evidence | fix or test |
| fix | OPEN findings | triage decision + narrow change + regression proof | unjustified decision; unresolved P0/P1 | review |
| test (G8) | G7 | executed-command ledger + raw/JUnit evidence + SHA | planned command not run; failure; stale evidence | check |
| check | requested minimum gate | deterministic PASS/FAIL/JSON result | any structural/provenance failure | owning stage |
| ship (G9) | G8 | deployment-profile safety/rollback plan | unsafe migration/rollout/rollback/ownership | audit |
| audit (AUDIT) | G9 strict | C1–C8 quotes, verdicts, reasoning, human sign-off | any missing/UNCLEAR/INCOHERENT pair | owning stage |
| status | workspace/ticket selector | read-only state, uncertainty, one next action | ambiguous selector/path | user clarification |
| clean | exact ticket + G9 or explicit force | archive receipt or confirmed purge receipt | broad target; unconfirmed purge | start/status |
| start | ticket + resolvable workspace | single deep-analysis pass, one collapsed stop for confirm, then continuous dispatch through the delivery pipeline (spec…check) — never dispatches learning/coaching itself, stops and tells the user to run them | epic-shaped request (routes to decompose); first genuine stop (P0/P1 finding, unresolved clarify claim, or ship/audit — always manual); G0 failure routes the user to learning/coaching, not an auto-dispatch | owning stage at the stop point, or ship |

## Ticket-type strategy dispatch

| Type | Required investigation |
|---|---|
| Bug | Reproduce → real execution path → root cause → sibling path only when same mechanism is evidenced |
| New feature | Closest analog → insertion points → constraints/contracts → negative integration effects |
| Spec change | Exact before/after → every consumer of changed behavior → signed side effects |
| Requirement change | Exact old/new rule → every encoding across code/config/copy/docs/repos → named authority |

Mixed tickets use claim-level Type. They must not use one strategy for all claims.

## Entry-point stages (outside the gate sequence)

`decompose` and `start` do not own a gate themselves (no `G0`…`G9`/`AUDIT`
row belongs to either) — they own **sequencing and stop-point count**, not
verdicts. Every gate they pass through still runs the owning stage's real
requirements from the table above; `check-gates.sh` does not know either
stage exists and does not need to. `decompose` runs before any child's
`spec`/`start`. `start` is the default way to walk `spec`→`check` (and hand
off to `ship`/`audit`) with as few user-visible stops as the ticket's Risk
allows — never a shortcut around what a stage requires. Calling a named
`/dev-workflow:<stage>` command directly instead of `start` remains valid for
manual, step-by-step control of one specific step. `references/risk.md`'s
P0/P1/P2 lanes govern `start`'s stop count exactly as they govern the manual
path; `start` does not introduce a fourth lane.
