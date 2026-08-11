---
name: spec
description: >-
  Normalize Intent + Spec; require Risk P0/P1/P2 and Scenario AC before coding.
argument-hint: "<Ticket ID> [ticket URL] [requirements path or paste]"
arguments: [ticket_id, url_or_path, spec_path]
disable-model-invocation: true
---

# /dev-workflow:spec

Normalize requirements into worklog.
Set **Risk** (P0/P1/P2) per `references/risk.md`.
Fill `01-intent.md` + `02-spec.md` with Scenario AC + NEG/PERM/EDGE (+ UI if needed).
Report uncovered AC/claims. Block forward when ambiguous.
Empty knowledge → `:learning`; wrong/changed → `:coaching`.
