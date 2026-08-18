---
name: coaching
description: >-
  User coaches AI on new/changed business, corrects wrong understanding, or answers
  a coaching ticket :learning opened. Updates domain-knowledge + changelog.
  Bootstrap empty system → :learning.
argument-hint: "<topic or coaching-ticket id> [answer text] — teach/correct AI, or answer an open coaching ticket"
arguments: [topic_or_ticket_id, answer_text]
disable-model-invocation: false
---

# /dev-workflow:coaching

Apply `references/skill-quality.md`; this stage owns a confirmed knowledge delta and its impact list.

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

Use when user corrects or changes business rules, or answers a coaching ticket `:learning` opened.
Read `references/project-root.md` and `references/coaching.md` (defines Path A — ticket answer —
and Path B — freeform correction; dispatch on whether the first argument resolves to an existing
`domain-knowledge/coaching-tickets/<NNN>-*.md` with `Status: OPEN`).

**Path A (ticket answer):** follow `coaching.md`'s Path A steps — append the answer, re-investigate
using it as a lead, then either follow up (still unclear), self-close (understood, no conflict), or
fall through to the diff-don't-overwrite step below (understood, but conflicts).

**"No conflict" is a claim you have to earn, not a default.** Before self-closing, explicitly
search the files a contradiction would actually live in: the ticket's `Target` file
(`domains/*.md` or `business.md`), `business.md` itself if `Target` is a different domain file (a
cross-cutting rule often lives in both), and `glossary.md` for the same term under a different
name. Record what you searched in the ticket's `Resolution` → `Conflict check:` line —
`none found — searched business.md:1-80, domains/billing.md (no match)`, not a bare `none found`
with no trail. A `Conflict check` with no searched-files list is not a completed check; treat it as
still unclear and fall through to the diff-don't-overwrite step rather than self-closing on it.

**Path B (freeform):** resolve workspace, diff current knowledge vs new guidance, and ask
`[COACHING]` for unclear points. Write `domain-knowledge/` and `changelog.md` only after explicit
confirm. Before confirmation, search direct consumers of the old rule (active specs/worklogs,
tests, config, copy) and present location, old assumption, follow-up, and owner. Never silently
edit active ticket decisions; route them back to `:spec`/`:clarify`.

If knowledge is empty, route to `:learning`.

## Diff, don't overwrite

Applies to **both paths**, every time a write would change a fact that's already recorded — this
is the one rule Path A's self-close does not skip. Coaching corrects or extends knowledge that
(mostly) already exists — this is different from `:learning`'s from-scratch bootstrap. Show the
user the actual before/after, not just the new text:

```
Current (business.md:14): "Free plan caps job postings at 3."
User says: "Free plan caps at 5 now, changed last sprint."
Proposed change: business.md:14 → "Free plan caps job postings at 5 (changed 2026-08, was 3)."
Also update: changelog.md (new row), any spec/worklog citing the old "3" limit as still-open?
```

Keeping the old value visible with a changelog trail is what makes `domain-knowledge/` trustworthy
over time — a silent overwrite means nobody can tell later whether "5" was always true or the
correction happened last week and some code/tests still assume "3". On Path A this means: a ticket
answer that only *adds* a fact no one recorded before may self-close and write immediately; a
ticket answer that *changes* a fact already in `domains/*.md`/`business.md` always stops here and
waits for explicit user confirm, exactly like Path B — no ticket answer bypasses this by virtue of
having come from the user, because the contradiction itself hasn't been surfaced to them yet.

Refuse invented rules and unconfirmed writes — on Path A that means never resolving a follow-up
`Q<n>` by guessing, and never self-closing over a detected conflict.
