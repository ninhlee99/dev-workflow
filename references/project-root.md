# Resolve project paths

Never hardcode customer paths. Resolve from cwd/git/marker/brief.

Layout (preferred):
`~/.workspaces/<project-slug>/{PROJECT.md,domain-knowledge/,worklogs/<Ticket_ID>/,repos/<repo-slug>/}`

Legacy layout still readable:
`<root>/workspaces/<project-slug>/...`

Resolve order (same as `bin/lib/resolve-paths.sh`):
1) plugin dir: `DEV_WORKFLOW_PLUGIN` → known symlinks → running script dir.
2) workspaces root: `DEV_WORKFLOW_WORKSPACES_ROOT` → `~/.workspaces` (default) → cwd walk-up (`.workspaces/`, `workspaces/`, `.dev-workflow.json`) → `DEV_WORKFLOW_EXTRA_WORKSPACE_ROOTS`.
3) project slug: explicit arg/env → `.dev-workflow.json` (`projectSlug`/`slug`) → existing `PROJECT.md` whose Repos table matches cwd → single existing workspace → slugified git/cwd name → ask once if ambiguous.
Slug is always the real repo/org name — never a name invented from a brief's feature
description (see `references/learning.md` § Choosing the slug). Honor an explicit user-requested
slug over the default.

Rules: print `project=<slug> home=<path> ticket=<id> worklog=<path> locale=<code>` at each stage start; keep artifacts outside project repo by default (under `~/.workspaces`) unless user explicitly overrides.
Validate with `bin/check-workspace.sh`. Isolate tickets per `references/task-isolation.md`. Clean finished tickets with `bin/clean-worklog.sh` / `:clean`.
