---
name: review
description: >-
  Neutral code review of the diff for 500/missing/injection/case defects,
  then fill AC How/By evidence. Use /dev-workflow:fix when P0/P1 stay OPEN.
argument-hint: "<Ticket ID> After build — review diff + fill 06-review-qa.md evidence"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:review

Verify implementation against requirements **and** review the actual code change (G7).

## Stance

Act as a **neutral human reviewer**, not the author.
Read `references/code-review.md` first.
Judge from the **diff + call sites**, not from guessed framework syntax or “usual” patterns.
Every finding needs `path:line` (or hunk) + concrete fix proposal.

## Steps

1. Resolve worklog; open `02-spec.md`, `05-impl-log.md`, confirmed claims, INDEX Risk.
2. Collect change set (`git diff` base…HEAD or files listed in impl log). No diff → FAIL review; do not invent.
3. Hunt defect classes per `code-review.md`: **500**, **missing**, **injection**, **case** (downcase/upcase/normalize), **other**. Fill class rows even if `none`.
4. Write findings into `templates/06-review-qa.md` Code review tables (Sev, Class, Location, Evidence, Risk, Fix proposal, Status=`OPEN`).
5. Fill AC/NEG/PERM/EDGE How/By/Date evidence (+ UI checklist if Touches UI = Yes).
6. Re-check conflict decisions still hold after impl.
7. Run `/dev-workflow:check <Ticket> [slug] G7` before any G7 PASS claim.

## Result rules

- Any P0/P1 finding still `OPEN` → Result **FAIL** → next `/dev-workflow:fix <Ticket>`
- Missing How/By on any AC row, or empty UI checklist when UI=Yes → **FAIL**
- Never invent PASS; never ship from this stage alone
- P2-only findings may proceed to `:test` if evidence complete (list P2 as follow-ups)

## Forbid

- Guessing bugs without opening the changed code
- Style-only blockers
- “LGTM” with empty finding table and empty class checklist
