# dev-workflow

[![Version](https://img.shields.io/badge/version-0.1.0-blue)](CHANGELOG.md)
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
learning ──► coaching ──► spec ──► conflict ──► plan
                                                  │
                                                build
                                                  │
                                               confirm
                                                  │
                                              check ──► ship
```

Each arrow is a **gate**. The AI refuses to advance until all criteria for the current gate pass — or a valid WAIVE entry exists in the worklog.

1. **learning** — AI reads the codebase and domain docs, builds a knowledge base, pauses to ask when a business rule is unclear.
2. **coaching** — Developer corrects misunderstandings or adds new/changed specs.
3. **spec** — Requirements normalised into explicit Acceptance Criteria (Scenario, Negative, Permission, Edge cases, UI states).
4. **conflict** — Every delta between spec and current code is documented with a decision, owner, and date.
5. **plan** — TDD-ready task breakdown; each task maps to an AC or conflict claim.
6. **build** — Code + tests written test-first; coverage map locked before PASS.
7. **confirm** — Evidence table filled (How/By/Date per AC); UI checklist if the ticket touches UI.
8. **check** — `bin/check-gates.sh` runs programmatic gate validation.
9. **ship** — Ship notes and PR description drafted from the confirmed worklog.

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

# 3. If learning is complete, jump straight to spec
/dev-workflow:spec TICKET-123 https://linear.app/…/TICKET-123

# 4. Check gate status at any time
/dev-workflow:status TICKET-123

# 5. Run programmatic gate checker before ship
/dev-workflow:check TICKET-123
```

The AI will create a workspace at `workspaces/<project-slug>/worklogs/TICKET-123/` and fill artifact files step by step.

---

## Stages & commands

| Command | Arguments | What it does |
|---------|-----------|--------------|
| `/dev-workflow:learning` | `[brief or path]` | AI self-learns the project: reads codebase, docs, APIs; builds `domain-knowledge/`; stops to ask on unclear business rules |
| `/dev-workflow:coaching` | `<topic or ticket>` | Developer corrects AI: add new spec, update changed rule, override wrong understanding |
| `/dev-workflow:start` | `<Ticket ID> [URL] [extra]` | Entry point — evaluates all gates and routes to the first failing one |
| `/dev-workflow:spec` | `<Ticket ID> [URL or spec]` | Normalises requirements into `02-spec.md` with full AC table (Scenario + NEG/PERM/EDGE + UI states) |
| `/dev-workflow:conflict` | `<Ticket ID> [decision]` | Detects spec-vs-code conflicts; every delta gets a decision, owner, and date in `03-conflict-report.md` |
| `/dev-workflow:plan` | `<Ticket ID>` | Produces TDD-ready `04-plan.md`; each task maps to an AC/claim |
| `/dev-workflow:build` | `<Ticket ID>` | Implements with TDD; records AC↔test coverage map in `05-impl-log.md`; refuses coding if prior gates fail |
| `/dev-workflow:confirm` | `<Ticket ID>` | Fills evidence table (How/By/Date per AC) in `06-review-qa.md`; includes UI checklist when applicable |
| `/dev-workflow:check` | `<Ticket ID> [slug] [G5\|G6\|G7]` | Runs `bin/check-gates.sh`; reports PASS/FAIL per gate with actionable messages |
| `/dev-workflow:ship` | `<Ticket ID>` | Drafts ship notes and PR description in `07-ship.md`; requires G6 PASS |
| `/dev-workflow:status` | `[Ticket ID]` | Prints current gate status and knowledge coverage |
| `/dev-workflow` | `<Ticket ID> [URL] [extra]` | Alias for `:start` |

---

## Gates

| Gate | Criterion | Blocked command |
|------|-----------|-----------------|
| **G0** | Domain knowledge exists and matches ticket scope | → `:learning` or `:coaching` |
| **G1** | `02-spec.md` has Scenario AC + NEG + PERM + EDGE (+ UI states if UI ticket) | → `:spec` |
| **G2** | Every non-MATCH conflict has decision + owner + date | → `:conflict` |
| **G3** | Every task in `04-plan.md` maps to an AC or conflict claim | → `:plan` |
| **G4** | `03-qa-log.md` has zero OPEN questions | → `:conflict` |
| **G5** | 100% AC/claim → test coverage map; all tests pass | → `:build` |
| **G6** | Evidence table filled (How/By/Date) for all ACs; UI checklist done if applicable | → `:confirm` |
| **G7** | `07-ship.md` complete with release evidence and PR notes | → `:ship` |

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
            └── 07-ship.md
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
"$DEV_WORKFLOW_PLUGIN/bin/check-gates.sh" TICKET-123 --project my-project --min G6
```

Or via AI (runs the same script, reports results in chat):

```
/dev-workflow:check TICKET-123
```

**Exit codes:** `0` = PASS, `1` = FAIL, `2` = usage/path error.

**Flags:**

| Flag | Default | Description |
|------|---------|-------------|
| `--project <slug>` | auto-detect | Override project slug |
| `--min <Gx>` | `G6` | Minimum gate to check through |
| `--json` | off | Output JSON for CI integration |

**CI integration example (GitHub Actions):**

```yaml
- name: Gate check
  run: |
    ./bin/check-gates.sh ${{ env.TICKET_ID }} \
      --project ${{ env.PROJECT_SLUG }} \
      --min G5 \
      --json
```

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for development workflow, adding stages, gate editing guidelines, commit conventions, and release steps.

---

## License

[MIT](LICENSE)
