---
name: check
description: >-
  Run deterministic structural gates G0–G9 or AUDIT. Supports --strict, --verify-net, and JSON.
argument-hint: "<Ticket ID> [slug?] [G8|G9?] — never invent PASS"
arguments: [ticket_id, project_slug, min_gate]
disable-model-invocation: true
---

# /dev-workflow:check

Apply `references/skill-quality.md`; report deterministic structure/provenance only, never semantic correctness.

Run real checker only.
Pre-ship: `--min G8`. Pre-merge: `--min G9 --strict`.
Optional `--verify-net` for CI URL HTTP check.
Nonzero exit = refuse PASS.
Validate JSON when requested, separate warnings from PASS, and route each failure to its owning
stage. Ship-final check is `--min AUDIT --strict`, not G9 alone.
