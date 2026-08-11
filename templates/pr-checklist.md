# PR checklist (dev-workflow) v0.2.0

- **Project slug:** …
- **Ticket:** …
- **Risk:** P0 / P1 / P2
- **Worklog:** `workspaces/<slug>/worklogs/<Ticket>/`

## Gates

```bash
$DEV_WORKFLOW_PLUGIN/bin/check-gates.sh <Ticket> --project <slug> --min G9 --strict
```

- [ ] Checker exit 0 (`--min G9`)
- [ ] Risk set; lane chosen
- [ ] G3 has human `CONFIRM G3:` (P0 also `CONFIRM G3-PM:`)
- [ ] G8 machine evidence (SHA + CI URL or junit path)
- [ ] G9 ship safety (migration / flag / monitor / rollback)
- [ ] WAIVE rows complete if any (forbidden on P0 G3/G8)

## Links

- Worklog INDEX: …
- PR: …
- Pilot row (optional): …
