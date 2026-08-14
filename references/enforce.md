# Enforce (operators)

## Pre-merge (required)

```bash
export DEV_WORKFLOW_PLUGIN=/path/to/dev-workflow
"$DEV_WORKFLOW_PLUGIN/bin/check-gates.sh" <Ticket> \
  --project <slug> --min G9 --strict
```

| Flag | Effect |
|------|--------|
| `--min G9` | Include ship safety |
| `--strict` | SHA↔git, junit parse, no P2 soft, no G8 WAIVE; **implies `--verify-net`** |
| `--verify-net` | HTTP HEAD on CI URL |
| `--json` | CI machine output |

Exit: `0` PASS · `1` FAIL · `2` path/usage error.

For P0/P1, G9 is only the structural floor. After `:audit` and human `AUDIT CONFIRM:`, run the
final check:

```bash
"$DEV_WORKFLOW_PLUGIN/bin/check-gates.sh" <Ticket> \
  --project <slug> --min AUDIT --strict
```

## G3 anti-forge

PASS only if:

1. `INDEX.md` has `CONFIRM G3: <Ticket> <Human> <YYYY-MM-DD>`  
2. `03b-human-confirm.md` has the same phrase + `Source: user-message`  
3. Name is not AI/ChatGPT/Claude/Copilot/Cursor/Assistant/Bot  
4. P0 also has `CONFIRM G3-PM:…` in both places  

## Org binding

1. Copy `templates/ci/github-actions-dev-workflow.yml` → product `.github/workflows/`  
2. Require check name `dev-workflow-gates`  
3. After pilot: `bin/pilot-score.sh workspaces/<slug>/pilot/PILOT-v0.4.md`  

See [docs/USER-GUIDE.md](../docs/USER-GUIDE.md) and [maturity.md](./maturity.md).
