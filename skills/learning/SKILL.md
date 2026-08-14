---
name: learning
description: >-
  AI self-learns any project from a brief: auto-creates workspaces/<project-slug>/,
  explores repos, promotes domain-knowledge; asks only when business unclear.
  Changed specs → :coaching.
argument-hint: "[project brief or path] — AI self-learns; auto-creates workspaces/<project-slug>/; asks only when business unclear"
arguments: [brief]
disable-model-invocation: false
---

# /dev-workflow:learning

Apply `references/skill-quality.md`; this stage owns provenance-backed knowledge, not confident-looking summaries.

Self-learn from brief and bootstrap workspace.
Read `references/project-root.md`, `references/learning.md`, `references/locale.md`, `references/workspace-health.md`.
If this is the first `/dev-workflow:*` command in this workspace (`domain-knowledge/INDEX.md`
missing or its `Chat locale` field unset), ask `[LOCALE]` per `references/locale.md` **before**
anything else — before creating the workspace, before the `[LEARNING]` business questions below.
Reply and ask `[LEARNING]` in **user language**.
Resolve/create `workspaces/<project-slug>/`; print `project=<slug> home=<path> locale=<code>`.
Slug = real repo/org name, not a name invented from the brief's feature wording (see
`references/learning.md` § Choosing the slug); use the user's explicit slug if they gave one, and
reuse an existing workspace whose `PROJECT.md` already lists the same repo(s) instead of creating
a new feature-named one.
Explore repos, capture facts; promote to `domain-knowledge/` only after answers; update INDEX.
For every promoted material fact, record truth label, `path:line`/source, verified date, and confidence.
List areas deliberately not explored; do not imply project-wide completeness from a targeted pass.
After create: run `bin/check-workspace.sh <slug>` — must PASS before later stages.

Read `references/learning.md` fully before exploring — it defines the "captured enough" DoD bar
(Bad vs Good example) and the target-driven exploration rule (follow real entrypoints, don't
full-read the repo). Do not tick `Needs learning: no` without meeting that bar.

Refuse hardcoded paths, invented business, and jumping to later stages.
