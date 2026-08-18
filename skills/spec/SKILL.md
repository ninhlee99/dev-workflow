---
name: spec
description: >-
  Normalize Intent + Spec; set Risk P0/P1/P2. P0 must add 02b-security.md.
  If Touches UI: fill QA handoff oracle table so independent QA can design
  test cases from this spec alone.
argument-hint: "<Ticket ID> [ticket URL] [requirements path or paste]"
arguments: [ticket_id, url_or_path, spec_path]
disable-model-invocation: false
---

# /dev-workflow:spec

Apply `references/skill-quality.md` and the authoritative `references/stage-contract.md`.

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

You are the BA on this ticket, not a transcriber. Read `references/ba-integrity.md` before
normalizing — it governs how skeptically you treat "current code behavior" as ground truth, how
you adapt that skepticism to this project's risk profile, and what you're actively looking for
(old-spec-vs-new-spec conflicts, documented-vs-actual mismatches, a fix that only patches the
loud symptom). Apply it now, not just when something already looks broken.

**First, classify the ticket** — Bug / New feature / Spec change / Requirement change — per
`references/ba-integrity.md`'s "Classify the ticket first" section, and record it as `Type: …` in
**both** `01-intent.md` and the worklog `INDEX.md` (`Type:` field, next to `Risk:`) — `INDEX.md` is
what downstream stages (`:clarify` especially) actually check, so a classification that only
lives in `01-intent.md` will get missed. Each type has its own investigation strategy in that
file; use the matching one, not the bug procedure by default. A ticket mixing types → split into
separate claims per type rather than forcing one strategy over both.

Normalize requirements into worklog. Attach a source/truth label to each decision-driving
requirement. Reporter wording is `DOCUMENTED`, not independently verified, unless corroborated;
analyst inference remains `INFERRED`.
Set **Risk** per `references/risk.md`.
If P0: create `02b-security.md` from template (`references/security.md`).

Also invoke the `security-review` skill against the pending/planned changes for broader
OWASP-style coverage on top of the required `02b-security.md` template above — it does not
replace the template. Fold any findings it surfaces into `02b-security.md`.
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
Before PASS, verify exactly one Type per claim, exactly one Risk, every requirement has a source or
explicit `UNVERIFIED`, and every UI oracle is observable without asking the implementer.

## Standalone use — self-chain into `:clarify`

`:spec` runs standalone with no other stage's output required. Once this stage's own PASS bar
above is met, check whether any claim is ambiguous or contradicts observed running behavior. If
so, **invoke `:clarify` yourself** before reporting done, so a bare `/dev-workflow:spec <Ticket>`
call leaves the ticket with both a normalized spec and its open questions surfaced/decided, not
just a spec that silently defers questions to a stage the user may never call. Skip this internal
call when there is nothing ambiguous to raise — an empty claim table doesn't need a `:clarify` run
manufactured for it.
