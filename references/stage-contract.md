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
| start | ticket + resolvable workspace | preflight + dispatch only, delivery pipeline (spec…audit) — never dispatches learning/coaching itself, stops and tells the user to run them | first failing prerequisite in the delivery pipeline; G0 failure routes the user to learning/coaching, not an auto-dispatch | owning stage |

## Ticket-type strategy dispatch

| Type | Required investigation |
|---|---|
| Bug | Reproduce → real execution path → root cause → sibling path only when same mechanism is evidenced |
| New feature | Closest analog → insertion points → constraints/contracts → negative integration effects |
| Spec change | Exact before/after → every consumer of changed behavior → signed side effects |
| Requirement change | Exact old/new rule → every encoding across code/config/copy/docs/repos → named authority |

Mixed tickets use claim-level Type. They must not use one strategy for all claims.
