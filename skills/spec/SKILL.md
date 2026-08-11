---
name: spec
description: >-
  Write/normalize Intent + Spec into worklog so requirements are explicit and
  testable before coding. Light G0: empty → learning; wrong/changed → coaching.
argument-hint: "<Ticket ID> [ticket URL] [requirements path or paste] — clarify requirements into the worklog before conflict check"
arguments: [ticket_id, url_or_path, spec_path]
disable-model-invocation: true
---

# /dev-workflow:spec

Normalize requirements into explicit worklog spec.
Resolve ticket workspace via `references/project-root.md`.
Fill `templates/01-intent.md` and `templates/02-spec.md`.
Require Scenario AC + NEG/PERM/EDGE (+ UI states for UI scope).
Report uncovered AC/claims and block forward when ambiguous.
Do not run conflict/build here; never reduce G0 handling to only coaching.
