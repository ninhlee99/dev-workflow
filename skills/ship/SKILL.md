---
name: ship
description: >-
  Draft ship/PR notes with worklog links after G8 test evidence PASS.
  Does not push/merge unless user explicitly asks. Use /dev-workflow:ship.
argument-hint: "<Ticket ID> Run only after test — write ship notes and prepare/update the PR from the worklog"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:ship

Prepare ship notes from reviewed + tested worklog.
Require G8 PASS/valid WAIVE (not under `--strict` G8 waive ban).
Run `/dev-workflow:check <Ticket> [slug] G8` before drafting.
Fill `templates/07-ship.md` with release evidence and PR notes.
If checker fails, refuse ship.
Never push or merge unless user explicitly asks.
