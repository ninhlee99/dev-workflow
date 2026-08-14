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
  cat >"$TEST_BIN/git" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$HOME/git.calls"
case "$*" in
  *"status --porcelain") printf '%s' "${FAKE_GIT_STATUS:-}" ;;
  *"pull --ff-only") exit "${FAKE_GIT_PULL_EXIT:-0}" ;;
esac
EOF
  printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$*" >>"$HOME/agy.calls"\n' >"$TEST_BIN/agy"
  chmod +x "$TEST_BIN/git" "$TEST_BIN/agy"
}

run_update() {
  HOME="$TEST_HOME" PATH="$TEST_BIN:/usr/bin:/bin" bash "$ROOT/update.sh" "$@" \
    >"$TEST_HOME/update.out" 2>"$TEST_HOME/update.err"
}

new_home
if run_update &&
   grep -q 'pull --ff-only' "$TEST_HOME/git.calls" &&
   [[ -L "$TEST_HOME/.claude/plugins/dev-workflow" ]] &&
   [[ ! -e "$TEST_HOME/.cursor" ]]; then
  ok "default fast-forwards source and refreshes Claude only"
else
  bad "default fast-forwards source and refreshes Claude only"
fi

new_home
if run_update --cursor &&
   grep -q 'pull --ff-only' "$TEST_HOME/git.calls" &&
   [[ -L "$TEST_HOME/.cursor/skills/dev-workflow-audit" ]] &&
   [[ ! -e "$TEST_HOME/.claude" ]]; then
  ok "--cursor refreshes Cursor only"
else
  bad "--cursor refreshes Cursor only"
fi

new_home
FAKE_GIT_STATUS=' M README.md' run_update --codex || update_exit=$?
if [[ "${update_exit:-0}" -ne 0 ]] &&
   ! grep -q 'pull --ff-only' "$TEST_HOME/git.calls" &&
   [[ ! -e "$TEST_HOME/.codex" ]]; then
  ok "dirty source is rejected before pull or host changes"
else
  bad "dirty source is rejected before pull or host changes"
fi
unset update_exit

new_home
FAKE_GIT_PULL_EXIT=1 run_update --codex || update_exit=$?
if [[ "${update_exit:-0}" -ne 0 ]] && [[ ! -e "$TEST_HOME/.codex" ]]; then
  ok "failed fast-forward stops before host refresh"
else
  bad "failed fast-forward stops before host refresh"
fi
unset update_exit

new_home
rm -f "$TEST_BIN/agy"
if run_update --all; then
  bad "--all rejects missing agy before pull"
elif [[ ! -e "$TEST_HOME/git.calls" && ! -e "$TEST_HOME/.claude" ]]; then
  ok "--all rejects missing agy before pull"
else
  bad "--all rejects missing agy before pull"
fi

new_home
if run_update --cursor --codex; then
  bad "conflicting update targets are rejected"
elif [[ ! -e "$TEST_HOME/git.calls" ]]; then
  ok "conflicting update targets are rejected"
else
  bad "conflicting update targets are rejected"
fi

printf 'RESULT: %s passed, %s failed\n' "$PASS" "$FAIL"
[[ "$FAIL" -eq 0 ]]
