---
name: build
description: >-
  TDD then implement only after coaching/spec/conflict/confirm/plan gates pass.
  Use /dev-workflow:build. Refuses production code if gates fail.
argument-hint: "<Ticket ID> Run only after plan pass — implement with TDD and log claim↔test mapping in the worklog"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:build

## Precondition (check before writing a single line of production code)

A Senior dev handed a ticket checks the spec is confirmed before opening an editor — do the same
here, don't wait until claiming G6 PASS to discover G4/G5 never passed:

1. Run `/dev-workflow:check <Ticket> [slug] G5` — if it FAILs, stop. There is nothing to build:
   either the plan doesn't exist (G4) or a conflict claim is still unconfirmed (G2/G5). Route the
   user to `:plan` or `:conflict`/`:confirm`, do not start coding "to make progress" while scope
   is still unsettled.
2. Only once G5 PASSes does this stage's own work begin.

## Steps

Implement only after prior gates pass (through G4 plan / G5 open-Q clear).
Read `references/task-isolation.md` — log **only** into `worklogs/<Ticket_ID>/` for this ticket.
Print `project=… ticket=… worklog=… locale=…` at start; refuse empty ticket.
Use TDD and log AC/claim-to-test mapping in `templates/05-impl-log.md` under **this** worklog.
Fill **Commit SHA** at the top of `05-impl-log.md` with the real commit the PASS claim is made
against — required for P0/P1/`--strict`, same bar as G8's test evidence. A PASS recorded with no
SHA, or against a stale one, is not verifiable evidence.
Do not edit another ticket’s impl log or reuse its PASS marks.
Run `/dev-workflow:check <Ticket> [slug] G6` before any G6 PASS claim.
Coverage gaps, failing tests, or missing/stale Commit SHA keep build FAIL.
Never invent PASS; refuse coding when prerequisite gates fail.
Chat in user language (`references/locale.md`).
