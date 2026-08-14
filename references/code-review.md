# Code review (neutral)

Use with `/dev-workflow:review` and `/dev-workflow:fix`.
Goal: find **real defects in the diff**, not invent bugs from imagined framework behavior.

## Stance (required)

1. **Diff-first.** Review only changed files + call sites they touch. Cite `path:line` (or hunk) for every finding.
2. **Evidence over guess.** Do not invent syntax/API from “typical Rails/React”. If unsure how a helper works in *this* repo, open definition or mark `UNCLEAR` + ask — never force a finding.
3. **Neutral reviewer.** Ignore author intent and “looks fine” vibes. Ask: what breaks for user, ops, security, or data if this ships?
4. **No drive-by style.** Skip renames, preference nits, and speculative refactors unless they hide a P0/P1 defect.
5. **Task-scoped.** Finding must relate to ticket AC / confirmed claims / touched contracts. Out-of-scope polish → note as `OUT_OF_SCOPE`, do not block G7 alone.
6. **Follow the call chain in order when a finding needs context beyond the diff.** A changed line
   rarely explains itself in isolation — before flagging something as a defect, trace it the same
   direction execution actually runs: entrypoint (route/controller/handler) that reaches the
   changed code → the changed code itself → what it calls next. Do not open unrelated files "to
   get a feel for the codebase" or pull in a sibling module that isn't actually on the path from
   the changed line to where it's invoked or to what it invokes. If the diff is self-contained
   (the finding is visible from the hunk alone), no extra traversal is needed at all — this rule
   only applies when you genuinely need surrounding context to judge correctness.

## Severity

| Sev | Meaning | Block ship? |
|-----|---------|-------------|
| P0 | Crash/500, authz hole, injection, data loss, money wrong | Yes |
| P1 | Wrong result, missing validation, case bug that misroutes/duplicates, silent fail | Yes unless WAIVE |
| P2 | Hardening, clarity, missing test for edge already called out | Soft — list, may defer |

## Defect classes (hunt these)

Scan every changed path for these classes. Empty class → write `none` in that row of `06-review-qa.md` (do not skip the row).

### 1. 500 / crash / unhandled error

- Uncaught nil/undefined on new branch
- Rescue/catch that swallows then re-raises generic 500 with no user/ops signal
- Missing status mapping (domain error → still 500)
- N+1 or unbounded load that can timeout under real size
- Background job: no retry/dead-letter when failure expected

### 2. Missing (validation / branch / authz / feedback)

- Happy path only; no empty / invalid / forbidden / not-found branch
- Spec NEG/PERM/EDGE with no code or test path
- Authz check missing on new endpoint/action
- UI: no loading / error / empty state when Touches UI = Yes
- API contract field added/removed without client or docs update

### 3. Injection / unsafe input

- SQL/string concat, raw Arel/query with user input
- HTML/JS render of unsanitized user content (XSS)
- Shell/`system`/`exec` with interpolations
- Path/file open from user path (traversal)
- SSRF: server fetch URL from user without allowlist
- Mass-assignment / strong-params gap on new attrs

### 4. Case / locale / normalize (`downcase` / `upcase` / fold)

- Email, username, slug, token, enum, header, locale code compared without normalize
- DB unique index case-sensitive while app lowercases (or reverse) → duplicate or false miss
- Route/param/key lookup that breaks when client sends different case
- `downcase`/`upcase` without Unicode/locale care when i18n data matters
- Hash/map keys built with one case, read with another

### 5. Other high-signal (still require evidence)

- Race on create-if-missing without unique constraint
- Timezone / date boundary wrong vs AC
- Feature flag default wrong for prod
- Secrets/PII logged or returned

## Finding format (write into `06-review-qa.md`)

Each finding row:

| Field | Rule |
|-------|------|
| Sev | P0 / P1 / P2 |
| Class | `500` \| `missing` \| `injection` \| `case` \| `other` |
| Location | `path:line` or hunk id |
| Evidence | What the **diff** does (quote or paraphrase 1 line) |
| Risk | User-visible / security / data effect if shipped |
| Fix proposal | Concrete change (or test to add) — not “please improve” |
| Status | `OPEN` until `:fix` triages |

## Anti-patterns (do not do)

- “Framework usually does X so this is wrong” without opening repo code
- Blocking on style/import order/rename
- Claiming PASS when any P0/P1 finding still `OPEN`
- Inventing How/By AC evidence without steps or test id

## After review

- If any P0/P1 `OPEN` → G7 Result = FAIL; next = `/dev-workflow:fix <Ticket>`
- If only P2 or none → fill AC evidence / UI checklist; then `:test`
- Never invent G7 PASS when evidence rows lack How/By
