# Learning

Use when workspace knowledge is empty or missing for ticket scope.

Input brief should include project name, domain, repo map, and learning goal.

Do:
1) resolve path via `project-root.md`; print `project=<slug> home=<path>`.
2) create `workspaces/<slug>/` when missing; seed base files.

## Choosing the slug

Default slug = the real repo/org name (git remote or top-level dir name), slugified — never a
name invented from the brief's feature description. A brief about "job search keyword bugs"
does not make the slug `<project>-jobsearch`; the repo is still `daijob5`/`daijob6_api`, so the
slug is `daijob` (or whatever the actual repo/product is called). One product spanning several
repos (e.g. `daijob5` + `daijob6_api` + `daijob6_companytools`) shares one slug and one workspace
— do not split by feature area into separate slugs.

If the user explicitly names a slug ("call it X", "put it under Y"), use exactly what they said —
explicit user instruction overrides the repo-name default.

If an existing `~/.workspaces/<slug>/PROJECT.md` already lists the repo(s) in play, reuse that
slug; do not create a second, feature-named workspace for the same repos.
3) explore repos, write facts only, and route unclear items per "Ticket vs inline" below.
4) promote to `domain-knowledge/` and INDEX only after answers.

## Ticket vs inline — where an unclear item goes

Two different kinds of "I don't know" come up during learning; they route differently:

- **Structural/navigational** (needed to keep learning itself moving — "which repo is
  this slug", "which of these two similarly-named services is the live one") → ask
  `[LEARNING]` inline, same turn, as before. These block the pass; there's nothing
  useful to explore until they're answered.
- **Business purpose of a function/flow** (code is readable, but *why* it does what it
  does — the business rule behind it — can't be determined from code + existing
  `domain-knowledge/` alone) → **open a coaching ticket** instead of asking inline.
  Copy `templates/domain-knowledge/coaching-ticket.md` to
  `domain-knowledge/coaching-tickets/<NNN>-<slug>.md` (`NNN` = next unused sequence
  number in that directory), fill `Opened`/`Target`/the `Q1` question citing the exact
  `file:line` that's unclear, and **keep exploring the rest of the scope** — one
  unclear function does not stall the whole pass. At the end of the pass, report the
  opened ticket paths so the user knows what's waiting, and answer them whenever
  (async) via `/dev-workflow:coaching <ticket-id> <answer>`.

Do not open a ticket for something a few more minutes of code reading would resolve —
tickets are for genuine business-intent gaps, not a shortcut around exploration effort.

## Explore with a target, not a full read

"Explore repos" (step 3) does not mean reading every file. Start from the concrete entrypoints
that define how the system actually works — routes file, top-level models list, main
controllers/services directories — and follow what they actually reference. Do not open files on
the theory that they "might be relevant" without a route/reference pointing at them first; a
repo-wide read produces a domain-knowledge file padded with guesses, which is worse than a shorter
file that only states what was actually confirmed.

## What "captured enough" means (G0 DoD bar — do not tick early)

`business.md` / `architecture.md` / `glossary.md` need **real content**, not a filled-in template
skeleton — a heading with one vague sentence under it is not meaningfully different from an empty
file to a reader who needs to act on it later.

**Bad** (technically non-empty, still useless): "This system handles jobs and companies."
**Good**: "Job posting belongs to a Company (1:many). A Company can have `plan: free|paid` — paid
unlocks unlimited postings; free caps at 3 active. `Job.status` is a state machine:
`draft → published → closed`, no skipping states, `closed` is terminal (see `app/models/job.rb:12`)."
— concrete enough that a later ticket's spec can cite it as fact without re-reading the code.

Mark `Needs learning: no` only when the domain file actually reads like the second example, not
the first. Do not tick it to unblock G0 — G0's job is to catch exactly this shortcut. If a section
of `business.md`/`architecture.md` still reads like the first example after this pass, leave it
marked unconfirmed rather than writing something that merely fills the space.

Exit: `PROJECT.md` + business/architecture/glossary + domain files for explored repos, no open
inline `[LEARNING]` (structural) questions. Open coaching tickets do **not** block exit — they're
answered async via `:coaching`; report their paths and move on.
Refuse: hardcoded paths, invented business, jumping to build/spec. Spec changes after learning use `:coaching`.

## Fixing a stale fact you happen to pass through

This stage's scope is capturing knowledge for the **current** target, not auditing everything
previously confirmed. If a later `:learning` pass opens a domain file for its own target and
notices an already-"confirmed" line that's now stale (a prior fact contradicted by what this pass
just found), fixing that one line opportunistically — while already there for another reason — is
in scope; treat it like `:coaching` would (state before/after, why). Do not go looking for
staleness across files the current target gives no reason to open — that's a proactive full
re-audit, which is `:coaching`'s job when the user asks for it, not something `:learning` does on
its own initiative.
