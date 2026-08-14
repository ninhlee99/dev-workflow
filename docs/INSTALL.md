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

The installer uses the clone as the plugin source. Keep or deliberately relocate that directory;
installed symlinks point back to it.

## What the installer changes

It does not modify product source. Depending on the host, it creates or refreshes:

| Host | Paths |
|---|---|
| Claude Code | `~/.claude/commands/dev-workflow*.md`, `~/.claude/plugins/dev-workflow`, `~/.claude/skills/dev-workflow-plugin` |
| Cursor | `~/.cursor/commands/dev-workflow*.md`, `~/.cursor/skills/dev-workflow/SKILL.md` |
| Codex | `~/.codex/skills/dev-workflow-*`, `~/.codex/plugins/dev-workflow` |
| Codex marketplace | Creates `~/.agents/plugins/marketplace.json` only when that file does not already exist |
| Antigravity | Rebuilds `hosts/antigravity/`; installation is completed separately with `agy` |

Shared `references/` and `templates/` remain in the clone and are linked into installed skills.
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

Run `bash install.sh`, then restart or reload the host if commands are not refreshed immediately.
Cursor receives one pointer skill plus colon commands; Codex receives one skill per workflow stage.

### Antigravity

```bash
bash hosts/antigravity/rebuild.sh
agy plugin install ./hosts/antigravity
```

## Verify without changing your real host configuration

The install script respects `HOME`, so it can be smoke-tested in an isolated temporary home:

```bash
install_test_home="$(mktemp -d)"
HOME="$install_test_home" bash install.sh
find "$install_test_home" -maxdepth 4 -name 'dev-workflow*' -print
```

The temporary directory can be removed after inspection. This test still rebuilds the repository's
Antigravity bundle because that bundle is a repository artifact.

Run repository validation:

```bash
./tests/regression.sh

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
bash install.sh
./tests/regression.sh
```

Rerunning the installer refreshes generated command copies and skill files. It is necessary after
updates because not every installed host surface is a live symlink.

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
