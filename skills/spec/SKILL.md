---
name: spec
description: >-
  Normalize Intent + Spec; set Risk P0/P1/P2. P0 must add 02b-security.md.
  If Touches UI: fill QA handoff oracle table so independent QA can design
  test cases from this spec alone.
argument-hint: "<Ticket ID> [ticket URL] [requirements path or paste]"
arguments: [ticket_id, url_or_path, spec_path]
disable-model-invocation: true
---

# /dev-workflow:spec

Normalize requirements into worklog.
Set **Risk** per `references/risk.md`.
If P0: create `02b-security.md` from template (`references/security.md`).
Fill Scenario AC + NEG/PERM/EDGE (+ UI if needed).

If Touches UI = Yes: fill the **QA handoff — testable oracle** table in `02-spec.md`. This
worklog does not run QA itself — that happens later, outside this pipeline, by a human tester or
a tool like `qa-intelligence`. Its only job here is to make sure whoever does QA next can design
test cases **from this file alone**, without asking the dev what a field is called or what
"success" looks like on screen. "Shows success message" is not a testable oracle; name the real
field/button label and the exact machine-checkable signal (`expected_text`,
`expected_url_includes`, `expected_result_count`, `expected_network`, or `other` with a precise
description). Screen not designed yet → mark the row `☐ TBD — confirm before :build closes`,
never leave it silently blank.

Empty knowledge → `:learning`; wrong/changed → `:coaching`.
