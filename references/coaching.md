# Coaching

Use when user teaches new/changed business, fixes wrong AI understanding, or answers a coaching
ticket `:learning` opened. Do not use for first-time bootstrap; use `:learning` then.

Two entry paths — dispatch on the argument:

## Path A — answering a coaching ticket

`/dev-workflow:coaching <ticket-id> <answer text>` where `<ticket-id>` resolves to an existing
`domain-knowledge/coaching-tickets/<NNN>-*.md` with `Status: OPEN`.

1. Append the answer to the ticket's Thread as the next `A<n>`.
2. Re-investigate using the answer as a lead: re-read the code cited in the ticket, trace
   callers/consumers, check related `domain-knowledge/` — same target-driven discipline as
   `references/learning.md`'s exploration rule (follow the lead, don't full-repo-read).
3. Decide:
   - **Still unclear** → append a sharper `Q<n+1>` follow-up to Thread, keep `Status: OPEN`, stop
     and wait for the next answer. Never guess past this point.
   - **Understood, and it doesn't contradict existing domain-knowledge** → the AI may close the
     ticket in this same turn — but "doesn't contradict" must be an *earned* conclusion, not a
     default: explicitly search the ticket's `Target` file, `business.md` if `Target` is a
     different domain file, and `glossary.md` for the same concept under another name, and record
     exactly what was searched in `Resolution` → `Conflict check:` (see
     `templates/domain-knowledge/coaching-ticket.md`). A `Conflict check` with no searched-files
     list is not complete — treat the claim as still open and fall through to "Diff, don't
     overwrite" instead of self-closing on it. Once the search is recorded and genuinely clean:
     write the fact to the ticket's `Target` file, fill `Resolution`, flip `Status: CLOSED`, add a
     `changelog.md` row citing the ticket id as source. No separate user confirm phrase is required
     here — the user already supplied the fact via the answer; what's auto-confirmed is only "this
     answer was understood correctly and doesn't conflict," not an invented rule.
   - **Understood, but it contradicts an existing recorded fact** → do **not** write yet. Run
     "Diff, don't overwrite" below first; only close the ticket after the user confirms the
     correction.

## Path B — freeform correction (not from a ticket)

Use when user proactively teaches or corrects something with no open ticket behind it.

1) resolve workspace via `project-root.md`.
2) compare current knowledge vs new correction.
3) ask `[COACHING]` for unclear points.
4) write `domain-knowledge/` and `changelog.md` only after explicit confirm.
5) if tied to a ticket, record scope and impact in worklog.

Refuse: system bootstrap here, invented rules, writing updates before confirm (Path B) or before
either a non-conflicting understood answer or explicit confirm on a conflict (Path A).
