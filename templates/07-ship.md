# 07 Ship: [Feature_Name]

- **PR:** [url]
- **Ticket:** [ID]
- **Risk:** ☐ P0 ☐ P1 ☐ P2
- **Commit SHA:** [sha]
- **Deployment profile:** ☐ web/service ☐ worker ☐ library/package ☐ mobile/desktop ☐ docs/config ☐ custom: …
- **Rollout / rollback authority:** [human role/name]
- **Checker:** `check-gates.sh --min G9 --strict` exit 0 ☐

## Pre-merge

- [ ] G0–G8 PASS (or valid INDEX WAIVE; P0: no G3/G8 WAIVE)
- [ ] G8 machine evidence verified (SHA / CI / junit)
- [ ] CI green on PR
- [ ] Worklog link in PR description
- [ ] P0: `02b-security.md` PASS
- [ ] Coverage gap ritual closed

## Ship safety (G9 — required)

### Migration / data

- **Has migration?** ☐ Yes ☐ No
- **Backward compatible / expand-contract?** ☐ Yes ☐ No ☐ N/A
- **Notes:** …

### Feature flag / dark launch

- **Flag name / N/A:** …
- **Default off in prod?** ☐ Yes ☐ N/A
- **Rollout plan:** …

### Canary / soak

- **Canary %:** … (or N/A + reason)
- **Soak time before 100%:** … (e.g. 30m / 24h)
- **Abort criteria:** …
- **Observable abort signal:** …

### Monitor / alert / SLO

- **Dashboard or log query:** …
- **Alert / owner on-call:** …
- **SLO / error-budget note:** … (or N/A)
- **First 24h watch:** …

### Rollback

- **Rollback steps:** …
- **Data repair needed?** ☐ Yes ☐ No
- **Time-to-rollback estimate:** …

**G9 FAIL** (P0/P1) if canary/soak/on-call/rollback still `…`.  
P2 may mark N/A with reason.

## Deploy notes

- …

## Links

- Worklog INDEX: …
- Test evidence: `06b-test-evidence.md`
- Security (P0): `02b-security.md`
- Pilot row (if in pilot): …
