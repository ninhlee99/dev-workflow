# Conflict check

Do not skip worklog artifacts. Read `references/risk.md` first. Read `references/ba-integrity.md`
before classifying anything — step 2 below is where the DJ-4748-style miss happens: it is not
enough to check code matches the ticket's stated AC, you must also check the AC/current-behavior
itself against an independent source before calling it `MATCH`.

Steps:
1) read `02-spec.md` + domain knowledge; note Risk P0/P1/P2.
2) read the checked `Type:` from INDEX. Mixed tickets dispatch each claim separately. A missing,
   unchecked, or multiply-checked Type is a G1 defect: stop and route to `:spec`.

   Use exactly the matching strategy from `references/stage-contract.md` and
   `references/ba-integrity.md`:

   - `Bug)` reproduce the reported input/output, find the real entrypoint, then walk only the
     confirmed execution chain hop by hop to the mechanism. Check a sibling path only when the same
     mechanism is evidenced.
   - `New feature)` read one closest analog end-to-end, confirm concrete insertion points and
     existing constraints/contracts; do not hunt for nonexistent wrong behavior.
   - `Spec change)` state documented before/after, then search every consumer of the specific
     behavior and surface assumptions of the old contract.
   - `Requirement change)` state exact old/new rule, search every encoding across code, config,
     UI copy, docs, and relevant repos, then require a named authority for the change.

   For each AC/NEG/PERM/EDGE, record the required evidence (`file:line`, exact copy/spec quote, or
   runtime result), truth label, source, date, and confidence before classifying `MATCH`, `NO`, or
   `UNCLEAR`. Before `MATCH`, identify an independent intent source. No independent source for a
   non-trivial behavior claim means `UNCLEAR — code-as-baseline only`, unless the authorized project
   norm explicitly selected code as baseline and that decision is quoted.
3) write all claims to `03-clarify-report.md` with source AC, proposal, decision, owner, date.
   Include claims nobody asked about if you found a real documented-vs-actual mismatch or an
   old-spec-vs-new-spec conflict while doing step 2 — do not limit claims to what the reporter
   already suspected.
4) write questions to `03-qa-log.md` (`OPEN/CONFIRMED/WAIVED`).
5) ask every `NO`/`UNCLEAR` claim as one short numbered list (after the multi-angle BA pass in
   `references/ba-integrity.md`), take the user's free-text batch reply, match it to claims
   yourself, **echo the matches back before writing any Decision** (a wrong silent match is worse
   than one extra line), and re-ask only the unresolved remainder — see `skills/clarify/SKILL.md`'s
   "Ask once, in plain language" section. Satisfied once every claim in `03-qa-log.md` reaches
   `CONFIRMED`/`WAIVED`, however many question rounds it took — the round count isn't checked,
   only the end state. `:confirm` (`CONFIRM G3:`) locks the resulting decisions in afterward.

Any unresolved claim or OPEN row means G2/G5 FAIL; block `:plan` and `:build`.
P2 may WAIVE G2 only with INDEX five-field row + reason.
