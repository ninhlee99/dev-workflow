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
Read `references/workflow.md` and resolve workspace via `references/project-root.md`.
Without ticket: report domain freshness and open learning/coaching questions.
With ticket: report gate state from worklog INDEX and next command.
No code changes; keep default output short.
