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
3) explore repos, write facts only, and tag unclear items as `[LEARNING]`.
4) promote to `domain-knowledge/` and INDEX only after answers.

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

Exit: `PROJECT.md` + business/architecture/glossary + domain files for explored repos, no open learning questions.
Refuse: hardcoded paths, invented business, jumping to build/spec. Spec changes after learning use `:coaching`.
