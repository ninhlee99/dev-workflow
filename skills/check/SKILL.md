---
name: check
description: >-
  Run check-gates.sh (G0–G9). Supports --strict and --verify-net.
argument-hint: "<Ticket ID> [slug?] [G8|G9?] — never invent PASS"
arguments: [ticket_id, project_slug, min_gate]
disable-model-invocation: true
---

# /dev-workflow:check

Run real checker only.
Pre-ship: `--min G8`. Pre-merge: `--min G9 --strict`.
Optional `--verify-net` for CI URL HTTP check.
Nonzero exit = refuse PASS.
