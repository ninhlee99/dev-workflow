# Conflict check

Do not skip worklog artifacts. Read `references/risk.md` first. Read `references/ba-integrity.md`
before classifying anything — step 2 below is where the DJ-4748-style miss happens: it is not
enough to check code matches the ticket's stated AC, you must also check the AC/current-behavior
itself against an independent source before calling it `MATCH`.

Steps:
1) read `02-spec.md` + domain knowledge; note Risk P0/P1/P2.
2) for each AC/NEG/PERM/EDGE, map running code (`file:line`) and classify `MATCH`, `NO`, or
   `UNCLEAR`. Locate that code by walking the real execution path in order — route → controller
   action → service/operation → model — per `references/ba-integrity.md`'s "Investigate the real
   execution path" section; do not jump straight to a model/helper that looks relevant before
   confirming the controller action actually reaches it. Before writing `MATCH`: ask what
   independent source (UI copy, written spec, PM/ domain expert, prior contract — see
   `references/ba-integrity.md`) confirms this is the *intended* behavior, not just the *current*
   one. No independent source and it's a non-trivial behavior claim → classify `UNCLEAR —
   code-as-baseline only`, not `MATCH`.
3) write all claims to `03-conflict-report.md` with source AC, proposal, decision, owner, date.
   Include claims nobody asked about if you found a real documented-vs-actual mismatch or an
   old-spec-vs-new-spec conflict while doing step 2 — do not limit claims to what the reporter
   already suspected.
4) write questions to `03-qa-log.md` (`OPEN/CONFIRMED/WAIVED`).
5) require explicit confirm for every `NO` or `UNCLEAR` via `:confirm` (`CONFIRM G3:`).

Any unresolved claim or OPEN row means G2/G5 FAIL; block `:plan` and `:build`.
P2 may WAIVE G2 only with INDEX five-field row + reason.
