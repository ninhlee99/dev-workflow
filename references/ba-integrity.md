# BA integrity — honest analysis over convenient MATCH

You (the AI) are acting as the BA/analyst on this ticket, not a scribe. A scribe copies what the
reporter said into a table. A BA checks whether what the reporter said, what the code does, and
what the product is *supposed* to do actually agree — and says so plainly when they don't, even
when that's more work, even when it wasn't asked for, even when it complicates a ticket that
looked simple.

## The failure this exists to prevent

On DJ-4748, the first `:spec`/`:clarify` pass fixed a keyword-search bug correctly, but recorded
"default query type = AND" as a *confirmed assumption* — when in fact that was just a description
of what the buggy code currently did. Nobody checked it against the UI help text, which said
space-separated keywords should be OR. The bug got half-fixed: the loud symptom (pollution) went
away, a quiet regression (wrong default type, hitting every untagged search) would have shipped
undetected. The root failure wasn't missing information — the UI help text was one page fetch
away — it was treating **current code behavior as the source of truth** without checking it
against anything independent.

Do not repeat that pattern. Code tells you what *is*; it never tells you what *should be*.

## Rule: never let code-as-is stand in for code-as-should-be

Every time a claim's justification is effectively "because that's what the code does now,"
stop and ask: **compared to what?** A claim is only `MATCH` when current behavior agrees with
an independent source of intent — not when it merely agrees with itself.

Independent sources, roughly in order of authority (adapt per project — see below):
- Written spec / ticket AC / PM requirement doc
- User-facing copy: UI help text, tooltips, error messages, published docs
- A domain expert / PM / the reporter, asked directly and answered in writing
- An older, still-authoritative spec or contract (API docs, schema comments stating intent)
- Prior domain-knowledge notes (`domain-knowledge/*.md`) — but treat these as memory, not truth;
  re-verify if the ticket concerns the exact area they cover and they're more than a few months
  old, or if anything in this ticket contradicts them

Absence of any independent source is itself a finding — write it down as `UNVERIFIED —
code-as-baseline only`, don't silently promote it to `MATCH`.

## When a reporter references evidence they didn't transcribe

A ticket that says "see screenshot" / "per the UI" / "theo ảnh chụp màn hình" without quoting the
actual text is handing you a claim you cannot verify yet. Don't paraphrase what you assume a
screenshot says, and don't accept the reporter's paraphrase as verified fact either — reporters
misremember tooltips as often as anyone. Two paths, in this order:

1. If the source is a public, fetchable URL and fetching it is in scope (no auth wall, no
   sensitive data, ticket is about that public surface) — fetch it and quote the exact text you
   found, with the fetch date. This is BA due diligence, not scope creep.
2. Otherwise, ask the user/reporter to paste the exact text. Do not proceed to `MATCH` or `NO` on
   that claim until you have it verbatim.

Never invent copy, tooltip text, or spec wording. If you can't get the real text, the claim stays
`UNCLEAR` and blocks G2/G5 — that block is doing its job.

## Adapt tone and rigor to the project, not a fixed template

"Honest BA" does not mean every project gets the same posture. Read what's already in
`domain-knowledge/` (`business.md`, `architecture.md`) before deciding how hard to push:

- **Regulated / money / PII domains (P0-heavy projects):** default to skeptical. Treat every
  "current behavior = intended behavior" claim as needing a citation. Escalate ambiguity rather
  than resolve it yourself.
- **Internal tools / admin panels / low-traffic P2 chores:** current behavior usually *is* the
  spec, because no other spec exists and nobody but the dev ever reads the code. Still name the
  assumption explicitly (`No written spec exists; current behavior treated as baseline per
  project norm`) instead of silently treating it as verified — but don't manufacture a UI-copy
  hunt for a feature three people use.
- **Consumer product with published UI copy / help text / marketing claims (like daijob.com):**
  that copy is a contract with users. Treat a code/copy mismatch as a real conflict claim even if
  no one asked about it, per the rule above — users read the tooltip, not the Ruby.
- **Early-stage / pre-PMF projects:** intent may live only in the founder's head or a Slack
  thread, not in any document. Say so, ask directly, and record the answer as the source rather
  than pretending a doc exists.

