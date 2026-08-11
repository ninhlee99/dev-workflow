# Conflict check

Do not skip worklog artifacts. Read `references/risk.md` first.

Steps:
1) read `02-spec.md` + domain knowledge; note Risk P0/P1/P2.
2) for each AC/NEG/PERM/EDGE, map running code (`file:line`) and classify `MATCH`, `NO`, or `UNCLEAR`.
3) write all claims to `03-conflict-report.md` with source AC, proposal, decision, owner, date.
4) write questions to `03-qa-log.md` (`OPEN/CONFIRMED/WAIVED`).
5) require explicit confirm for every `NO` or `UNCLEAR` via `:confirm` (`CONFIRM G3:`).

Any unresolved claim or OPEN row means G2/G5 FAIL; block `:plan` and `:build`.
P2 may WAIVE G2 only with INDEX five-field row + reason.
