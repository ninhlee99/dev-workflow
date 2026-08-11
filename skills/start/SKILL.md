---
name: start
description: >-
  Full delivery pipeline: learning → coaching → spec → conflict → plan → build →
  confirm → ship. Use /dev-workflow:start. Stops for human confirm on conflicts.
argument-hint: "<Ticket ID> [ticket URL] [spec path or paste] — start full pipeline from first failing gate (learning → coaching → spec → conflict → plan → build → confirm → ship)"
arguments: [ticket_id, url_or_path, extra]
disable-model-invocation: true
---

# /dev-workflow:start

Dispatch from first failing gate.
Read `references/workflow.md` and `references/project-root.md`.
Resolve and print `project=<slug> home=<path>`.
Run in order: learning → coaching → spec → conflict → plan → build → confirm → ship.
Ask user on ambiguity or conflict decisions; never hardcode paths.
