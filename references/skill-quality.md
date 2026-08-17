# Skill quality contract (minimum 9/10 bar)

Every `/dev-workflow:*` skill must apply this contract. A concise artifact is acceptable; an
unsupported conclusion is not.

## Truth labels

Label every material claim whose status is not obvious from a direct quote:

| Label | Meaning | Required evidence |
|---|---|---|
| `OBSERVED` | Directly seen in code, runtime output, diff, or artifact | `path:line`, command output, test id, or exact quote |
| `DOCUMENTED` | Stated by an independent source of intent | exact quote + source + verified date |
| `INFERRED` | Reasoned from observed/documented facts | cited premises + falsifiable reasoning |
| `UNVERIFIED` | Plausible but not independently checked | what was checked + missing evidence/owner |
| `CONFLICTING` | Authoritative sources disagree | both quotes + decision owner; never silently choose |

Never upgrade `INFERRED` or `UNVERIFIED` to fact. Current code proves what is, not what should be.

## Evidence record

For each decision-driving claim record: claim id, truth label, source type, source location, exact
quote or concise observation, verification date, confidence (`high|medium|low`), and owner when a
decision is needed. Sensitive values must be redacted without hiding the fact being proved.

## Responsibility and handoff

Each skill owns only its declared output and may not repair an upstream artifact silently. On an
upstream defect, report `owner stage → broken claim → evidence → required next command` and stop.
Every completed stage prints: verdict, uncovered/uncertain items, artifacts changed, checker/test
actually run, and exactly one next command. A PASS without its required evidence is dishonest.

## Investigation discipline

1. Classify ticket type and risk before choosing an investigation strategy.
2. Start from the smallest real entrypoint or source that can answer the question.
3. Form one falsifiable question at a time; follow only evidence-linked hops.
4. Stop when the claim is proved or disproved with high confidence.
5. If unresolved after the relevant path is exhausted, record `UNVERIFIED`/`UNCLEAR`, checked
   locations, missing runtime/access, and owner. Do not widen into unrelated files to appear busy.

Default reading budget: the named artifact, its direct dependencies, and one relevant analog/call
chain. Exceed it only for a cited open question, cross-repo hop, all-consumer search required by a
Spec/Requirement change, or P0 threat path. This is a relevance budget, not a shortcut.

## Change discipline

- Preserve user changes and unrelated dirty files.
- Use the smallest responsible seam; no drive-by cleanup.
- Behavior changes require RED evidence before implementation and GREEN evidence after it, unless
  the repository genuinely has no executable test surface; document that exception and substitute.
- Never claim a command, URL, file, SHA, screenshot, or human phrase was verified unless it was.

## Self-check before PASS

Score the stage on six dimensions: `competence`, `responsibility`, `reasoning`, `completeness`,
`accuracy`, `honesty`. PASS requires every dimension to have concrete evidence meeting the bar
below; do not average a weak dimension away:

- **9/10:** all required inputs/outputs and negative paths handled; conclusions trace to evidence;
  uncertainty is explicit; ownership and stop conditions are respected; deterministic checks pass.
- **8/10 or lower:** any required field is warn-only, a material claim lacks provenance, prose and
  checker disagree, an unresolved item is hidden, or the skill claims more than it verifies.

Record deficiencies rather than awarding yourself a numeric PASS. Numbers are for an independent
reviewer; the skill's job is to produce auditable evidence.

## Responsibility matrix

| Skill | Owns | Explicitly does not own |
|---|---|---|
| learning | evidence-backed project knowledge bootstrap | ticket requirements or production edits |
| coaching | confirmed knowledge delta + impact list + changelog | silently rewriting active ticket decisions |
| spec | typed/risked requirement model and testable oracles | deciding unresolved business conflicts |
| conflict | type-specific current-vs-intended analysis and decision questions | implementation or invented decisions |
| confirm | provenance of exact authorized human decisions | judging or fabricating those decisions |
| plan | executable, traceable implementation/test tasks | coding or expanding confirmed scope |
| build | scoped RED→GREEN implementation evidence | changing AC to fit code |
| review | independent diff/contract defect analysis | fixing findings or style policing |
| fix | evidence-based finding triage and narrow remediation | bulk cleanup or suppressing valid P0/P1 risk |
| test | execution evidence for every planned/coverage command | treating logs or filenames as assertions |
| check | deterministic structural/provenance enforcement | semantic judgment |
| ship | deployment-specific safety and rollback readiness | push/merge/deploy without authority |
| audit | cross-artifact semantic coherence | redoing review/conflict or passing unresolved pairs |
| status | read-only truthful state and next action | mutation or optimistic gate inference |
| clean | recoverable removal of one resolved worklog | domain knowledge, repos, or unrelated tickets |
| start | preflight and dispatch to the first owning stage | doing every stage itself or bypassing a refusal |
| feedback | confirmed dev-workflow defect reports filed as GitHub issue(s) | fixing the underlying skill or filing target-product bugs |
