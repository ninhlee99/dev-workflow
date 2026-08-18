# Semantic audit (post-structural)

Use with `/dev-workflow:audit`. Runs **after** `check-gates.sh --min G9 --strict` exits 0.

## Why this exists

`check-gates.sh` verifies **structure**: field non-empty, checkbox ticked, SHA matches git HEAD,
junit has zero failures. It cannot verify **meaning** — a field can be non-empty, not a repeated
placeholder, long enough, and still be *wrong*: a Decision that doesn't answer its Proposal, a
Rollback plan that doesn't undo the Migration two sections above it, a test command that runs but
doesn't actually exercise the AC it's mapped to. Regex/awk have a hard ceiling here — they match
patterns, not logic. This stage exists to check logic, using the one tool that can: an AI (or
human) actually reading the content in context.

This is not a re-run of `:review` (that hunts code diff defects) and not a re-run of `:clarify`
(that diffs spec vs running code). This reads the **worklog's own internal consistency** — do its
parts agree with each other and with the spec — after every gate has already structurally passed.

## When to use

- After `check-gates.sh <Ticket> --min G9 --strict` exits 0
- Before `:ship` is treated as final / before merge
- Risk P0/P1 required; P2 optional (skip is acceptable only with a recorded reason)

**Do NOT use** as a substitute for `:review` (code defects) or `:clarify` (spec vs code) — this
stage assumes both already passed and only checks the worklog's internal story holds together.

## The Process

```
Semantic audit:
- [ ] Step 1: LOAD — read all worklog artifacts for the ticket (02 through 07)
- [ ] Step 2: CROSS-CHECK — verify each coherence pair below with quoted evidence from both sides
- [ ] Step 3: VERDICT — PASS / FAIL / UNCLEAR per pair, with reasoning (not just a label)
- [ ] Step 4: LOG — write 08-semantic-audit.md
- [ ] Step 5: GATE — any FAIL routes back to the stage that owns the broken artifact, not straight to fix
```

### Step 1: LOAD

Read in full (not skimmed): `02-spec.md`, `03-clarify-report.md`, `04-plan.md`, `05-impl-log.md`,
`06-review-qa.md`, `06b-test-evidence.md`, `07-ship.md`. All must already be `check-gates.sh` PASS
— if not, stop and route back to `:check`, do not audit an incomplete worklog.

### Step 2: CROSS-CHECK — coherence pairs (required, in order)

For each pair, quote the **exact text** from both sides before judging. A verdict without both
quotes is not evidence, it's an opinion — do not write one.

| # | Pair | What "coherent" means |
|---|---|---|
| C1 | Conflict claim Proposal ↔ Decision | Decision actually resolves what Proposal asked — not a restatement, not a non-sequitur, not "confirmed" with no content |
| C2 | Plan task AC/claim ↔ DoD/test command | The named test command would plausibly exercise the named AC's Given/When/Then — not a generic `rspec` with no path, not a command for an unrelated file |
| C3 | Impl-log Coverage map Result=PASS ↔ AC text | The test path name/description is topically related to the AC it claims to cover (a `login_spec.rb` claiming to cover an "export CSV" AC is incoherent) |
| C4 | Review AC evidence "How verified" ↔ AC Given/When/Then | The verification steps described actually correspond to the scenario, not a copy-pasted generic phrase repeated across unrelated AC rows |
| C5 | Ship Migration section ↔ Ship Rollback section | If Migration = Yes, Rollback steps must address undoing that specific migration (schema revert / backfill note), not a generic "revert commit" that would leave the DB in a broken half-migrated state |
| C6 | Ship Feature flag ↔ Ship Rollout plan | If a flag exists, rollout plan should reference using it (gradual enable) — a flag declared but rollout plan ignoring it entirely is a contradiction worth flagging |
| C7 | Clarify report side-effect claims ↔ Review "Side effects" checklist | Anything clarify-report flagged as a kept/changed side effect (notification, cache, audit log) should appear verified (not silently dropped) in review's Side effects section |
| C8 | Fix-log Decision ↔ Review finding Class/Location | `check-gates.sh` G7 only verifies a `06c-fix-log.md` row exists for every triaged finding — it cannot judge whether the Decision actually addresses what the finding described. A `FIX` decision whose "Changes applied" row touches a different file than the finding's `Location`, or whose one-line reason doesn't relate to the finding's `Class` (e.g. finding is `injection`, fix note says "renamed variable"), is a fix-log entry that exists structurally but proves nothing |

