# dev-workflow (Tiếng Việt)

Version `0.1.0`. Quy trình ưu tiên làm rõ yêu cầu trước khi code, có gate check bắt buộc.

Cài đặt:
- Claude Code: `/plugin marketplace add <path>` → `/plugin install dev-workflow@dev-workflow-marketplace` → `/reload-plugins`
- Cursor/Codex/local: `bash install.sh`
- Antigravity: `bash hosts/antigravity/rebuild.sh` → `agy plugin install ./hosts/antigravity`

Luồng chính: `learning → coaching → spec → conflict → plan → build → confirm → /dev-workflow:check → ship`.

Gate: `G0 knowledge`, `G1 AC rõ`, `G2 quyết định non-MATCH`, `G3 map task`, `G4 không OPEN`, `G5 coverage test`, `G6 evidence nghiệm thu`, `G7 ship artifact`.
WAIVE chỉ ghi ở INDEX worklog (reason/owner/expiry/PM note).

Workspace: `<root>/workspaces/<project-slug>/{PROJECT.md,domain-knowledge/,worklogs/<Ticket_ID>/,repos/<repo-slug>/}`.
Chi tiết resolve path: `references/project-root.md`. Xem thêm [README.md](./README.md), [STRUCTURE.md](./STRUCTURE.md), [MARKETPLACE.md](./MARKETPLACE.md).
