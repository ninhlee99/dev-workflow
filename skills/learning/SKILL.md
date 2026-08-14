---
name: learning
description: >-
  AI self-learns any project from a brief: auto-creates workspaces/<project-slug>/,
  explores repos, promotes domain-knowledge; asks only when business unclear.
  Changed specs → :coaching.
argument-hint: "[project brief or path] — AI self-learns; auto-creates workspaces/<project-slug>/; asks only when business unclear"
arguments: [brief]
disable-model-invocation: true
---

# /dev-workflow:learning

Self-learn from brief and bootstrap workspace.
Read `references/project-root.md`, `references/learning.md`, `references/locale.md`, `references/workspace-health.md`.
Reply and ask `[LEARNING]` in **user language**.
Resolve/create `workspaces/<project-slug>/`; print `project=<slug> home=<path> locale=<code>`.
Explore repos, capture facts; promote to `domain-knowledge/` only after answers; update INDEX.
After create: run `bin/check-workspace.sh <slug>` — must PASS before later stages.

## What "captured enough" means (G0 DoD bar)

`business.md`/`architecture.md`/`glossary.md` need **real content**, not a filled-in template
skeleton — a heading with one vague sentence under it is not different from an empty file to a
reader who needs to act on it later.

**Bad** (technically non-empty, still useless): "This system handles jobs and companies."
**Good**: "Job posting belongs to a Company (1:many). A Company can have `plan: free|paid` —
paid unlocks unlimited postings; free caps at 3 active. `Job.status` is a state machine:
`draft → published → closed`, no skipping states, `closed` is terminal (see
`app/models/job.rb:12`)." — concrete enough that a later ticket's spec can cite it as fact
without re-reading the code.

Mark `Needs learning: no` only when the domain file actually reads like the second example, not
the first. Do not tick it to unblock G0 — G0's job is to catch exactly this shortcut.

Refuse hardcoded paths, invented business, and jumping to later stages.