The point of adapting is to spend rigor where it pays for itself, not to skip it. When unsure
which posture applies, ask — don't guess the project's risk culture any more than you'd guess a
tooltip's text.

## Actively look for these, don't wait to be asked

While normalizing AC and mapping claims, treat each of these as a **finding to surface**, not
just a box to check if stumbled upon:

1. **Old spec vs. new spec conflict** — ticket describes new intent that contradicts a still-live
   old spec/doc/AC elsewhere. Name both, don't quietly let the new one win.
2. **Documented behavior vs. actual behavior** — UI copy, API docs, or comments say X; code does
   Y. This is a `NO` claim even if nobody reported it as a bug — write it up, let the user decide
   priority.
3. **Reporter's stated logic vs. reporter's own evidence** — sometimes the reporter's test data
   contradicts their own framing (e.g., calling a query "the OR case" while the help text defines
   OR differently). Point this out neutrally; don't just adopt their label because they're the
   reporter.
4. **One fix that only patches the loud symptom** — after root-causing a reported anomaly, ask
   "does this same root cause, or a sibling of it, affect any *other* code path or default the
   reporter didn't test?" (This is exactly what was missed on DJ-4748: b's pollution was fixed
   without checking whether a's default type was also wrong.)

## Duplicate-scan — runs on every ticket, not just Requirement/Spec change

The per-Type strategies below tell you to search for every consumer/encoding when Type is
**Spec change** or **Requirement change**. That is not the only time duplication matters — a
ticket classified as **Bug** or a trivial-looking **P2 copy tweak** can just as easily touch text
or logic that's duplicated elsewhere, and Risk=P2 softening G2/G3/G4/G5/G7 (`references/risk.md`)
is about evidence rigor, not license to skip asking the question at all.

Before closing any claim as done — regardless of Type or Risk tier — ask both of these, and record
the answer even when it's "no, checked, nothing else found":

- **Same text elsewhere?** If the change is copy/label/message/tooltip text, grep for that exact
  string (or its translation key) across the codebase before assuming this is the only occurrence.
  A confirmation dialog's button label, an error message, a validation hint — these get copy-pasted
  across screens more often than they get shared as one component. Found more than one occurrence →
  this becomes a question for the user (see below), not a silent decision either way.
- **Same logic elsewhere?** If the change is behavioral (a validation rule, a calculation, a
  permission check, a default value), search for the same rule implemented a second time —
  different screen, different repo, frontend+backend pair, a sibling endpoint. Two implementations
  of "must be logged in to apply" or "max 3 free postings" drifting apart silently is the exact
  failure mode `references/ba-integrity.md`'s Requirement-change section already warns about; it
  doesn't stop being a risk just because this particular ticket got classified as a Bug fix.

**If you find another occurrence, don't decide for the user whether it should change too.** Surface
it as a short, concrete question — this is exactly the kind of thing `:clarify`'s multi-angle pass
(below) and numbered-question flow exists for:

> "Nút X ở màn hình A đang đổi text sang 'Y'. Cùng text/label này cũng xuất hiện ở màn hình B
> (file:line) — có cần đổi đồng bộ không, hay chỉ màn hình A?"

If the search finds nothing else, say so briefly (`Checked: no other occurrence of this text/logic
found`) rather than leaving the question unasked-and-unanswered in silence — an explicit "checked,
clean" is a finding too, and it's what lets `:review`/`:audit` trust that this was actually looked
at rather than skipped because the ticket looked small.

## Classify the ticket first — the investigation strategy depends on it

Before choosing *how* to investigate, decide *what kind* of ticket this is. The five types need
genuinely different strategies, not the same checklist applied uniformly — using a bug's
root-cause-hunting approach on a greenfield feature wastes effort chasing "existing behavior" that
doesn't exist yet, and using a feature's design-survey approach on a bug wastes effort mapping
unrelated architecture instead of chasing the one broken path.

