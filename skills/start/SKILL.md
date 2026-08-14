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

Apply `references/skill-quality.md` and dispatch exclusively from `references/stage-contract.md`.

Dispatch from first failing gate.
Read `references/workflow.md`, `references/project-root.md`, `references/locale.md`, `references/task-isolation.md`.
If this is the first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per
`references/locale.md` before anything else — do not guess from message language. Otherwise read
the already-set `Chat locale` from `domain-knowledge/INDEX.md` and use it silently.
Resolve and print `project=<slug> home=<path> ticket=<id> worklog=<path> locale=<code>`.
Run `bin/check-workspace.sh` once; FAIL → fix layout (or `:learning`) before gates.
Ensure worklog is **only** `worklogs/<Ticket_ID>/` — never mix another ticket.
Run the first applicable failing owner only: learning when knowledge is missing; coaching when
knowledge is contradicted/changed; otherwise spec → conflict → confirm → plan → build → review →
fix (only justified OPEN findings) → test → check → ship → audit. Do not run learning and coaching
as unconditional sequential ceremony.

This ordering is enforced by **you reading and following it**, not by a script — `check-gates.sh`
verifies each stage's *output artifact* is real, but nothing stops calling `:build` before
`:plan` exists if you skip straight there. The actual backstop is `:build`'s own refusal
("Refuses production code if gates fail") and each stage's file-existence check in
`check-gates.sh` — jumping ahead produces an immediate, visible FAIL at the next `:check` call,
not a silent wrong result. Still: don't rely on that backstop as permission to skip steps: run
`bin/check-workspace.sh` and the gate table check *before* dispatching each stage, the way this
file says, rather than after something breaks.

Ask user on ambiguity or conflict decisions; never hardcode paths.
After dispatch, surface the owning stage's evidence and stop condition; do not absorb its
responsibility or continue past a human/failed gate.
