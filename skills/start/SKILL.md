---
name: start
description: >-
  Full delivery pipeline from first failing gate. Use /dev-workflow:start.
  Stops for human confirm on conflicts before plan.
argument-hint: "<Ticket ID> [ticket URL] [spec path or paste] — start full pipeline from first failing gate"
arguments: [ticket_id, url_or_path, extra]
disable-model-invocation: true
---

# /dev-workflow:start

Dispatch from first failing gate.
Read `references/workflow.md` and `references/project-root.md`.
Resolve and print `project=<slug> home=<path>`.
Run in order: learning → coaching → spec → conflict → confirm → plan → build → review → fix (if findings) → test → check → ship.
Ask user on ambiguity or conflict decisions; never hardcode paths.
