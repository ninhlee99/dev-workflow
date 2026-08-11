# dev-workflow (English)

Version `0.1.0`. Requirement-first workflow with multi-project workspaces and strict gate checks.

Install:
- Claude Code: `/plugin marketplace add <path>` → `/plugin install dev-workflow@dev-workflow-marketplace` → `/reload-plugins`
- Cursor/Codex/local: `bash install.sh`
- Antigravity: `bash hosts/antigravity/rebuild.sh` → `agy plugin install ./hosts/antigravity`

Core flow: `learning → coaching → spec → conflict → plan → build → confirm → /dev-workflow:check → ship`.

Gates: `G0 knowledge`, `G1 explicit AC`, `G2 non-MATCH decisions`, `G3 task mapping`, `G4 no OPEN QA`, `G5 test coverage`, `G6 acceptance evidence`, `G7 ship artifact`.
WAIVE only on worklog INDEX with reason/owner/expiry/PM note.

Workspace: `<root>/workspaces/<project-slug>/{PROJECT.md,domain-knowledge/,worklogs/<Ticket_ID>/,repos/<repo-slug>/}`.
Path resolution and constraints: `references/project-root.md`. See also [README.md](./README.md), [STRUCTURE.md](./STRUCTURE.md), [MARKETPLACE.md](./MARKETPLACE.md).
