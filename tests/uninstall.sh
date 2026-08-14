#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

ok() { printf 'PASS: %s\n' "$1"; PASS=$((PASS + 1)); }
bad() { printf 'FAIL: %s\n' "$1"; FAIL=$((FAIL + 1)); }

new_home() {
  TEST_HOME="$(mktemp -d)"
  TEST_BIN="$TEST_HOME/bin"
  mkdir -p "$TEST_BIN"
  printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$*" >>"$HOME/agy.calls"\n' >"$TEST_BIN/agy"
  chmod +x "$TEST_BIN/agy"
}

run_install() {
  HOME="$TEST_HOME" PATH="$TEST_BIN:$PATH" bash "$ROOT/install.sh" "$@" \
    >"$TEST_HOME/install.out" 2>"$TEST_HOME/install.err"
}

run_uninstall() {
  HOME="$TEST_HOME" PATH="$TEST_BIN:$PATH" bash "$ROOT/uninstall.sh" "$@" \
    >"$TEST_HOME/uninstall.out" 2>"$TEST_HOME/uninstall.err"
}

run_uninstall_without_agy() {
  HOME="$TEST_HOME" PATH="/usr/bin:/bin" bash "$ROOT/uninstall.sh" "$@" \
    >"$TEST_HOME/uninstall.out" 2>"$TEST_HOME/uninstall.err"
}

run_uninstall_with_project_commands() {
  DEV_WORKFLOW_PROJECT_CLAUDE_COMMANDS="$TEST_HOME/project-commands" \
    HOME="$TEST_HOME" PATH="$TEST_BIN:$PATH" bash "$ROOT/uninstall.sh" "$@" \
    >"$TEST_HOME/uninstall.out" 2>"$TEST_HOME/uninstall.err"
}

new_home
run_install --claude
mkdir -p "$TEST_HOME/.claude/commands" "$TEST_HOME/.cursor"
touch "$TEST_HOME/.claude/commands/keep-me.md" "$TEST_HOME/.cursor/keep-me"
if run_uninstall &&
   [[ ! -e "$TEST_HOME/.claude/plugins/dev-workflow" ]] &&
   [[ ! -e "$TEST_HOME/.claude/skills/dev-workflow-plugin" ]] &&
   [[ ! -e "$TEST_HOME/.claude/commands/dev-workflow:audit.md" ]] &&
   [[ -f "$TEST_HOME/.claude/commands/keep-me.md" ]] &&
   [[ -f "$TEST_HOME/.cursor/keep-me" ]]; then
  ok "default uninstalls Claude only and preserves unrelated files"
else
  bad "default uninstalls Claude only and preserves unrelated files"
fi

if run_uninstall && [[ -f "$TEST_HOME/.claude/commands/keep-me.md" ]]; then
  ok "local uninstall is idempotent"
else
  bad "local uninstall is idempotent"
fi

new_home
mkdir -p "$TEST_HOME/project-commands"
touch "$TEST_HOME/project-commands/dev-workflow:audit.md" "$TEST_HOME/project-commands/keep-me.md"
if run_uninstall_with_project_commands --claude &&
   [[ ! -e "$TEST_HOME/project-commands/dev-workflow:audit.md" ]] &&
   [[ -f "$TEST_HOME/project-commands/keep-me.md" ]]; then
  ok "Claude project commands are removed without touching neighbors"
else
  bad "Claude project commands are removed without touching neighbors"
fi

new_home
run_install --cursor
touch "$TEST_HOME/.cursor/commands/keep-me.md" "$TEST_HOME/.cursor/skills/keep-me"
if run_uninstall --cursor &&
   [[ "$(find "$TEST_HOME/.cursor/skills" -maxdepth 1 -name 'dev-workflow-*' | wc -l | tr -d ' ')" -eq 0 ]] &&
   [[ ! -e "$TEST_HOME/.cursor/commands/dev-workflow:audit.md" ]] &&
   [[ -f "$TEST_HOME/.cursor/commands/keep-me.md" ]] &&
   [[ -f "$TEST_HOME/.cursor/skills/keep-me" ]]; then
  ok "--cursor removes only dev-workflow entries"
else
  bad "--cursor removes only dev-workflow entries"
fi

new_home
run_install --codex
touch "$TEST_HOME/.codex/skills/keep-me"
if run_uninstall --codex &&
   [[ "$(find "$TEST_HOME/.codex/skills" -maxdepth 1 -name 'dev-workflow-*' | wc -l | tr -d ' ')" -eq 0 ]] &&
   [[ ! -e "$TEST_HOME/.codex/plugins/dev-workflow" ]] &&
   [[ ! -e "$TEST_HOME/.agents/plugins/plugins/dev-workflow" ]] &&
   [[ ! -e "$TEST_HOME/.agents/plugins/marketplace.json" ]] &&
   [[ -f "$TEST_HOME/.codex/skills/keep-me" ]]; then
  ok "--codex removes generated marketplace seed and owned entries"
else
  bad "--codex removes generated marketplace seed and owned entries"
fi

new_home
run_install --codex
printf '\n' >>"$TEST_HOME/.agents/plugins/marketplace.json"
if run_uninstall --codex &&
   [[ -f "$TEST_HOME/.agents/plugins/marketplace.json" ]] &&
   grep -q 'preserved modified Codex marketplace' "$TEST_HOME/uninstall.out"; then
  ok "modified Codex marketplace is preserved"
else
  bad "modified Codex marketplace is preserved"
fi

new_home
if run_uninstall --agy && grep -q '^plugin uninstall dev-workflow$' "$TEST_HOME/agy.calls"; then
  ok "--agy delegates uninstall to agy"
else
  bad "--agy delegates uninstall to agy"
fi

new_home
run_install --all
if run_uninstall --all &&
   [[ ! -e "$TEST_HOME/.claude/plugins/dev-workflow" ]] &&
   [[ ! -e "$TEST_HOME/.cursor/skills/dev-workflow-audit" ]] &&
   [[ ! -e "$TEST_HOME/.codex/skills/dev-workflow-audit" ]] &&
   grep -q '^plugin uninstall dev-workflow$' "$TEST_HOME/agy.calls"; then
  ok "--all uninstalls every supported host"
else
  bad "--all uninstalls every supported host"
fi

new_home
run_install --claude
if run_uninstall_without_agy --all; then
  bad "--all rejects missing agy before partial uninstall"
elif [[ -L "$TEST_HOME/.claude/plugins/dev-workflow" ]]; then
  ok "--all rejects missing agy before partial uninstall"
else
  bad "--all rejects missing agy before partial uninstall"
fi

new_home
if run_uninstall --cursor --codex; then
  bad "conflicting uninstall targets are rejected"
else
  ok "conflicting uninstall targets are rejected"
fi

new_home
if run_uninstall --host unknown; then
  bad "unknown uninstall target is rejected"
else
  ok "unknown uninstall target is rejected"
fi

printf 'RESULT: %s passed, %s failed\n' "$PASS" "$FAIL"
[[ "$FAIL" -eq 0 ]]
