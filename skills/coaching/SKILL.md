---
name: coaching
description: >-
  User coaches AI on new/changed business or corrects wrong understanding.
  Updates domain-knowledge + changelog. Bootstrap empty system → :learning.
argument-hint: "<topic or ticket?> User teaches new/changed business or corrects AI misunderstanding"
arguments: [topic]
disable-model-invocation: true
---

# /dev-workflow:coaching

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

Use when user corrects or changes business rules.
Read `references/project-root.md` and `references/coaching.md`.
Resolve workspace, diff current knowledge vs new guidance, and ask `[COACHING]` for unclear points.
Write `domain-knowledge/` and `changelog.md` only after explicit confirm.
If knowledge is empty, route to `:learning`.

## Diff, don't overwrite

Coaching corrects or extends knowledge that (mostly) already exists — this is different from
`:learning`'s from-scratch bootstrap. Show the user the actual before/after, not just the new
text:

```
Current (business.md:14): "Free plan caps job postings at 3."
User says: "Free plan caps at 5 now, changed last sprint."
Proposed change: business.md:14 → "Free plan caps job postings at 5 (changed 2026-08, was 3)."
Also update: changelog.md (new row), any spec/worklog citing the old "3" limit as still-open?
```

Keeping the old value visible with a changelog trail is what makes `domain-knowledge/` trustworthy
over time — a silent overwrite means nobody can tell later whether "5" was always true or the
correction happened last week and some code/tests still assume "3".

Refuse invented rules and unconfirmed writes.
