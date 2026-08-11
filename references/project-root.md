# Resolve project paths

Never hardcode customer paths. Resolve from cwd/git/marker/brief.

Layout:
`<root>/workspaces/<project-slug>/{PROJECT.md,domain-knowledge/,worklogs/<Ticket_ID>/,repos/<repo-slug>/}`

Resolve order (same as `bin/lib/resolve-paths.sh`):
1) plugin dir: `DEV_WORKFLOW_PLUGIN` → known symlinks → running script dir.
2) workspaces root: `DEV_WORKFLOW_WORKSPACES_ROOT` → cwd walk-up (`workspaces/` or `.dev-workflow.json` or legacy marker) → git root+parent → `DEV_WORKFLOW_EXTRA_WORKSPACE_ROOTS` → fallback parent-of-git/cwd.
3) project slug: explicit arg/env → `.dev-workflow.json` (`projectSlug`/`slug`) → single existing workspace → slugified git/cwd name → ask once if ambiguous.

Rules: print `project=<slug> home=<path>` at each stage start; prefer existing home; keep artifacts outside child repos unless user asks.
