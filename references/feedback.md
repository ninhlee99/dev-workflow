# Feedback

Use when user reports a bug/complaint/pain point about using dev-workflow itself (a skill's
behavior, gate output, or generated artifact) — not the target product under test/build.

Do:
1) resolve workspace via `project-root.md`.
2) collect all feedback items raised so far this session (or since last `:feedback` run): what
   skill/stage, what happened, what was expected.
3) deduplicate against existing OPEN GitHub issues (`gh issue list`) before filing new ones.
4) ask `[FEEDBACK]` to confirm scope/title before creating each issue.
5) file via `gh issue create` on the dev-workflow plugin repo, label `feedback`.
6) report back: issue URL(s), title(s), and any item that was skipped (duplicate/declined) with
   reason.

Refuse: filing without `gh` available/authenticated, filing on a repo the user didn't confirm,
inventing failures not actually observed/reported by the user.
