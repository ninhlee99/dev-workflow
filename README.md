# dev-workflow

**Version:** `0.1.0`  
**Goal:** Enforce clear requirements before code — no missed specs, no logic/UI bugs.

---

## Structure

```
dev-workflow/
├── commands/            # Slash commands (one per stage)
├── skills/              # Stage logic (SKILL.md per stage)
├── references/          # Shared knowledge files (loaded on demand)
├── templates/           # Artifact templates (spec, conflict, plan, …)
├── bin/
│   ├── check-gates.sh   # Programmatic gate enforcer
│   └── lib/
│       └── resolve-paths.sh  # Auto-detects project root & slug
├── hosts/antigravity/   # Antigravity-specific manifests + commands
├── .claude-plugin/      # Claude Code manifest
├── .cursor-plugin/      # Cursor manifest
├── .codex-plugin/       # Codex manifest
├── install.sh           # Installer / updater
├── plugin.json          # Agent Plugins (Cursor Cloud) manifest
└── workspaces/          # Per-project workspace (auto-created)
    └── <project-slug>/
        ├── PROJECT.md
        ├── domain-knowledge/
        ├── worklogs/<Ticket_ID>/
        └── repos/<repo-slug>/
```

---

## Installation

### Claude Code
```bash
/plugin marketplace add <path-to-plugin>
/plugin install dev-workflow@dev-workflow-marketplace
/reload-plugins
```

### Cursor / Codex / Local
```bash
bash install.sh
```

### Antigravity
```bash
bash hosts/antigravity/rebuild.sh
agy plugin install ./hosts/antigravity
```

---

## Workflow

```
learning → coaching → spec → conflict → plan → build → confirm → check → ship
```

Each stage is gated. A stage only PASS when all criteria are met.

| Gate | Criterion |
|------|-----------|
| G0 | Project knowledge exists |
| G1 | Explicit Acceptance Criteria written |
| G2 | All non-MATCH decisions documented |
| G3 | Task-to-file mapping complete |
| G4 | No OPEN QA items |
| G5 | 100 % AC → test coverage mapped |
| G6 | Acceptance evidence table filled |
| G7 | Ship artifact ready |

**WAIVE policy:** Any gate may be waived only when a worklog INDEX entry exists with: reason, owner, expiry, PM/EM sign-off.

---

## Commands

| Command | Arguments | Effect |
|---------|-----------|--------|
| `/dev-workflow:learning` | `[brief/path]` | AI self-learns project — reads codebase/docs, builds domain knowledge, stops to ask when business rule is unclear |
| `/dev-workflow:coaching` | `<topic/ticket>` | User corrects AI — add new spec, update changed rule, override misunderstood logic |
| `/dev-workflow:start` | `<Ticket ID> [URL/path/extra]` | Entry point — routes to first failing gate |
| `/dev-workflow:spec` | `<Ticket ID> [URL/path/spec]` | Normalize ticket into `02-spec.md` with ACs, edge cases, permissions |
| `/dev-workflow:conflict` | `<Ticket ID> [decision text]` | Detect spec-vs-code conflicts, produce `03-conflict-report.md` |
| `/dev-workflow:plan` | `<Ticket ID>` | Create TDD-ready impl plan (`04-plan.md`) from confirmed scope |
| `/dev-workflow:build` | `<Ticket ID>` | Implement with TDD; map each test to an AC; record in `05-impl-log.md` |
| `/dev-workflow:confirm` | `<Ticket ID>` | Verify evidence against original requirements; UI checklist; gate G6 |
| `/dev-workflow:check` | `<Ticket ID> [slug] [G5\|G6\|G7]` | Run `bin/check-gates.sh` — reports PASS/FAIL per gate |
| `/dev-workflow:ship` | `<Ticket ID>` | Prepare ship notes, PR description, `06-ship.md`; gate G7 |
| `/dev-workflow:status` | `[Ticket ID]` | Show knowledge status and current gate progress |
| `/dev-workflow` | `<Ticket ID> [URL/path/extra]` | Alias for `:start` |

---

## Enforcement

Run the gate checker directly:

```bash
export DEV_WORKFLOW_PLUGIN=/path/to/dev-workflow
"$DEV_WORKFLOW_PLUGIN/bin/check-gates.sh" <Ticket ID> --project <slug> --min G6
```

Or via AI: `/dev-workflow:check <Ticket ID>` — AI runs the checker and reports results.

---

## Path resolution

The plugin auto-discovers project context in this order:

1. `DEV_WORKFLOW_PROJECT` env var
2. `.dev-workflow.json` marker in current or parent directories
3. Git repository root → slug from `git remote get-url origin`
4. Fallback: current working directory name

Workspaces are auto-created at first run.

---

## License

MIT
