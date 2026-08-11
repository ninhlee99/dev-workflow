---
name: plan
description: >-
  Break confirmed spec+conflict decisions into small tasks with DoD/tests.
  Use /dev-workflow:plan only after conflict claims are fully confirmed.
argument-hint: "<Ticket ID> Run only after spec and conflict pass — write a TDD-ready implementation plan into the worklog"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:plan

Create implementation plan from confirmed scope only.
Fill `templates/04-plan.md` for the ticket.
Each task must map to AC/claim, target repo/path, DoD, and test command.
Print uncovered AC/claim gaps; gaps block next stage.
Do not enter build here and do not invent tasks beyond confirmed decisions.
