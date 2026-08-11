# Security & contract (P0 required)

Fill when **Risk = P0**. Store as `02b-security.md` in the worklog (copy from this template).

- **Ticket:** [ID]
- **Date:** [YYYY-MM-DD]
- **Owner:** [name]

## Threat note (short)

- **Asset at risk:** money / authz / PII / legacy data / other: …
- **Abuse cases:** …
- **Mitigations:** …

## Secrets / PII

| Check | Status | Notes |
|---|---|---|
| No secrets in code/logs/PR | ☐ PASS ☐ FAIL | |
| PII minimized / masked | ☐ PASS ☐ N/A | |
| Authz rules reviewed | ☐ PASS ☐ N/A | |

## Multi-repo contract (if API/shared types touched)

| Consumer / provider | Contract test / pact / schema | Status |
|---|---|---|
| | | ☐ PASS ☐ N/A |

## Sign-off

- **Dev:** …
- **PM/Security (P0):** …
