# dev-workflow（日本語）

Version `0.1.0`。実装前に要件を明確化し、ゲートを強制するワークフローです。

インストール:
- Claude Code: `/plugin marketplace add <path>` → `/plugin install dev-workflow@dev-workflow-marketplace` → `/reload-plugins`
- Cursor/Codex/ローカル: `bash install.sh`
- Antigravity: `bash hosts/antigravity/rebuild.sh` → `agy plugin install ./hosts/antigravity`

主フロー: `learning → coaching → spec → conflict → plan → build → confirm → /dev-workflow:check → ship`。

ゲート: `G0 知識`, `G1 明確なAC`, `G2 non-MATCHの決定`, `G3 タスク対応`, `G4 OPENなし`, `G5 テスト網羅`, `G6 受入証跡`, `G7 出荷成果物`。
WAIVE は worklog INDEX のみ（reason/owner/expiry/PM note）。

Workspace: `<root>/workspaces/<project-slug>/{PROJECT.md,domain-knowledge/,worklogs/<Ticket_ID>/,repos/<repo-slug>/}`。
パス解決: `references/project-root.md`。関連: [README.md](./README.md), [STRUCTURE.md](./STRUCTURE.md), [MARKETPLACE.md](./MARKETPLACE.md)。
