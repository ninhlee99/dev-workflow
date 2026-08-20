# 08 Semantic audit: [Feature_Name]

- **Precondition:** `check-gates.sh --min G9 --strict` exit 0 ☐
- **Ticket:** [ID]

Read `references/audit.md` before filling this. Every pair below requires **quoted evidence from
both sides** — a verdict without both quotes is not evidence.

## Coherence pairs

Every pair's Verdict and REASON live in the bullet lines below its table, never in a table column
— a pair block has exactly one place to answer, not two.

### C1 — Conflict claim Proposal ↔ Decision

| claim_id | Proposal (quoted) | Decision (quoted) |
|---|---|---|
| C-01 | | |

- **VERDICT:** ☐ COHERENT ☐ INCOHERENT ☐ UNCLEAR ☐ N/A
- **REASON:** …

### C2 — Plan task AC/claim ↔ DoD/test command

| Task # | AC/claim | DoD/test command (quoted) |
|---|---|---|
| 1 | | |

- **VERDICT:** ☐ COHERENT ☐ INCOHERENT ☐ UNCLEAR ☐ N/A
- **REASON:** …

### C3 — Impl-log Coverage PASS ↔ AC text

| AC | Test path (quoted) | AC text (quoted) |
|---|---|---|
| AC-01 | | |

- **VERDICT:** ☐ COHERENT ☐ INCOHERENT ☐ UNCLEAR ☐ N/A
- **REASON:** …

### C4 — Review "How verified" ↔ AC Given/When/Then

| AC | How verified (quoted) | Given/When/Then (quoted) |
|---|---|---|
| AC-01 | | |

- **VERDICT:** ☐ COHERENT ☐ INCOHERENT ☐ UNCLEAR ☐ N/A
- **REASON:** …

### C5 — Ship Migration ↔ Rollback

- **Migration says (quoted):** "…"
- **Rollback says (quoted):** "…"
- **VERDICT:** ☐ COHERENT ☐ INCOHERENT ☐ UNCLEAR ☐ N/A (no migration)
- **REASON:** …

### C6 — Ship Feature flag ↔ Rollout plan

- **Flag says (quoted):** "…"
- **Rollout plan says (quoted):** "…"
- **VERDICT:** ☐ COHERENT ☐ INCOHERENT ☐ UNCLEAR ☐ N/A (no flag)
- **REASON:** …

### C7 — Conflict side-effects ↔ Review Side effects checklist

| Side effect (from clarify report) | Review Side effects status |
|---|---|
| | |

- **VERDICT:** ☐ COHERENT ☐ INCOHERENT ☐ UNCLEAR ☐ N/A
- **REASON:** …

### C8 — Fix-log Decision ↔ Review finding Class/Location

`check-gates.sh` G7 only verifies a `06c-fix-log.md` row exists for every triaged finding —
not that the Decision actually addresses what the finding described. Check that here.

| Finding ID | Finding Class/Location (quoted) | Fix-log Decision + "Changes applied" (quoted) |
|---|---|---|
| R-01 | | |

- **VERDICT:** ☐ COHERENT ☐ INCOHERENT ☐ UNCLEAR ☐ N/A (no findings triaged)
- **REASON:** …

## Summary

- Total pairs: [n]
- COHERENT: [n]
- INCOHERENT: [n] — must route back to owning stage before ship is final
- N/A: [n] (with reason on each row)

**Gate: ship is not final while any pair is INCOHERENT or UNCLEAR without a logged decision.**

## Routing (if any INCOHERENT)

| Pair | Route back to | Reason for routing |
|---|---|---|
| | `:clarify` / `:plan` / `:build` / `:review` / `:ship` | |

## Sign-off (required — AI verdict alone is not final)

Paste the exact user message below (do not invent):

```
AUDIT CONFIRM: …
```

- **Forbidden names:** AI, ChatGPT, Claude, Copilot, Cursor, Assistant, Bot

## Result

☐ PASS — all pairs COHERENT or N/A **and** human `AUDIT CONFIRM:` recorded, ship is final
☐ FAIL — INCOHERENT pair(s) open (see Routing) or sign-off missing
