---
name: fix
description: >-
  Triage review findings then fix only justified defects. Skip style,
  out-of-scope, or suggestions that contradict AC/system. Log in 06c-fix-log.md.
argument-hint: "<Ticket ID> After review FAIL — triage OPEN findings; fix only FIX decisions"
arguments: [ticket_id]
disable-model-invocation: false
---

# /dev-workflow:fix

Apply `references/skill-quality.md`; every triage decision needs current evidence and an accountable owner.

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

Remediate code-review findings without cargo-cult patching.

## When

After `:review` left P0/P1 findings `OPEN` (or human asked to clear review comments).
Not a gate by itself — clears blockers so G7/G8 can PASS. `check-gates.sh` G7 verifies both that
no P0/P1 stays `OPEN` **and** that `06c-fix-log.md` exists with a matching row for every finding
you moved off `OPEN` — flipping a Status cell to `FIXED` without actually filling the fix-log
will still fail G7, not silently pass.

## Steps

1. Load `references/code-review.md` + worklog `06-review-qa.md` Code review table.
2. Copy `templates/06c-fix-log.md` → worklog `06c-fix-log.md` if missing.
3. **Triage every OPEN finding** before editing code:
   - Read cited `path:line` and surrounding call sites.
   - Decide `FIX` / `SKIP` / `DEFER` using rules in template + below.
4. Apply **only** `FIX` items. Prefer smallest change that removes the defect.
5. Add/adjust test when defect class is `500` / `missing` / `injection` / `case` and no covering test exists.
6. Update `06-review-qa.md`: set finding Status to `FIXED` / `SKIPPED` / `DEFERRED` + link to fix-log row.
7. Update `05-impl-log.md` if coverage map gains tests.
8. Print: fixed count / skipped count / remaining P0/P1 → next command (`:review` or `:test`).

## Triage rules (strict)

**FIX when all true:**
- Evidence still visible in current code (not already fixed)
- User/security/data risk is concrete
- In scope of ticket AC, confirmed claims, or P0 security bar
- Proposed fix matches this repo’s patterns (open neighbors; do not invent foreign idioms)

**SKIP when any true:**
- Style / rename / taste only
- Speculative (“might fail if…”) with no path in diff or tests
- Contradicts `02-spec` AC or G3-confirmed claim
- Wrong for system (e.g. suggests downcase when product requires case-preserve)
- Touches unrelated module; belongs in other ticket
- Duplicate of another finding

**DEFER when:** real P2 hardening, explicit follow-up owned, not ship-blocking.

**Never SKIP P0** without INDEX waiver + PM note.

## Anti-patterns

- Fix everything in the comment thread “to be safe”
- Rewrite large modules while fixing one nil check
- Invent PASS on review/test after partial fix
- Change AC/spec silently to make finding go away (use `:coaching` / `:clarify` instead)

## Done means

- `06c-fix-log.md` triage complete for every former OPEN finding
- Remaining OPEN P0/P1 = 0 (or WAIVE documented)
- Next: `/dev-workflow:review <Ticket>` to refresh evidence, then `:test`

## 9/10 controls

For P0/P1 FIX, first add or identify a reproduction that fails for the stated mechanism and log
RED→GREEN. If executable reproduction is impossible, document why and require equivalent proof.
SKIP/DEFER requires evidence, owner, expiry/follow-up id, and impact; otherwise it remains OPEN.