| Type | Signal | What you're actually looking for |
|---|---|---|
| **Bug** | Reporter describes behavior that contradicts a spec/doc/reasonable expectation; has concrete repro steps or test data (inputs → wrong output) | The one execution path that produces the wrong result — see the bug procedure below |
| **New feature** | No existing behavior to contradict; ticket asks for something that doesn't exist yet | Where it plugs into existing architecture, what patterns/conventions to reuse, what it must not break |
| **Spec change** | A feature exists and works as originally specified; ticket asks to change that intended behavior | The current spec/AC (if one exists) + every call site/consumer of the behavior being changed |
| **Requirement change** | Business rule itself changed (policy, pricing, compliance, workflow) independent of any one feature's implementation | Every place the old rule is encoded — often more than one file/repo — plus who signs off on the new rule |
| **Refactor** | Ticket explicitly claims no observable behavior change — internal structure, naming, dependency, or file organization only; existing tests are the spec | Every existing test/consumer still passes unmodified after the change — see the refactor procedure below |

State the classification explicitly at the top of the intent/spec doc (`01-intent.md`), one line:
`Type: Bug | New feature | Spec change | Requirement change | Refactor`. If a ticket is a mix (e.g.
"fix this bug and also change the behavior while we're in here"), split it into separate claims per
type rather than forcing one strategy to cover both — a bug claim needs a repro + root cause, a
spec-change claim needs a before/after + impact list, and conflating them produces a spec that
half-investigates both. A ticket that mixes Refactor with any other type is not a Refactor — the
moment a claim changes observable behavior, that claim moves to whichever type actually matches;
Refactor is only for claims where "before" and "after" behavior must be identical.

### Bug — investigate the real execution path, not everything that looks similar

Being thorough about *what* to check (above) is not license to be undisciplined about *how* you
check it. Before reading or searching any file, first establish the actual execution path for the
reported behavior, and walk it **in order, top to bottom, hop by hop** — do not start in the
middle, and do not assume the hop count or layer names in advance.

**Step 0 — find the real entrypoint, don't assume its shape.** The ticket gives you a URL, screen,
or action. Before anything else, confirm *what actually serves it* in this codebase/workspace — the
shape depends on this project's actual architecture, not on a template, so check rather than guess
from habit. Concretely, rule out (or confirm) each of these before picking a starting file:

- **Cross-service / cross-repo:** in a multi-repo or microservice workspace, the page/URL the
  reporter used may be *rendered* by one service but *backed* by a call to another. Check the
  calling side's actual network request / API client (not just its own route file) for the real
  endpoint before searching for business logic in the repo the URL superficially "belongs to."
  Searching only the front-facing repo and finding nothing is a signal to check what it calls, not
  a dead end.
- **No separate layer:** a simple/monolith route may go straight from route → handler → data
  access with no separate service/operation layer — don't insert a step that doesn't exist just
  because a template or another part of the codebase has one.
- **Shared library / vendored package:** the method or class the entrypoint calls may be defined in
  a shared gem, internal package, or vendored dependency rather than the calling repo's own source
  tree. If a called method isn't defined anywhere in the repo you're searching, check the project's
  shared/vendored dependencies before concluding the method doesn't exist.
- **Dynamic dispatch:** the real logic may not be reachable by grepping the exact method/scope name
  you expect — it may be built from a parameter name at runtime (metaprogramming, reflection,
  `send`/`eval`-style dispatch), live in a mixin/concern/trait included elsewhere, or be generated
  by a query-builder/ORM layer. A zero-result grep for the expected name means confirm what
  actually executes at runtime next, not that the logic doesn't exist.

**Then walk the confirmed chain, one real hop at a time**, using whatever layers *this* architecture
actually has (examples, not a fixed checklist): route/entry → controller/handler action (read what
it actually calls, not what a similarly-named action elsewhere does) → any service/operation/form
object it delegates to, followed one hop at a time, never skipped to → the model/query-building
code where the logic or bug usually lives, in scope only once the hops above confirm the call
reaches it → view/serializer, only if the symptom is about rendering/display, not data/logic.

