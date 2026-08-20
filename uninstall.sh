#!/usr/bin/env bash
# Uninstall dev-workflow from one coding agent, or all supported agents.
set -euo pipefail

STAGES=(decompose start learning coaching spec clarify confirm plan build review fix test check ship audit status clean feedback)
TARGET_HOST="claude"
TARGET_EXPLICIT=0
PROJECT_CLAUDE_CMDS="${DEV_WORKFLOW_PROJECT_CLAUDE_COMMANDS:-}"

usage() {
  cat <<'EOF'
Usage: bash uninstall.sh [--claude|--cursor|--codex|--agy|--all]
       bash uninstall.sh [--host|--agent] claude|cursor|codex|antigravity|all

Default: claude

Options:
  --claude               Uninstall only from Claude Code
  --cursor               Uninstall only from Cursor
  --codex                Uninstall only from Codex
  --agy, --antigravity   Uninstall only from Antigravity
  --all                  Uninstall from every supported coding agent
  --host, --agent <name>  Uninstall only from that coding agent, or all
  --list-hosts            Print supported coding agents
  -h, --help              Show this help

Examples:
  bash uninstall.sh                         # Claude only
  bash uninstall.sh --cursor                # Cursor only
  bash uninstall.sh --codex                 # Codex only
  bash uninstall.sh --agy                   # Antigravity only
  bash uninstall.sh --all                   # Every supported agent
EOF
}

select_target() {
  local requested="$1"
  if [[ "$TARGET_EXPLICIT" -eq 1 && "$TARGET_HOST" != "$requested" ]]; then
    echo "ERROR: conflicting uninstall targets '$TARGET_HOST' and '$requested'; choose exactly one target" >&2
    usage >&2
    exit 2
  fi
  TARGET_HOST="$requested"
  TARGET_EXPLICIT=1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host|--agent)
      [[ $# -ge 2 ]] || { echo "ERROR: $1 requires a host" >&2; usage >&2; exit 2; }
      select_target "$2"
      shift 2
      ;;
    --claude) select_target claude; shift ;;
    --cursor) select_target cursor; shift ;;
    --codex) select_target codex; shift ;;
    --agy|--antigravity) select_target antigravity; shift ;;
    --all) select_target all; shift ;;
    --list-hosts)
      echo "claude cursor codex antigravity all"
      exit 0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    claude|cursor|codex|antigravity|all)
      select_target "$1"
      shift
      ;;
    *)
      echo "ERROR: unsupported host '$1'" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$TARGET_HOST" in
  claude|cursor|codex|antigravity|all) ;;
  *) echo "ERROR: unsupported host '$TARGET_HOST'" >&2; usage >&2; exit 2 ;;
esac

if [[ "$TARGET_HOST" == "antigravity" || "$TARGET_HOST" == "all" ]]; then
  command -v agy >/dev/null 2>&1 || {
    echo "ERROR: agy CLI not found; no host was uninstalled" >&2
    exit 1
  }
fi

remove_owned_path() {
  local path="$1" label="$2"
  if [[ -e "$path" || -L "$path" ]]; then
    rm -rf "$path"
    echo "  [$label] removed $path"
  fi
}

remove_colon_commands() {
  local dest="$1" label="$2" f
  [[ -d "$dest" ]] || return 0
  shopt -s nullglob
  for f in "$dest"/dev-workflow.md "$dest"/dev-workflow:*.md "$dest"/dev-workflow-*.md; do
    remove_owned_path "$f" "$label"
  done
  shopt -u nullglob
}

remove_stage_entries() {
  local dest_root="$1" label="$2" s
  for s in "${STAGES[@]}"; do
    remove_owned_path "$dest_root/dev-workflow-$s" "$label"
  done
  remove_owned_path "$dest_root/dev-workflow" "$label"
  remove_owned_path "$dest_root/dev-workflow-qa" "$label"
}

codex_marketplace_seed() {
  cat <<'EOF'
{
  "name": "personal",
  "interface": { "displayName": "Personal" },
  "plugins": [
    {
      "name": "dev-workflow",
      "source": { "source": "local", "path": "./plugins/dev-workflow" },
      "policy": { "installation": "AVAILABLE", "authentication": "ON_INSTALL" },
      "category": "Productivity"
    }
  ]
}
EOF
}

uninstall_claude() {
  echo "==> Claude Code"
  remove_owned_path "$HOME/.claude/skills/dev-workflow-plugin" "claude-skill"
  remove_owned_path "$HOME/.claude/plugins/dev-workflow" "claude-plugin"
  remove_colon_commands "$HOME/.claude/commands" "claude-command"
  if [[ -n "$PROJECT_CLAUDE_CMDS" ]]; then
    remove_colon_commands "$PROJECT_CLAUDE_CMDS" "project-claude-command"
  fi
}

uninstall_cursor() {
  echo "==> Cursor"
  remove_stage_entries "$HOME/.cursor/skills" "cursor-skill"
  remove_colon_commands "$HOME/.cursor/commands" "cursor-command"
}

uninstall_codex() {
  local marketplace="$HOME/.agents/plugins/marketplace.json"
  echo "==> Codex"
  remove_stage_entries "$HOME/.codex/skills" "codex-skill"
  remove_owned_path "$HOME/.codex/plugins/dev-workflow" "codex-plugin"
  remove_owned_path "$HOME/.agents/plugins/plugins/dev-workflow" "codex-marketplace-link"
  if [[ -f "$marketplace" ]]; then
    if cmp -s "$marketplace" <(codex_marketplace_seed); then
      remove_owned_path "$marketplace" "codex-marketplace"
    else
      echo "  [codex-marketplace] preserved modified Codex marketplace: $marketplace"
    fi
  fi
}

uninstall_antigravity() {
  echo "==> Antigravity"
  agy plugin uninstall dev-workflow
}

echo "==> Target: $TARGET_HOST"

case "$TARGET_HOST" in
  claude) uninstall_claude ;;
  cursor) uninstall_cursor ;;
  codex) uninstall_codex ;;
  antigravity) uninstall_antigravity ;;
  all)
    uninstall_claude
    uninstall_cursor
    uninstall_codex
    uninstall_antigravity
    ;;
esac

echo "==> Uninstall complete: $TARGET_HOST"
echo "    The repository clone and worklogs were not removed."
