# Fixtures (check-gates smoke) — v0.2.0

```bash
chmod +x bin/check-gates.sh
export DEV_WORKFLOW_WORKSPACES_ROOT="$(pwd)/fixtures"
```

| Ticket | Expect |
|---|---|
| FIX-FAIL `--min G1` | exit 1 empty AC |
| FAIL-G8-missing `--min G8` | exit 1 missing 06b |
| FAIL-G8-failing `--min G8` | exit 1 Overall FAIL |
| PASS-G8 `--min G8` | exit 0 |
| PASS-G9 `--min G9` | exit 0 |
