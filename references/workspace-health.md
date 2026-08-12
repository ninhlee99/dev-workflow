# Workspace health

Verify `~/.workspaces/<project-slug>/` is usable before ticket work.
Script: `bin/check-workspace.sh [slug]`.

## Layout (required)

```
~/.workspaces/
  [.dev-workflow.json]          # optional marker
  <slug>/
    PROJECT.md                  # required
    domain-knowledge/           # required dir
      INDEX.md                  # required for G0
    worklogs/                   # required dir (may be empty)
    repos/                      # optional; per-repo NOTES
```

## Checks (script prints PASS/FAIL)

| ID | Check |
|----|-------|
| W0 | Resolve plugin + workspaces root |
| W1 | `PROJECT.md` exists and has Slug line |
| W2 | `domain-knowledge/` + `INDEX.md` |
| W3 | `worklogs/` directory exists |
| W4 | No worklog file living **outside** `worklogs/<Ticket_ID>/` under project home |
| W5 | Each `worklogs/<Ticket_ID>/` has `INDEX.md` (warn if missing) |
| W6 | Marker `.dev-workflow.json` slug matches folder if both present (warn) |

Exit `0` only if W0–W4 PASS. W5/W6 warn-only.

## When to run

- `:learning` after create — must PASS before promote knowledge.
- `:start` / `:status` — run once; print result; FAIL → fix layout before gates.
- Manual: `"$DEV_WORKFLOW_PLUGIN/bin/check-workspace.sh" [slug]`

## Fail → fix

| Fail | Action |
|------|--------|
| W0 | Set `DEV_WORKFLOW_WORKSPACES_ROOT` or add `.dev-workflow.json` |
| W1–W3 | Re-run `:learning` or copy `templates/workspaces/_project/` |
| W4 | Move stray files into correct `worklogs/<Ticket>/` |
