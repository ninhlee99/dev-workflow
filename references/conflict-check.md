# Conflict check

Do not skip worklog artifacts.

Steps:
1) read `02-spec.md` + domain knowledge.
2) for each AC/NEG/PERM/EDGE, map running code (`file:line`) and classify `MATCH`, `NO`, or `UNCLEAR`.
3) write all claims to `03-conflict-report.md` with source AC, proposal, decision, owner, date.
4) write questions to `03-qa-log.md` (`OPEN/CONFIRMED/WAIVED`).
5) require explicit confirm for every `NO` or `UNCLEAR`.

Any unresolved claim or OPEN row means G2/G4 FAIL; block `:plan` and `:build`.
