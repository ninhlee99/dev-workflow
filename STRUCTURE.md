# Structure — dev-workflow v0.4

Annotated layout. **Edit** `references/` and `templates/` only; re-run `bash install.sh` to refresh skill symlinks.

---

## Tree

```
dev-workflow/
├── bin/
│   ├── check-gates.sh              # G0–G9 enforcer (PASS/FAIL)
│   ├── pilot-score.sh              # 10-ticket measurable success bar
│   └── lib/resolve-paths.sh        # Project/workspace/slug resolution
│
├── commands/                       # Slash commands (Cursor / Claude)
│   ├── dev-workflow.md             # alias → :start
│   └── dev-workflow:<stage>.md     # one file per stage
│
├── skills/<stage>/SKILL.md         # Stage instructions (AI)
│   ├── references/ → ../../references
│   └── templates/  → ../../templates
│
├── references/                     # Shared rules (load on demand)
│   ├── workflow.md                 # Gate table + stage order
│   ├── risk.md                     # P0/P1/P2 + timeboxes
│   ├── security.md                 # P0 02b-security
│   ├── pilot.md                    # Pilot ops
│   ├── maturity.md                 # Expert rubric (≥8)
│   ├── enforce.md                  # Checker flags
│   ├── project-root.md             # Path resolution
│   ├── learning.md / coaching.md
│   └── conflict-check.md
│
├── templates/                      # Filled per ticket / project
│   ├── INDEX.md
│   ├── 01-intent.md … 07-ship.md
│   ├── 02b-security.md             # P0
│   ├── 03b-human-confirm.md        # G3 anti-forge
│   ├── 06b-test-evidence.md        # G8
│   ├── pilot-metrics.md
│   ├── gate-checklist.md / pr-checklist.md
│   ├── ci/github-actions-dev-workflow.yml
│   ├── domain-knowledge/
│   └── workspaces/_project|/_repo/
│
├── docs/
│   └── USER-GUIDE.md               # Day-to-day usage (start here for humans)
│
├── fixtures/workspaces/demo/       # Checker smoke data + sample pilot
├── hosts/antigravity/              # Antigravity bundle
├── .claude-plugin/ .cursor-plugin/ .codex-plugin/
├── plugin.json
├── install.sh
├── README.md MARKETPLACE.md CONTRIBUTING.md CHANGELOG.md
└── LICENSE
```

**Stages in `install.sh`:**  
`start learning coaching spec conflict confirm plan build review test check ship status`

---

## Worklog artifacts ↔ gates

| Template | Gate |
|----------|------|
| domain-knowledge / PROJECT.md | G0 |
| `02-spec.md` (+ `02b-security.md` if P0) | G1 |
| `03-conflict-report.md` | G2 |
| `03b-human-confirm.md` + INDEX CONFIRM | G3 |
| `04-plan.md` | G4 |
| `03-qa-log.md` (no OPEN) | G5 |
| `05-impl-log.md` | G6 |
| `06-review-qa.md` | G7 |
| `06b-test-evidence.md` | G8 |
| `07-ship.md` | G9 |

---

## Design principles

1. **Single source of truth** — root `references/` + `templates/` only.  
2. **Load on demand** — skills list only needed refs (token discipline).  
3. **Neutral paths** — no hardcoded customer repos; resolve via env/marker/git.  
4. **Programmatic truth** — `check-gates.sh` / `pilot-score.sh`, not AI self-claim.
