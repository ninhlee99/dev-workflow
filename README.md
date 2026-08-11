# dev-workflow

[![Version](https://img.shields.io/badge/version-0.2.0-blue)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Hosts](https://img.shields.io/badge/hosts-Claude%20%7C%20Cursor%20%7C%20Codex%20%7C%20Antigravity-purple)](#installation)

> **Requirement-first AI workflow.** Enforce clear specs, explicit acceptance criteria, and gate-checked delivery before any code is written. Eliminates missed specs, logic bugs, and UI regressions.

---

## Table of Contents

- [How it works](#how-it-works)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Stages & commands](#stages--commands)
- [Gates](#gates)
- [Workspace layout](#workspace-layout)
- [Repository structure](#repository-structure)
- [Enforcement (CLI)](#enforcement-cli)
- [Contributing](#contributing)
- [License](#license)

---

## How it works

```
learning ──► coaching ──► spec ──► conflict ──► confirm (user sign-off) ──► plan
                                                                               │
                                                                             build
                                                                               │
                                                                            review
                                                                               │
                                                                             test (evidence)
                                                                               │
                                                                           check ──► ship
```

Each arrow is a **gate**. The AI refuses to advance until all criteria for the current gate pass — or a valid WAIVE entry exists in the worklog.

1. **learning** — AI reads the codebase and domain docs, builds a knowledge base, pauses to ask when a business rule is unclear.
2. **coaching** — Developer corrects misunderstandings or adds new/changed specs.
3. **spec** — Requirements normalised into explicit Acceptance Criteria (Scenario, Negative, Permission, Edge cases, UI states).
4. **conflict** — Every delta between spec and current code is documented with a decision, owner, and date.
5. **confirm** — AI presents all conflict decisions and spec changes to the user; user signs off explicitly before any coding starts.
6. **plan** — TDD-ready task breakdown; each task maps to an AC or conflict claim.
7. **build** — Code + tests written test-first; coverage map locked before PASS.
8. **review** — Evidence table filled (How/By/Date per AC); UI checklist if the ticket touches UI.
9. **test** — Real test suite + machine evidence (Commit SHA, CI URL / junit path) in `06b-test-evidence.md`; G8.
10. **check** — `bin/check-gates.sh` validates G0–G9 (optional `--strict`; Risk P0/P1 implies machine evidence).
11. **ship** — Ship safety (migration / flag / monitor / rollback) in `07-ship.md`; G9 PASS before merge.

---

## Prerequisites

| Requirement | Version |
|-------------|---------|
| Bash | 4+ (`brew install bash` on macOS) |
| AI host | Claude Code **or** Cursor **or** Codex **or** Antigravity |
| Git | any recent version |

---

## Installation

### Claude Code

```bash
/plugin marketplace add /path/to/dev-workflow
/plugin install dev-workflow@dev-workflow-marketplace
/reload-plugins
```

### Cursor / Codex / local

```bash
git clone git@github.com:ninhlee99/dev-workflow.git
cd dev-workflow
bash install.sh
```

`install.sh` will:
- Symlink `references/` and `templates/` into each stage skill.
- Deploy colon commands to `~/.cursor/commands/` and `~/.claude/commands/`.
- Create a thin pointer skill at `~/.cursor/skills/dev-workflow/`.
- Build the Antigravity host bundle.

### Antigravity

```bash
bash hosts/antigravity/rebuild.sh
agy plugin install ./hosts/antigravity
```

---

## Quick start

```
# 1. Teach the AI about your project (first time only)
/dev-workflow:learning

# 2. Start a ticket — AI routes to first failing gate
/dev-workflow:start TICKET-123 https://linear.app/…/TICKET-123

# 3. Step through the pipeline manually if needed
/dev-workflow:spec    TICKET-123   # write ACs
/dev-workflow:conflict TICKET-123  # detect conflicts
/dev-workflow:confirm TICKET-123   # YOU sign off on all decisions
/dev-workflow:plan    TICKET-123   # TDD-ready plan
/dev-workflow:build   TICKET-123   # implement + tests
/dev-workflow:review  TICKET-123   # fill evidence table
/dev-workflow:test    TICKET-123   # run tests + record evidence
/dev-workflow:check   TICKET-123   # programmatic gate check
/dev-workflow:ship    TICKET-123   # PR notes

# Check gate status at any time
/dev-workflow:status TICKET-123
```

The AI will create a workspace at `workspaces/<project-slug>/worklogs/TICKET-123/` and fill artifact files step by step.

---

## Stages & commands

| Command | Arguments | What it does |
|---------|-----------|--------------|
| `/dev-workflow:learning` | `[brief or path]` | AI self-learns the project: reads codebase, docs, APIs; builds `domain-knowledge/`; stops to ask on unclear business rules |
| `/dev-workflow:coaching` | `<topic or ticket>` | Developer corrects AI: add new spec, update changed rule, override wrong understanding |
| `/dev-workflow:start` | `<Ticket ID> [URL] [extra]` | Entry point — evaluates all gates and routes to the first failing one |
| `/dev-workflow:spec` | `<Ticket ID> [URL or spec]` | Normalises requirements into `02-spec.md`; **requires Risk P0/P1/P2** |
| `/dev-workflow:conflict` | `<Ticket ID> [decision]` | Detects spec-vs-code conflicts; every delta gets a decision, owner, and date in `03-conflict-report.md` |
| `/dev-workflow:confirm` | `<Ticket ID>` | Waits for human `CONFIRM G3: <Ticket> <name> <date>` (P0 also `CONFIRM G3-PM:`) — AI must not invent |
| `/dev-workflow:plan` | `<Ticket ID>` | Produces TDD-ready `04-plan.md`; each task maps to an AC/claim; requires G3 |
| `/dev-workflow:build` | `<Ticket ID>` | Implements with TDD; records AC↔test coverage map in `05-impl-log.md`; refuses coding if prior gates fail |
| `/dev-workflow:review` | `<Ticket ID>` | Fills evidence table (How/By/Date per AC) in `06-review-qa.md`; includes UI checklist when applicable (G7) |
| `/dev-workflow:test` | `<Ticket ID>` | Runs tests; records output + machine evidence (SHA/CI/junit) in `06b-test-evidence.md`; G8 |
| `/dev-workflow:check` | `<Ticket ID> [slug] [G8\|G9]` | Runs `bin/check-gates.sh` (G0–G9); supports `--strict` |
| `/dev-workflow:ship` | `<Ticket ID>` | Fills ship safety in `07-ship.md`; requires G9 PASS |
| `/dev-workflow:status` | `[Ticket ID]` | Prints current gate status and knowledge coverage |
| `/dev-workflow` | `<Ticket ID> [URL] [extra]` | Alias for `:start` |

---

## Gates

| Gate | Criterion | Blocked command |
|------|-----------|-----------------|
| **G0** | Domain knowledge exists and matches ticket scope | → `:learning` or `:coaching` |
| **G1** | Spec + **Risk P0/P1/P2** + Scenario AC (+ UI states if UI) | → `:spec` |
| **G2** | Every non-MATCH conflict has decision + owner + date | → `:conflict` |
| **G3** | Human phrase `CONFIRM G3: <Ticket> <name> <date>` on INDEX (P0 + `CONFIRM G3-PM:`) | → `:confirm` |
| **G4** | Every task in `04-plan.md` maps to an AC or conflict claim | → `:plan` |
| **G5** | `03-qa-log.md` has zero OPEN questions | → `:conflict` |
| **G6** | 100% AC/claim → test coverage map; all tests pass | → `:build` |
| **G7** | Evidence table filled (How/By/Date); UI checklist if applicable | → `:review` |
| **G8** | Test evidence + machine fields (SHA / CI URL or junit); zero failing tests | → `:test` |
| **G9** | Ship safety: migration / feature flag / monitor / rollback | → `:ship` |

### Risk lanes

See `references/risk.md`.

| Tier | Lane | Notes |
|------|------|-------|
| **P0** | Hard | Money/auth/PII/legacy — no WAIVE G3/G8; dual confirm; machine evidence mandatory |
| **P1** | Hard | Default behavior change — full G0–G9 |
| **P2** | Fast | Chore/docs — may WAIVE G2/G4/G5/G7 with INDEX rows |

Ship merge requires **G9 PASS** (`--min G9`).

### WAIVE policy

A gate may be waived only when the worklog `INDEX.md` contains a row with all five fields:

```
Gate/claim | reason | owner | expiry YYYY-MM-DD | PM note
```

**Forbidden without PM sign-off:** waiving any gate involving money flows, permission logic, or legacy data migration.

---

## Workspace layout

Auto-created on first run. Project slug is resolved from environment → `.dev-workflow.json` → git remote → cwd name.

```
workspaces/
└── <project-slug>/
    ├── PROJECT.md                  # Project overview, repos, domains
    ├── domain-knowledge/
    │   ├── INDEX.md                # Knowledge coverage tracker
    │   ├── architecture.md
    │   ├── business.md
    │   ├── glossary.md
    │   ├── changelog.md
    │   └── domains/<domain>.md
    ├── repos/
    │   └── <repo-slug>/
    │       ├── NOTES.md
    │       ├── map-flows.md
    │       ├── map-models.md
    │       └── open-questions.md
    └── worklogs/
        └── <Ticket_ID>/
            ├── INDEX.md            # Gate status + waivers
            ├── 01-intent.md
            ├── 02-spec.md
            ├── 03-conflict-report.md
            ├── 03-qa-log.md
            ├── 04-plan.md
            ├── 05-impl-log.md
            ├── 06-review-qa.md
            ├── 06b-test-evidence.md
            ├── 07-ship.md
            └── (optional) ../pilot/PILOT-v0.2.md
```

---

## Repository structure

```
dev-workflow/
├── bin/
│   ├── check-gates.sh          # Programmatic gate enforcer (exit 0=PASS, 1=FAIL, 2=error)
│   └── lib/
│       └── resolve-paths.sh    # Auto-detects project root, workspaces root, project slug
├── commands/                   # Slash command definitions (one .md per stage)
├── skills/                     # Stage logic (one SKILL.md per stage; symlinks to references/ + templates/)
├── references/                 # Shared knowledge loaded on-demand by skills
│   ├── workflow.md             # Gate table + dispatch rules
│   ├── risk.md                 # P0/P1/P2 hard/fast lanes
│   ├── project-root.md         # Path resolution algorithm
│   ├── learning.md             # learning stage rules
│   ├── coaching.md             # coaching stage rules
│   ├── conflict-check.md       # conflict detection steps
│   └── enforce.md              # Enforcement policy
├── templates/                  # Artifact templates (filled by AI per ticket)
├── hosts/
│   └── antigravity/            # Antigravity-specific bundle (built by rebuild.sh)
├── fixtures/
│   └── workspaces/demo/        # Example workspace for gate checker smoke tests
├── .claude-plugin/             # Claude Code marketplace manifest
├── .cursor-plugin/             # Cursor marketplace manifest
├── .codex-plugin/              # Codex manifest
├── plugin.json                 # Agent Plugins (Cursor Cloud) manifest
├── install.sh                  # Installer — wires symlinks + deploys commands to host tools
├── CHANGELOG.md
├── CONTRIBUTING.md
├── MARKETPLACE.md
└── STRUCTURE.md
```

---

## Enforcement (CLI)

Run the gate checker directly from the terminal, independently of any AI:

```bash
export DEV_WORKFLOW_PLUGIN=/path/to/dev-workflow
"$DEV_WORKFLOW_PLUGIN/bin/check-gates.sh" TICKET-123 --project my-project --min G9 --strict
```

Or via AI:

```
/dev-workflow:check TICKET-123
```

**Exit codes:** `0` = PASS, `1` = FAIL, `2` = usage/path error.

**Flags:**

| Flag | Default | Description |
|------|---------|-------------|
| `--project <slug>` | auto-detect | Override project slug |
| `--min <Gx>` | `G8` | Check through gate (`G0`–`G9`); use `G9` before merge |
| `--strict` | off | Reject G8 WAIVE; require machine evidence + UI screenshots; reject thin output |
| `--json` | off | JSON for CI |

**CI example:**

```yaml
- name: Gate check
  run: |
    ./bin/check-gates.sh ${{ env.TICKET_ID }} \
      --project ${{ env.PROJECT_SLUG }} \
      --min G9 \
      --strict \
      --json
```

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for development workflow, adding stages, gate editing guidelines, commit conventions, and release steps.

---

## License

[MIT](LICENSE)
