---
name: check
description: >-
  Run bin/check-gates.sh and report PASS/FAIL. Supports G0–G9 and --strict.
argument-hint: "<Ticket ID> [slug?] [G8|G9?] — run gate checker; never invent PASS"
arguments: [ticket_id, project_slug, min_gate]
disable-model-invocation: true
---

# /dev-workflow:check

Run real checker only.
Default min G8; before merge use G9.
Pass `--strict` for CI / when Risk P0.
Report exit code + next stage. Nonzero = refuse PASS.
