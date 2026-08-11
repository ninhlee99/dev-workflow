---
name: ship
description: >-
  Draft ship/PR notes with worklog links after Confirm. Does not push/merge
  unless user explicitly asks. Use /dev-workflow:ship.
argument-hint: "<Ticket ID> Run only after confirm — write ship notes and prepare/update the PR from the worklog"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:ship

Prepare ship notes from confirmed worklog.
Require G6 PASS/valid WAIVE, then run `/dev-workflow:check <Ticket> [slug] G7` when final ship gate is required.
Fill `templates/07-ship.md` with release evidence and PR notes.
If checker fails, refuse ship.
Never push or merge unless user explicitly asks.
