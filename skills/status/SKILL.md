---
name: status
description: >-
  Show domain-knowledge freshness, workspaces learning progress, and ticket
  worklog gates; suggest next /dev-workflow:* command.
argument-hint: "<Ticket ID?> Leave empty for domain-knowledge only; with ticket also show gate progress and next subcommand"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:status

Show concise knowledge and gate progress.
Read `references/workflow.md`, `references/project-root.md`, `references/locale.md`, `references/workspace-health.md`.
Reply in user language.
Without ticket: report domain freshness (see `bin/check-workspace.sh` W0–W6 checks — plugin dir,
PROJECT.md, domain-knowledge/INDEX.md, worklogs/ layout, stray files, per-ticket INDEX.md,
marker-slug consistency) + run its summary directly, do not re-derive by hand.
With ticket: report gate state from **that** worklog INDEX only (`task-isolation.md`); suggest
`:clean` if G9 PASS and user wants to free memory — `:clean` only needs G9, not `:audit`.
No code changes; keep default output short.
