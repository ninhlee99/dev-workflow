---
name: test
description: >-
  Run tests; record machine evidence. Under --strict/P0, checker verifies
  SHA vs git HEAD and junit file contents.
argument-hint: "<Ticket ID> Run after review — fill 06b-test-evidence.md"
arguments: [ticket_id]
disable-model-invocation: true
---

# /dev-workflow:test

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

1. Refuse if `06-review-qa.md` still has P0/P1 Status=`OPEN` — run `/dev-workflow:fix` first.
2. Fill `06b-test-evidence.md` (output + SHA + CI URL or junit path).
3. Prefer real junit/xml path so `--strict` can parse failures=0.
4. Run `/dev-workflow:check <Ticket> [slug] G8` (add `--strict` before merge path).
5. Zero failing tests required.

## Non-strict vs `--strict` — what actually changes

Non-strict (default): checker verifies the evidence file's *shape* — SHA present and
plausible-looking, a CI URL or junit path filled in, no failing-suite row. It does not open the
junit file or check the SHA against git.

`--strict` (required before merge): checker actually opens the junit/log file and searches for
`failures="[1-9]` / `<error`, and confirms the Commit SHA matches `git rev-parse HEAD` in this
repo right now. A stale SHA (yesterday's commit, evidence pasted from a different branch) passes
non-strict and fails `--strict` — that gap is the whole point of running `--strict` before merge
instead of trusting the non-strict pass from earlier in the loop.

Run non-strict while iterating; always run `--min G9 --strict` as the actual pre-merge gate.
