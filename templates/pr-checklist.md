# PR checklist (dev-workflow)

- **Project slug:** …
- **Ticket:** …
- **Worklog:** `workspaces/<slug>/worklogs/<Ticket>/`

## Gates

```bash
$DEV_WORKFLOW_PLUGIN/bin/check-gates.sh <Ticket> --project <slug> --min G6
```

- [ ] Checker exit 0
- [ ] G1 Scenario AC complete
- [ ] G2 every non-MATCH confirmed
- [ ] G5 coverage map no MISSING + has PASS
- [ ] G6 AC evidence How/By (UI checklist if touches UI)
- [ ] WAIVE (if any) has all INDEX fields

## Links

- Worklog INDEX: …
- PR: …
