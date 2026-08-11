# PR checklist (dev-workflow)

- **Project slug:** …
- **Ticket:** …
- **Worklog:** `workspaces/<slug>/worklogs/<Ticket>/`

## Gates

```bash
$DEV_WORKFLOW_PLUGIN/bin/check-gates.sh <Ticket> --project <slug> --min G8 --strict
```

- [ ] Checker exit 0
- [ ] G1 Scenario AC complete
- [ ] G2 every non-MATCH decided
- [ ] G3 user sign-off on INDEX
- [ ] G6 coverage map no MISSING + has PASS
- [ ] G7 AC evidence How/By (UI checklist if touches UI)
- [ ] G8 test evidence recorded; zero failures
- [ ] WAIVE (if any) has all INDEX fields (not under `--strict` G8 ban)

## Links

- Worklog INDEX: …
- PR: …