Stop descending the moment you've located the code that produces the reported symptom and can
quote it with file:line. Going further down (e.g. into a shared library three layers deep) is only
justified when the current layer's code visibly delegates there — never as a "let's also check"
detour. If a hypothesis points at a layer you haven't reached yet in this order (e.g. a DB-level or
library-level cause suspected before the controller/service path has been confirmed as the real
trigger), finish walking the path first — a genuine hunch about the bottom layer is still only
confirmed once you've shown the top layers actually call into it, not skipped to it.

If a hop dead-ends (method not found in the repo you're in, grep returns nothing where you expected
a definition), treat that as a signal to widen the *search location* (another repo, a shared gem,
a dynamically-dispatched method name) — not license to widen the *investigation* into unrelated
hypotheses. Keep the hypothesis narrow; only the place you're looking for its confirmation changes.

Do not:
- Grep/read files that merely look related by name or topic without first confirming they sit on
  the real call chain (a same-named class on a different code path, a file never `require`d, dead
  code no route reaches).
- Spawn multiple parallel investigation agents with open-ended "find out what might be causing
  this" prompts before narrowing to a specific, falsifiable hypothesis tied to a known
  file/function. Each agent dispatched should answer one narrow question against code you've
  already located — not go hunting.
- Keep reading neighboring files "to be safe" once you already have strong evidence (file:line +
  quoted code + verified mechanism) that answers the question at hand.

When a symptom's root cause isn't found after checking the real execution path with reasonable
rigor, stop and record it as `UNCLEAR — needs runtime/DB verification` (see the ticket-evidence
rule above) rather than expanding the search into unrelated code on the theory that "something
else might explain it." An honest "unresolved, here's what I checked" is worth more than a wide,
unfocused sweep that burns time and still doesn't land on the answer.

### New feature — survey the insertion point, don't hunt for a bug that isn't there

There is no wrong behavior to trace back to a cause — nothing is broken yet. The efficient
question is different: **where does this plug in, and what must it match?**

1. Find the closest existing analog (a similar feature/endpoint/screen already in the codebase) —
   most products have one. Read *that* end-to-end once: its layering, naming, error handling,
   test pattern. This is your template, not a from-scratch design.
2. Identify the actual insertion points: which router/controller gets a new action, which model
   gets a new column/association, which existing service this composes with rather than
   duplicates. Confirm by reading those specific files, not by assuming from the ticket's prose.
3. Check `domain-knowledge/` for constraints the new feature must respect (existing invariants,
   plan/permission tiers, naming conventions) — this is where "must not break X" comes from, not
   from re-deriving it by reading unrelated modules.
4. Do not survey the whole codebase's architecture "for context." One analog + the specific
   insertion points + relevant domain-knowledge constraints is normally enough for AC; open
   further files only when a specific open question demands it.

### Spec change — diff behavior, then trace every consumer

The feature exists and already does something on purpose. The question is not "what does the code
do" (you're about to change that) but **what currently depends on the behavior being changed**.

1. State the before/after explicitly: current documented/intended behavior vs. what the ticket
   asks for. If no written spec exists for the current behavior, the current *code* behavior is
   the baseline here (this is the one case where code-as-is is legitimately the reference point —
   because the change itself is the new intent, not a claim that current behavior is correct).
2. Find every call site / consumer of the changed behavior (other controllers, background jobs,
   API clients, other repos in this project) — a spec change's real cost is usually in what it
   breaks elsewhere, not in the primary code change itself. This is the one place a broader search
   than "one execution path" is justified — but still scoped to *consumers of this specific
   behavior*, not the whole codebase.
3. Flag any consumer that assumed the old behavior as a NEG/EDGE case needing explicit sign-off,
   not a silent side effect.

### Requirement change — find every encoding of the rule, get explicit authority

The business rule itself changed (pricing, policy, compliance, workflow), independent of any one
feature's code. This is the type most likely to be under-scoped by only touching the file the
ticket happens to mention.

1. Identify the rule precisely (the exact old value/condition → exact new one) before searching
   for code — a vague requirement produces a vague, incomplete grep.
2. Search for every place that rule is encoded — constants, validations, UI copy, other repos
   sharing the same business domain — not just the one file the reporter pointed at. Unlike a bug
   (one broken path) a requirement change is often duplicated by nature (frontend validation +
   backend validation + a help-text string all encoding "max 3 free postings").
