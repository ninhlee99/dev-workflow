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
Without ticket: report domain freshness + run `bin/check-workspace.sh` summary.
With ticket: report gate state from **that** worklog INDEX only (`task-isolation.md`); suggest `:clean` if G9 PASS and user wants to free memory.
No code changes; keep default output short.
