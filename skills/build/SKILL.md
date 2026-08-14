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

0. If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per
   `references/locale.md` before anything else.
1. Run `/dev-workflow:check <Ticket> [slug] G5` — if it FAILs, stop. There is nothing to build:
   either the plan doesn't exist (G4) or a conflict claim is still unconfirmed (G2/G5). Route the
   user to `:plan` or `:conflict`/`:confirm`, do not start coding "to make progress" while scope
   is still unsettled.
2. Only once G5 PASSes does this stage's own work begin.

## Steps

Implement only after prior gates pass (through G4 plan / G5 open-Q clear).
Read `references/task-isolation.md` — log **only** into `worklogs/<Ticket_ID>/` for this ticket.
Print `project=… ticket=… worklog=… locale=…` at start; refuse empty ticket.

**Use TDD (required, regardless of what's installed).** Per task in `04-plan.md`: write the
failing test from that task's test command first, run it and confirm it fails for the stated
reason (not a setup/syntax error), then implement the minimum to make it pass. This cycle applies
whether or not any other skill is present in the session — do not skip or water it down on a repo
that lacks extra tooling. Log AC/claim-to-test mapping in `templates/05-impl-log.md` under **this**
worklog.

Optional enhancement: if a `tdd` or `test-driven-development` skill is also available in this
session, invoke it for a more thorough red-green-refactor treatment (refactor-phase discipline,
project-specific test patterns) on top of the required cycle above — never as a substitute for it,
and its absence changes nothing about the required steps.
Fill **Commit SHA** at the top of `05-impl-log.md` with the real commit the PASS claim is made
against — required for P0/P1/`--strict`, same bar as G8's test evidence. A PASS recorded with no
SHA, or against a stale one, is not verifiable evidence.
Do not edit another ticket’s impl log or reuse its PASS marks.
Run `/dev-workflow:check <Ticket> [slug] G6` before any G6 PASS claim.
Coverage gaps, failing tests, or missing/stale Commit SHA keep build FAIL.
Never invent PASS; refuse coding when prerequisite gates fail.
Chat in user language (`references/locale.md`).
