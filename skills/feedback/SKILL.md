---
name: feedback
description: >-
  User reports a bug/pain point about dev-workflow itself while using it.
  Aggregates issues raised, dedupes, and files GitHub issue(s) via gh, then
  reports back URL(s). Use /dev-workflow:feedback.
argument-hint: "[free text] — describe what went wrong; omit to aggregate what was already raised this session"
arguments: [description]
disable-model-invocation: false
---

# /dev-workflow:feedback

Apply `references/skill-quality.md`; this stage owns filed GitHub issue(s) for confirmed
dev-workflow defects and its report-back, not fixing the underlying skill.

If first `/dev-workflow:*` command in this workspace, ask `[LOCALE]` per `references/locale.md`
before anything else.

Use when user complains about dev-workflow's own behavior (a skill, gate, or generated artifact) —
not the target product the ticket is building. Read `references/feedback.md`.

## Steps

1. Collect: use the description argument plus any feedback already raised earlier this
   conversation (skill name, expected vs actual, evidence — quote/log/artifact path).
2. Verify `gh auth status`; if not authenticated, stop and tell user how to fix.
3. `gh issue list --repo ninhlee99/dev-workflow --state open --search "<keywords>"` to check for an
   existing duplicate before filing.
4. Ask `[FEEDBACK]` to confirm each issue's title/body before creating — never file silently.
5. For each confirmed, non-duplicate item:
   ```bash
   gh issue create --repo ninhlee99/dev-workflow --title "<title>" --label feedback --body "<body>"
   ```
   Body must include: skill/command affected, expected behavior, actual behavior, repro
   steps/evidence, ticket/workspace context if relevant.
6. Report back a table: item → filed URL, or item → skipped + reason (duplicate of #N, declined).

## Refuse

- No concrete failure described (vague "not great") — ask for specifics first.
- `gh` unavailable/unauthenticated.
- Filing to any repo other than the confirmed target.
- Treating a target-product bug (not dev-workflow's own behavior) as feedback — route that to the
  user's own tracker instead.
