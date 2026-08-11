# Enforce

Never claim G5/G6/G7 PASS without real checker run. Exit code drives verdict.

```bash
/dev-workflow:check <Ticket> [slug] [G5|G6|G7]
"$DEV_WORKFLOW_PLUGIN/bin/check-gates.sh" <Ticket> [--project <slug>] --min G5|G6|G7
```

Exit: `0=PASS or valid WAIVE`, `1=FAIL`, `2=path/worklog error`.
Resolve paths from cwd/git via `project-root.md`. WAIVE allowed only on worklog INDEX.
