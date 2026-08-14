# Install and update dev-workflow

This guide describes what is installed, how to verify it, and how to update safely. For daily
ticket usage, continue with [USER-GUIDE.md](./USER-GUIDE.md).

## Requirements

- Git
- Bash 3.2 or newer
- One or more supported hosts: Claude Code, Cursor, Codex, Antigravity

Check Bash before installing:

```bash
bash --version
```

## Clone and install

```bash
git clone https://github.com/ninhlee99/dev-workflow.git
cd dev-workflow
bash install.sh
```

With no option, only Claude Code is installed. Select exactly one coding agent or all:

```bash
bash install.sh --claude                # same as the default
bash install.sh --cursor
bash install.sh --codex
bash install.sh --agy                   # Antigravity
bash install.sh --all
```

Long forms `--host <name>` and `--agent <name>` remain supported; `--antigravity` is an alias for
`--agy`, and `--list-hosts` prints supported values. Conflicting target flags or an unknown host
exit with status 2 and do not silently fall back to Claude.

The installer uses the clone as the plugin source. Keep or deliberately relocate that directory;
installed symlinks point back to it.

## What the installer changes

It does not modify product source. Depending on the host, it creates or refreshes:

| Host | Paths |
|---|---|
| Claude Code | `~/.claude/commands/dev-workflow*.md`, `~/.claude/plugins/dev-workflow`, `~/.claude/skills/dev-workflow-plugin` |
| Cursor | `~/.cursor/commands/dev-workflow*.md`, all `~/.cursor/skills/dev-workflow-*` stage links |
| Codex | all `~/.codex/skills/dev-workflow-*` stage links, `~/.codex/plugins/dev-workflow` |
| Codex marketplace | Creates `~/.agents/plugins/marketplace.json` only when that file does not already exist |
| Antigravity | Rebuilds and validates `hosts/antigravity/`, then runs `agy plugin install` |

All 16 stage skills are installed for Cursor/Codex, not a thin pointer. Shared `references/` and
`templates/` remain in the clone and are linked into every stage.
Existing unrelated commands, skills, plugins, and an existing Codex marketplace file are preserved.

## Host-specific alternatives

### Claude Code marketplace

Inside Claude Code:

```text
/plugin marketplace add https://github.com/ninhlee99/dev-workflow
/plugin install dev-workflow@dev-workflow-marketplace
/reload-plugins
```

The local installer also supports loading the clone directly:

```bash
claude --plugin-dir /absolute/path/to/dev-workflow
```

### Cursor and Codex

Run the matching shorthand flag. Cursor and Codex both receive one live link per workflow stage; rerun the
installer after moving the clone or changing command files. Restart/reload the host afterward.

### Antigravity

```bash
bash install.sh --agy
```

This requires `agy` on `PATH`. The installer stops if it is absent and validates the bundle before
registration.

## Verify without changing your real host configuration

The install script respects `HOME`, so it can be smoke-tested in an isolated temporary home:

```bash
install_test_home="$(mktemp -d)"
HOME="$install_test_home" bash install.sh --cursor
find "$install_test_home" -maxdepth 4 -name 'dev-workflow*' -print
```

The temporary directory can be removed after inspection. Cursor/Codex/Claude isolated tests do not
touch another host. Use `tests/install.sh` to exercise Antigravity with a fake `agy` registry.

Run repository validation:

```bash
./tests/regression.sh
./tests/install.sh

export DEV_WORKFLOW_WORKSPACES_ROOT="$(pwd)/fixtures"
./bin/check-gates.sh FIX-FAIL --project demo --min G1          # expect FAIL
./bin/check-gates.sh PASS-G8 --project demo --min G8           # expect PASS
./bin/check-gates.sh PASS-G9 --project demo --min G9 --strict  # expect PASS
./bin/pilot-score.sh fixtures/workspaces/demo/pilot/PILOT-v0.4.md
```

Finally, restart/reload the chosen host and verify both `/dev-workflow:status` and
`/dev-workflow:audit` are available.

## Update

From the existing clone:

```bash
git pull --ff-only
bash install.sh --host <the-agent-you-use>
./tests/regression.sh
./tests/install.sh
```

Rerunning the installer refreshes command copies and repairs live skill links. The default remains
Claude-only, so use the same explicit host—or `all`—that you intend to update.

## Product workspace setup

Installation and project setup are separate. In a product repository, optionally add:

```json
{ "projectSlug": "my-app" }
```

Save it as `.dev-workflow.json`. For organization enforcement, copy
`templates/ci/github-actions-dev-workflow.yml` to the product repository's `.github/workflows/`
directory and require the `dev-workflow-gates` status check.

Worklogs default to `~/.workspaces/<project-slug>/`, outside product source.

## Troubleshooting

| Problem | Check |
|---|---|
| Command does not appear | Restart/reload host; confirm its command path above; rerun `bash install.sh` |
| Installed skill cannot read references | Keep the clone at its installed path; rerun installer after moving it |
| Codex plugin missing from picker | Existing `~/.agents/plugins/marketplace.json` was preserved; add the local plugin entry manually |
| `worklog not found` | Set `DEV_WORKFLOW_WORKSPACES_ROOT`, add `.dev-workflow.json`, or pass `--project` |
| Permission error | Confirm the current user owns the target host directories under its home directory |
| Antigravity content stale | Run `bash hosts/antigravity/rebuild.sh` before `agy plugin install` |

The installer has no destructive uninstall command. To remove it, inspect the exact host paths in
the table above and remove only entries named `dev-workflow`; do not delete an entire host commands,
skills, plugins, or marketplace directory.
