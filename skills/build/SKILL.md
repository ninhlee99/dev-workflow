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

Implement only after prior gates pass (through G4 plan / G5 open-Q clear).
Use TDD and log AC/claim-to-test mapping in `templates/05-impl-log.md`.
Run `/dev-workflow:check <Ticket> [slug] G6` before any G6 PASS claim.
Coverage gaps or failing tests keep build FAIL.
Never invent PASS; refuse coding when prerequisite gates fail.
