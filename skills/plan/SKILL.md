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

## Precondition

Run `/dev-workflow:check <Ticket> [slug] G3` first. If it FAILs, stop — scope isn't confirmed yet
(no `CONFIRM G3:` phrase, or a conflict claim still open). Planning against unconfirmed scope
produces tasks that get thrown away the moment `:confirm` lands on a different decision — route
the user to `:conflict`/`:confirm` instead of drafting a plan you already know is provisional.

## Steps

Create implementation plan from confirmed scope only.
Fill `templates/04-plan.md` for the ticket.
Each task must map to AC/claim, target repo/path, DoD, and test command.

**Test command must be a real, runnable command** — `bundle exec rspec spec/operations/companies/job_delete_spec.rb`,
not "add tests for this". `check-gates.sh` G4 only verifies the column isn't blank, not that the
command is real; that gap is yours to close as the plan's author, not the checker's — a plan task
with a fake-sounding command passes the machine gate and still leaves `:build` with nothing
concrete to run.

Print uncovered AC/claim gaps; gaps block next stage.
Do not enter build here and do not invent tasks beyond confirmed decisions.
