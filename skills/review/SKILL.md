---
name: review
description: >-
  Neutral code review of the diff for 500/missing/injection/case defects,
  then fill AC How/By evidence. Use /dev-workflow:fix when P0/P1 stay OPEN.
argument-hint: "<Ticket ID> After build — review diff + fill 06-review-qa.md evidence"
arguments: [ticket_id]
disable-model-invocation: false
---

# /dev-workflow:review

Apply `references/skill-quality.md`; independence means re-deriving conclusions from the diff and contracts.

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

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

   If the diff touches code with a finding already `DEFERRED` on a **different** ticket's
   `06c-fix-log.md` for the same defect, do not re-raise it here as a new finding — note in this
   ticket's evidence that it was seen and is already tracked there. "Touches code" here means the
   DEFERRED finding's own function/method body is part of this diff — not merely a nearby line in
   the same file (an adjacent export, an import, a sibling function). A diff that edits code next
   to, but not inside, the deferred function is a genuinely different change; review it fresh. A
   cross-ticket DEFERRED item is already-known signal, not new; re-raising it on every ticket that
   happens to touch the same file is noise, not diligence. (This differs from `fix/SKILL.md`'s
   same-pass SKIP rule for a duplicate
   *within* one review — this is about carrying a decision across tickets.)

   Also invoke the `code-review` skill (medium/high effort) on the same diff for broader
   reuse/simplification/efficiency coverage on top of the required class hunt above — it does not
   replace the class hunt. Fold any correctness findings it surfaces into the class rows
   below; quality-only findings stay out of the Sev/Class table.
4. Write findings into `templates/06-review-qa.md` Code review tables (Sev, Class, Location, Evidence, Risk, Fix proposal, Status=`OPEN`).
5. Fill AC/NEG/PERM/EDGE How/By/Date evidence (+ UI checklist if Touches UI = Yes).
6. Re-check clarify decisions still hold after impl.
7. Run `/dev-workflow:check <Ticket> [slug] G7` before any G7 PASS claim.

## Result rules

- Any P0/P1 finding still `OPEN` → Result **FAIL** → next `/dev-workflow:fix <Ticket>`
  (`check-gates.sh` G7 verifies this by reading Sev/Status columns directly — do not rely on
  self-discipline alone, the checker will catch a P0 left OPEN under a hand-written PASS line)
- Missing How/By on any AC row, or empty UI checklist when UI=Yes → **FAIL**
- Never invent PASS; never ship from this stage alone
- P2-only findings may proceed to `:test` if evidence complete (list P2 as follow-ups)

## Forbid

- Guessing bugs without opening the changed code
- Style-only blockers
- “LGTM” with empty finding table and empty class checklist

## 9/10 controls

Expand `other` when applicable: concurrency/idempotency, transaction/atomicity,
compatibility/migration, cache/event invalidation, retry, privacy/observability, and resource bounds.
Re-check changed public contracts and side effects. Uncertain runtime behavior is `UNCLEAR`, not a
finding, until a local definition or runtime path proves it.
