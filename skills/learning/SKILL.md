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
Refuse hardcoded paths, invented business, and jumping to later stages.
