# 06c Fix log: [Feature_Name]

- **Date:** [YYYY-MM-DD]
- **Ticket:** [Ticket_ID]
- **Operator:** [name/AI]
- **Source review:** `06-review-qa.md` (Code review findings)

## Triage

For each OPEN finding from review. Status after triage: `FIX` | `SKIP` | `DEFER`.

| ID | Sev | Class | Location | Decision | Why (1 line) |
|---|---|---|---|---|---|
| R-01 | P0/P1/P2 | 500/missing/injection/case/other | path:line | FIX / SKIP / DEFER | |

### Decision rules

- **FIX** — defect real in diff; matches AC/claim/security; fix in scope of ticket.
- **SKIP** — style-only, speculative (no evidence), contradicts confirmed claim/AC, wrong for this stack/convention, or out of ticket scope.
- **DEFER** — real but P2 / follow-up ticket; note owner + ticket id if any.

**Forbid:** SKIP a P0 without PM note on INDEX.  
**Forbid:** FIX drive-by unrelated files “while here”.

## Changes applied

| ID | Files | What changed | Test / proof |
|---|---|---|---|
| R-01 | | | |

## Skipped (keep for audit)

| ID | Reason | Follow-up? |
|---|---|---|
| | | ☐ none ☐ ticket … |

## Result

☐ All FIX items done + related tests green  
☐ Blocked — list remaining P0/P1  

**Next:** re-check review findings → `/dev-workflow:review` (update Status) → `/dev-workflow:test` when P0/P1 clear.
