# Enforce

```bash
./bin/check-gates.sh <Ticket> --project <slug> --min G9 --strict
./bin/pilot-score.sh workspaces/<slug>/pilot/PILOT-v0.4.md
```

- `--strict` implies `--verify-net`.
- G3: INDEX + `03b-human-confirm.md` (Source: user-message; no AI names).
- Org: copy `templates/ci/github-actions-dev-workflow.yml` → required status check.
- Rubric: `references/maturity.md`.
