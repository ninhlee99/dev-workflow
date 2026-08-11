---
name: check
description: >-
  Run bin/check-gates.sh on a ticket worklog and report PASS/FAIL.
  Paths auto-resolve from the user project (cwd/git/workspaces). Use /dev-workflow:check.
argument-hint: "<Ticket ID> [project-slug?] [G5|G6|G7?] — run gate checker; print PASS/FAIL and next fix"
arguments: [ticket_id, project_slug, min_gate]
disable-model-invocation: true
---

# /dev-workflow:check

Run real checker only; never infer PASS.
Resolve paths via `references/project-root.md`.
Execute checker for ticket, optional slug, and min gate (`G5|G6|G7`, default `G6`).
Report exit code and gate verdict (`0=PASS/WAIVE`, nonzero=FAIL/error) plus next stage.
If checker is not run or exit is nonzero, refuse PASS.
