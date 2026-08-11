# Fixtures — v0.4.0

```bash
export DEV_WORKFLOW_WORKSPACES_ROOT="$(pwd)/fixtures"
./bin/check-gates.sh PASS-G8 --project demo --min G8          # exit 0
./bin/check-gates.sh PASS-G9 --project demo --min G9 --strict # exit 0
./bin/pilot-score.sh fixtures/workspaces/demo/pilot/PILOT-v0.4.md  # exit 0
```
