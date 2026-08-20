---
name: learning
description: >-
  AI self-learns any project from a brief: auto-creates workspaces/<project-slug>/,
  explores repos, promotes domain-knowledge; opens a coaching ticket per unclear
  business function instead of blocking on inline questions. Changed specs → :coaching.
argument-hint: "[project brief or path] — AI self-learns; auto-creates workspaces/<project-slug>/; opens coaching tickets for unclear function purposes"
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
Fill `PROJECT.md` from `templates/workspaces/_project/PROJECT.md`'s exact structure (`Slug:` field
included) — do not improvise the field layout, `bin/check-workspace.sh`'s W1 check expects that
literal shape.
Explore repos, capture facts; promote to `domain-knowledge/` only after answers; update INDEX.
For every promoted material fact, record truth label, `path:line`/source, verified date, and confidence.
List areas deliberately not explored; do not imply project-wide completeness from a targeted pass.
After create: run `bin/check-workspace.sh <slug>` — must PASS before later stages.

Read `references/learning.md` fully before exploring — it defines the "captured enough" DoD bar
(Bad vs Good example), the target-driven exploration rule (follow real entrypoints, don't
full-read the repo), and the **"Ticket vs inline"** routing rule for unclear items. Do not tick
`Needs learning: no` without meeting that bar.

## When a function's business purpose is unclear

Do not stop the pass to ask inline — per `references/learning.md`'s "Ticket vs inline" section,
open a coaching ticket (copy `templates/domain-knowledge/coaching-ticket.md` into
`domain-knowledge/coaching-tickets/<NNN>-<slug>.md`, cite the exact `file:line`) and keep exploring
the rest of the scope. Reserve inline `[LEARNING]` questions for structural/navigational blockers
only (which repo/slug, which of two same-named services is live) — anything that's actually about
*why* the code behaves this way goes to a ticket, not the inline prompt. Report opened ticket paths
at the end of the pass; they don't block `Exit` (see `learning.md`), they're answered async via
`/dev-workflow:coaching <ticket-id> <answer>`.

Refuse hardcoded paths, invented business, and jumping to later stages.
