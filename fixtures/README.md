# Fixtures (check-gates smoke)

## FAIL G1 (empty AC)

```bash
chmod +x bin/check-gates.sh
DEV_WORKFLOW_WORKSPACES_ROOT="$(pwd)/fixtures" \
  ./bin/check-gates.sh FIX-FAIL --project demo --min G1
# expect exit 1 — "no filled AC-xx row"
```

Optional PASS path: fill Given/When/Then on `AC-01` (and later gates artifacts) under a copy of this worklog; not required for v1.6 smoke.