### Step 3: VERDICT

Each pair gets exactly one of:

- **COHERENT** — both sides quoted, they agree, reasoning states *why* in one sentence
- **INCOHERENT** — both sides quoted, they conflict or one is vacuous; state the concrete
  contradiction
- **UNCLEAR** — insufficient content on one side to judge (e.g. field genuinely N/A) — this is not
  a pass, it needs a human decision same as `:clarify`'s UNCLEAR label

Format per pair:

```
[C5] Migration ↔ Rollback
MIGRATION SAYS: "Has migration? Yes — adds NOT NULL column `status` with default backfill"
ROLLBACK SAYS: "Rollback steps: revert merge commit abcdef12"
VERDICT: INCOHERENT
REASON: Reverting the app commit does not undo a completed NOT NULL backfill migration —
        the column stays on rolled-back schema reads. Rollback plan is missing a down-migration
        or explicit note that the column is additive/safe to leave.
```

### Step 4: LOG

Write `08-semantic-audit.md` (template in `templates/08-semantic-audit.md`) with all 8 pairs (C1–C8),
even the ones that are trivially COHERENT (e.g. C5/C6 when there's no migration/flag at all — mark
`N/A` explicitly, do not omit the row).

### Step 5: GATE

- Any `INCOHERENT` → route back to the **stage that owns the broken side** (C1/C2 → `:clarify`/`:plan`;
  C3/C4 → `:build`/`:review`; C5/C6/C7 → `:ship`; C8 → `:fix`) — do not patch the audit file
  itself to make it pass
- Any `UNCLEAR` → ask the user directly, same anti-guess rule as `:clarify` Step 5
- When all 8 pairs are `COHERENT` or explicitly `N/A` with reason, the audit is AI-complete, not
  final — an AI's own verdict on its own audit has the same blind-spot risk this stage exists to
  catch, one level up. Require the same anti-forge human sign-off `:confirm` (G3) uses: ask for
  `AUDIT CONFIRM: <Ticket> <name> <YYYY-MM-DD>`, forbid AI/tool names (AI, ChatGPT, Claude,
  Copilot, Cursor, Assistant, Bot), record verbatim in `08-semantic-audit.md` Sign-off section.
- Ship is not final until sign-off is recorded — AI PASS alone is not Result PASS

## Anti-patterns

- Marking COHERENT without quoting both sides — a verdict with no quotes is a guess wearing a
  label
- Treating this as a second code review (defect hunting) — that's `:review`'s job; this is about
  whether the worklog's own claims agree with each other
- Auditing a worklog that hasn't passed `check-gates.sh --min G9 --strict` yet — structural gaps
  must close first, semantic audit on an incomplete worklog wastes the check
- Rubber-stamping P2 tickets by copying the P1 pair list without reading — if genuinely N/A
  (no migration, no flag), say so explicitly per row; do not delete rows to shrink the file

## Relationship to check-gates.sh

This stage is deliberately **not** encoded in `check-gates.sh` — regex/awk cannot judge whether
two pieces of prose agree in meaning, and pretending otherwise (adding ever more elaborate string
heuristics) hits diminishing returns fast. `check-gates.sh` stays the hard structural floor (fast,
cheap, deterministic, runs in CI); `:audit` is the semantic ceiling on top of it (slower, needs a
reader, catches what CI never will). Both are required for the ticket to be genuinely
ship-ready — structural PASS alone is necessary but not sufficient.
