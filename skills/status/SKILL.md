---
name: status
description: >-
  Show domain-knowledge freshness, workspaces learning progress, and ticket
  worklog gates; suggest next /dev-workflow:* command.
argument-hint: "<Ticket ID?> Leave empty for domain-knowledge only; with ticket also show gate progress and next subcommand"
arguments: [ticket_id]
disable-model-invocation: false
---

# /dev-workflow:status

Apply `references/skill-quality.md`; status is read-only and separates structural, semantic, and human-final state.

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

Show concise knowledge and gate progress.
Read `references/workflow.md`, `references/project-root.md`, `references/locale.md`, `references/workspace-health.md`.
Reply in user language.
Without ticket: report domain freshness (see `bin/check-workspace.sh` W0–W6 checks — plugin dir,
PROJECT.md, domain-knowledge/INDEX.md, worklogs/ layout, stray files, per-ticket INDEX.md,
marker-slug consistency) + run its summary directly, do not re-derive by hand. Also list any
`domain-knowledge/coaching-tickets/*.md` with `Status: OPEN` (id + title) so the user can see
what's waiting on an answer — these are async and don't block anything, just surface them.
With ticket: report gate state from **that** worklog INDEX only (`task-isolation.md`); suggest
`:clean` if G9 PASS and user wants to free memory — `:clean` only needs G9, not `:audit`.
No code changes; keep default output short.
Report G9 structural, AUDIT semantic, and human sign-off separately. Run the checker when possible;
never infer PASS from a checkbox alone. Include uncertainty and exactly one next command.
