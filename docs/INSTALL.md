# Install and update dev-workflow

This guide describes what is installed, how to verify it, and how to update safely. For daily
ticket usage, continue with [USER-GUIDE.md](./USER-GUIDE.md).

## Requirements

- Git
- Bash 3.2 or newer
- One or more supported hosts: Claude Code, Cursor, Codex, or Antigravity
- `agy` on `PATH` only when installing Antigravity or using `--all`

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

| Target | Command | Extra requirement |
|---|---|---|
| Claude Code (default) | `bash install.sh` or `bash install.sh --claude` | None |
| Cursor only | `bash install.sh --cursor` | None |
| Codex only | `bash install.sh --codex` | None |
| Antigravity only | `bash install.sh --agy` | `agy` on `PATH` |
| Every supported agent | `bash install.sh --all` | `agy` on `PATH` |

Long forms `--host <name>` and `--agent <name>` remain supported; `--antigravity` is an alias for
`--agy`, and `--list-hosts` prints supported values. Conflicting target flags or an unknown host
exit with status 2 and do not silently fall back to Claude.

`--all` preflights `agy` before installing any host. If `agy` is missing, it exits without a
partial Claude/Cursor/Codex installation.

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

### Cursor

```bash
bash install.sh --cursor
```

Restart/reload Cursor, then verify `/dev-workflow:status` appears.

### Codex

```bash
bash install.sh --codex
```

Start a new Codex task so it discovers the refreshed skills. Codex and Cursor both receive one live
link per workflow stage; rerun the installer after moving the clone or changing command files.

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

Finally, restart/reload the chosen host (start a new task in Codex) and verify both
`/dev-workflow:status` and `/dev-workflow:audit` are available.

## Update

From the existing clone, run the same target used during installation:

| Target | Command | Extra requirement |
|---|---|---|
| Claude Code (default) | `bash update.sh` or `bash update.sh --claude` | None |
| Cursor only | `bash update.sh --cursor` | None |
| Codex only | `bash update.sh --codex` | None |
| Antigravity only | `bash update.sh --agy` | `agy` on `PATH` |
| Every supported agent | `bash update.sh --all` | `agy` on `PATH` |

`update.sh` requires a clean Git worktree, runs `git pull --ff-only`, then invokes the installer for
the selected target. It never auto-stashes, resets, merges, or overwrites local changes. Invalid or
conflicting targets and a missing `agy` dependency are rejected before the pull. If the pull fails,
host integration is not changed. If source update succeeds but host refresh fails, rerun
`bash install.sh` with the same target after resolving the reported problem.

The default remains Claude-only. Long forms `--host <name>` and `--agent <name>` are supported.

Verify update behavior without pulling or changing real host configuration:

```bash
./tests/update.sh  # expect 6 PASS
```

## Uninstall

Uninstall uses the same target flags and defaults to Claude only:

| Target | Command | Extra requirement |
|---|---|---|
| Claude Code (default) | `bash uninstall.sh` or `bash uninstall.sh --claude` | None |
| Cursor only | `bash uninstall.sh --cursor` | None |
| Codex only | `bash uninstall.sh --codex` | None |
| Antigravity only | `bash uninstall.sh --agy` | `agy` on `PATH` |
| Every supported agent | `bash uninstall.sh --all` | `agy` on `PATH` |

Long forms `--host <name>` and `--agent <name>` are also supported. Conflicting targets are
rejected. Like installation, `--all` checks for `agy` before changing any host, preventing a
partial uninstall.

The script removes only paths owned by dev-workflow:

- Claude/Cursor colon commands and dev-workflow skill/plugin entries
- Cursor/Codex per-stage skill entries, including recognized legacy names
- Codex's local plugin and marketplace link
- The Codex marketplace file only when it still exactly matches the seed generated by installer
- The registered Antigravity plugin through `agy plugin uninstall dev-workflow`

It deliberately preserves the cloned repository, `~/.workspaces` worklogs, unrelated host files,
parent directories, and modified/existing Codex marketplace configuration. After uninstalling,
restart/reload the affected host; for Codex, start a new task.

Verify uninstall behavior without changing real host configuration:

```bash
./tests/uninstall.sh  # expect 11 PASS
```

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
| Command does not appear | Restart/reload host; start a new Codex task if applicable; rerun the matching install flag |
| Installed skill cannot read references | Keep the clone at its installed path; rerun installer after moving it |
| Update rejects a dirty repository | Commit or stash intentional changes yourself, then rerun; the updater never modifies them |
| `git pull --ff-only` fails | Resolve branch/upstream divergence manually; update deliberately avoids creating a merge commit |
| Codex plugin missing from picker | Existing `~/.agents/plugins/marketplace.json` was preserved; add the local plugin entry manually |
| `worklog not found` | Set `DEV_WORKFLOW_WORKSPACES_ROOT`, add `.dev-workflow.json`, or pass `--project` |
| Permission error | Confirm the current user owns the target host directories under its home directory |
| `agy CLI not found` | Install/configure `agy`, or choose a non-Antigravity target instead of `--agy`/`--all` |
| Antigravity content stale | Rerun `bash install.sh --agy`; it rebuilds and validates before installing |
| Codex marketplace remains after uninstall | It was not the exact installer-generated seed; inspect and edit it manually rather than allowing automated deletion |

Never delete an entire host commands, skills, plugins, marketplace, or workspaces directory when
removing dev-workflow.