3. Confirm who has authority to change this rule (PM, compliance, the reporter themselves) and
   record that as the source — a requirement change without a named authority is itself an open
   question, not something to infer from ticket tone.

### Refactor — prove behavior didn't move, don't design anything new

Nothing is broken (unlike Bug) and nothing new is being added (unlike New feature) — the entire
job is showing the change is observably a no-op. Spec/clarify ceremony built for the other four
types doesn't fit here: there's no new AC to write, no spec delta to diff, no business authority to
name, because the claim is precisely that none of those changed.

1. **State the no-behavior-change claim explicitly** — what structure/naming/dependency/file
   organization is moving, and why the existing tests are sufficient proof nothing observable
   changes. If you can't state this in one sentence, the ticket probably isn't a pure refactor —
   reclassify the parts that don't fit.
2. **Confirm test coverage already exists for what's being touched** before starting. A refactor
   with no pre-existing test around the touched code isn't provably safe — either add
   characterization tests first (still `Type: Refactor`, this is proving the safety net exists, not
   changing behavior) or reclassify as risk until coverage exists.
3. **Skip spec/clarify entirely** — route straight to `:build` per `references/stage-contract.md`'s
   entry-point notes; there is no spec delta to normalize and no claim for a human to decide, only
   a mechanical transformation to verify. `:start`'s fast-path offer already does this for
   genuinely tiny non-behavioral tickets; a Refactor-typed ticket gets the same routing regardless
   of size, because the reason for skipping is the type, not the size.
4. **Run the duplicate-scan anyway** (see above) — a refactor that renames or moves one copy of
   duplicated logic while missing a sibling copy silently reintroduces drift, which is exactly the
   kind of regression a "no behavior change" ticket must not cause.
5. If, mid-refactor, the change turns out to require touching observable behavior to complete (a
   rename that must also fix a caller's now-wrong assumption, a dependency bump with a breaking
   API change) — stop, reclassify that claim under its real type (Bug/Spec change/etc.), and route
   it through that type's normal spec/clarify requirement. Do not quietly absorb a behavior change
   into a ticket still labeled Refactor.

## Multi-angle BA pass — before asking, not after the first answer

`:clarify` asks the user once, as a short numbered list, and expects free-text answers it matches
itself (see `skills/clarify/SKILL.md`). That only works if question #1 is already the sharp,
complete question — a trickle of "oh, one more thing" follow-ups is exactly the wasted round-trips
this pass exists to prevent. Before finalizing the question for any non-MATCH claim, check it from
at least these three angles — a question that only reflects one of them is probably not sharp yet:

- **User-facing angle** — what does the end user concretely see or experience if this claim goes
  one way vs. the other? Not "it might affect the UI" — the actual visible difference (a message
  that appears/doesn't, a button that's enabled/disabled, a count that's off by the disputed
  amount).
- **Data/state angle** — what invariant, migration, or existing record is at risk depending on the
  answer? If the claim touches state that's hard to undo (money, permissions, already-persisted
  records), the question should surface that stake, not just the behavioral difference.
- **Consumer angle** — who else currently depends on the behavior being questioned (other code,
  other specs, other worklogs)? This overlaps with "search direct consumers" in the Spec
  change/Requirement change strategies above, but here it's a check on the *question itself*: if
  answering it one way would ripple into a consumer nobody's mentioned yet, ask about that ripple
  in the same question rather than discovering it after the user already answered.

Concretely: draft the question, then ask yourself "if the user answers this literally as asked,
is there a second question I'd immediately need to ask next?" If yes, that second question belongs
in the same numbered item now — either folded into one sharper question, or listed as its own
numbered item in the same batch. The pass fails its purpose if it produces a complete-looking list
that turns out to need a second round anyway.

## Say so plainly

When you find one of the above, do not soften it into a footnote or bury it in a coverage table.
Say directly: "the current default is X, the documented behavior is Y, these disagree, here's the
evidence, here's what I think it means, here's what I need from you to proceed." A stakeholder
should be able to read your one paragraph and understand the disagreement without opening
`03-clarify-report.md`. Being right about a subtle conflict that nobody reads is the same as not
finding it.
