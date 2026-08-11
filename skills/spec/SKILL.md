---
name: spec
description: >-
  Normalize Intent + Spec; set Risk P0/P1/P2. P0 must add 02b-security.md.
argument-hint: "<Ticket ID> [ticket URL] [requirements path or paste]"
arguments: [ticket_id, url_or_path, spec_path]
disable-model-invocation: true
---

# /dev-workflow:spec

Normalize requirements into worklog.
Set **Risk** per `references/risk.md`.
If P0: create `02b-security.md` from template (`references/security.md`).
Fill Scenario AC + NEG/PERM/EDGE (+ UI if needed).
Empty knowledge → `:learning`; wrong/changed → `:coaching`.
