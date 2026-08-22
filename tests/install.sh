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

run_install_without_agy() {
  HOME="$TEST_HOME" PATH="/usr/bin:/bin" bash "$ROOT/install.sh" "$@" \
    >"$TEST_HOME/install.out" 2>"$TEST_HOME/install.err"
}

new_home
if run_install &&
   [[ -L "$TEST_HOME/.claude/plugins/dev-workflow" ]] &&
   [[ -f "$TEST_HOME/.claude/commands/dev-workflow:audit.md" ]] &&
   [[ ! -e "$TEST_HOME/.cursor" ]] &&
   [[ ! -e "$TEST_HOME/.codex" ]] &&
   [[ ! -e "$TEST_HOME/agy.calls" ]]; then
  ok "default installs Claude only"
else
  bad "default installs Claude only"
fi

new_home
if run_install --claude &&
   [[ -L "$TEST_HOME/.claude/plugins/dev-workflow" ]] &&
   [[ ! -e "$TEST_HOME/.cursor" ]] &&
   [[ ! -e "$TEST_HOME/.codex" ]]; then
  ok "--claude installs Claude only"
else
  bad "--claude installs Claude only"
fi

if [[ "$(rg -l '^disable-model-invocation: false$' "$ROOT"/skills/*/SKILL.md | wc -l | tr -d ' ')" -eq 18 ]]; then
  ok "all source skills permit model invocation"
else
  bad "all source skills permit model invocation"
fi

new_home
if run_install --host cursor &&
   [[ -L "$TEST_HOME/.cursor/skills/dev-workflow-audit" ]] &&
   [[ "$(find "$TEST_HOME/.cursor/skills" -maxdepth 1 -type l -name 'dev-workflow-*' | wc -l | tr -d ' ')" -eq 18 ]] &&
   [[ -f "$TEST_HOME/.cursor/commands/dev-workflow:audit.md" ]] &&
   [[ ! -e "$TEST_HOME/.claude" ]] &&
   cmp -s "$ROOT/skills/audit/SKILL.md" "$TEST_HOME/.cursor/skills/dev-workflow-audit/SKILL.md"; then
  ok "Cursor receives full live stage skills"
else
  bad "Cursor receives full live stage skills"
fi

new_home
if run_install --cursor &&
   [[ -L "$TEST_HOME/.cursor/skills/dev-workflow-audit" ]] &&
   [[ ! -e "$TEST_HOME/.claude" ]]; then
  ok "--cursor aliases Cursor-only install"
else
  bad "--cursor aliases Cursor-only install"
fi

new_home
if run_install --host codex &&
   [[ -L "$TEST_HOME/.codex/skills/dev-workflow-audit" ]] &&
   [[ "$(find "$TEST_HOME/.codex/skills" -maxdepth 1 -type l -name 'dev-workflow-*' | wc -l | tr -d ' ')" -eq 18 ]] &&
   [[ -L "$TEST_HOME/.codex/plugins/dev-workflow" ]] &&
   [[ -L "$TEST_HOME/.agents/plugins/plugins/dev-workflow" ]] &&
   grep -q '"path": "./plugins/dev-workflow"' "$TEST_HOME/.agents/plugins/marketplace.json" &&
   [[ ! -e "$TEST_HOME/.claude" ]]; then
  ok "Codex receives full live skills and canonical marketplace source"
else
  bad "Codex receives full live skills and canonical marketplace source"
fi

new_home
if run_install --codex &&
   [[ -L "$TEST_HOME/.codex/skills/dev-workflow-audit" ]] &&
   [[ ! -e "$TEST_HOME/.claude" ]]; then
  ok "--codex aliases Codex-only install"
else
  bad "--codex aliases Codex-only install"
fi

new_home
if run_install --host antigravity &&
   grep -q "plugin install $ROOT/hosts/antigravity" "$TEST_HOME/agy.calls" &&
   [[ ! -e "$TEST_HOME/.claude" ]]; then
  ok "Antigravity bundle is installed through agy"
else
  bad "Antigravity bundle is installed through agy"
fi

new_home
if run_install --agy &&
   grep -q "plugin install $ROOT/hosts/antigravity" "$TEST_HOME/agy.calls" &&
   [[ ! -e "$TEST_HOME/.claude" ]]; then
  ok "--agy aliases Antigravity-only install"
else
  bad "--agy aliases Antigravity-only install"
fi

new_home
if run_install --host all &&
   [[ -L "$TEST_HOME/.claude/plugins/dev-workflow" ]] &&
   [[ -L "$TEST_HOME/.cursor/skills/dev-workflow-audit" ]] &&
   [[ -L "$TEST_HOME/.codex/skills/dev-workflow-audit" ]] &&
   grep -q 'plugin install' "$TEST_HOME/agy.calls"; then
  ok "all installs every supported host"
else
  bad "all installs every supported host"
fi

new_home
if run_install --all &&
   [[ -L "$TEST_HOME/.claude/plugins/dev-workflow" ]] &&
   [[ -L "$TEST_HOME/.cursor/skills/dev-workflow-audit" ]] &&
   [[ -L "$TEST_HOME/.codex/skills/dev-workflow-audit" ]] &&
   grep -q 'plugin install' "$TEST_HOME/agy.calls"; then
  ok "--all installs every supported host"
else
  bad "--all installs every supported host"
fi

new_home
if run_install_without_agy --host all; then
  bad "all preflight rejects missing agy before partial install"
elif [[ ! -e "$TEST_HOME/.claude" && ! -e "$TEST_HOME/.cursor" && ! -e "$TEST_HOME/.codex" ]]; then
  ok "all preflight rejects missing agy before partial install"
else
  bad "all preflight rejects missing agy before partial install"
fi

new_home
if run_install --host unknown; then
  bad "unknown host is rejected"
else
  ok "unknown host is rejected"
fi

new_home
if run_install --cursor --codex; then
  bad "conflicting shorthand targets are rejected"
else
  ok "conflicting shorthand targets are rejected"
fi

printf 'RESULT: %s passed, %s failed\n' "$PASS" "$FAIL"
[[ "$FAIL" -eq 0 ]]
