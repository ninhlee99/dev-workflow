# Maturity rubric (no dimension below 9)

Scores are not self-awarded. A 9 requires the named deterministic check or inspectable evidence;
one weak dimension cannot be hidden by averaging. Apply `references/skill-quality.md` to every stage.

| Criterion | Target | Required evidence for 9 |
|---|---|---|
| Spec / conflict / confirm | ≥9 | Type+Risk enforced; provenance labels; type-specific strategy; exact claim decisions; anti-forge confirm |
| Risk lanes | ≥9 | P0/P1/P2 in checker; explicit P2 waivers; P0 dual authority + security |
| Evidence authenticity | ≥9 | RED→GREEN record; command ledger; assertion evidence; SHA↔git; parsed JUnit; reachable CI under strict |
| Security (P0) | ≥9 | threat/abuse/PII/contract evidence; named owner; no silent waiver |
| Ship / prod safety | ≥9 | deployment profile; migration-aware rollback; abort signal; rollout/rollback authority |
| Programmatic enforce | ≥9 | `check-gates.sh` + regression tests + positive/negative fixtures + required CI check |
| Measurable proof | ≥9 | `pilot-score.sh` success bar plus recorded warnings/escapes and representative risk mix |
| Adoption / token discipline | ≥9 | stage contract, relevance budget, one-owner dispatch, P2 profile-based N/A |
| Semantic coherence | ≥9 | C1–C8 present; two quotes + reason each; no UNCLEAR/INCOHERENT; human sign-off; AUDIT checker PASS |

## Org binding (required for score to hold)

1. Copy `templates/ci/github-actions-dev-workflow.yml` → product repo `.github/workflows/`.
2. Branch protection: require `dev-workflow-gates` status check.
3. Run 10-ticket pilot; `bin/pilot-score.sh` must exit 0.
