#!/usr/bin/env bash
# check-gates.sh — soft→hard gate checker for dev-workflow worklogs.
# Exit 0 = PASS (or only WAIVE-covered fails). Exit 1 = FAIL. Exit 2 = usage/path error.
#
# Usage:
#   ./bin/check-gates.sh <Ticket_ID> [--project <slug>] [--min G0|…|G8] [--strict] [--json]
#   DEV_WORKFLOW_WORKSPACES_ROOT=/path ./bin/check-gates.sh TICKET-123
#
# Looks for: <workspaces-root>/workspaces/<slug>/worklogs/<Ticket_ID>/
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/resolve-paths.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/resolve-paths.sh"
resolve_plugin_dir || DEV_WORKFLOW_PLUGIN_DIR="$PLUGIN_DIR"
PLUGIN_DIR="${DEV_WORKFLOW_PLUGIN_DIR:-$PLUGIN_DIR}"

TICKET=""
PROJECT_SLUG=""
MIN_GATE="G8"
STRICT=0
JSON=0
FAILS=()
WARNS=()
WAIVES=()

usage() {
  cat <<EOF
Usage: $(basename "$0") <Ticket_ID> [--project <slug>] [--min G0|G1|G2|G3|G4|G5|G6|G7|G8] [--strict] [--json]

Checks worklog artifacts under workspaces/<project-slug>/worklogs/<Ticket_ID>/.
Default --min G8 (enough to ship).

--strict: reject G8 WAIVE; require UI screenshot paths; reject placeholder test output.

Exit: 0 PASS · 1 FAIL · 2 usage/path error
EOF
}

gate_rank() {
  case "$1" in
    G0) echo 0 ;; G1) echo 1 ;; G2) echo 2 ;; G3) echo 3 ;;
    G4) echo 4 ;; G5) echo 5 ;; G6) echo 6 ;; G7) echo 7 ;;
    G8) echo 8 ;;
    *) echo 99 ;;
  esac
}

need_gate() {
  local g="$1"
  [[ "$(gate_rank "$g")" -le "$(gate_rank "$MIN_GATE")" ]]
}

fail() { FAILS+=("$1"); }
warn() { WARNS+=("$1"); }

# --- args ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_SLUG="${2:-}"; shift 2 ;;
    --min) MIN_GATE="${2:-G8}"; shift 2 ;;
    --strict) STRICT=1; shift ;;
    --json) JSON=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*)
      echo "Unknown flag: $1" >&2
      usage
      exit 2
      ;;
    *)
      if [[ -z "$TICKET" ]]; then TICKET="$1"; shift
      else echo "Unexpected arg: $1" >&2; usage; exit 2
      fi
      ;;
  esac
done

[[ -n "$TICKET" ]] || { usage; exit 2; }

# --- resolve worklog from user's project tree (auto) ---
if [[ -n "$PROJECT_SLUG" ]]; then
  export DEV_WORKFLOW_PROJECT_SLUG="$PROJECT_SLUG"
fi
WORKLOG="$(resolve_worklog_dir "$TICKET" "${PROJECT_SLUG:-}" || true)"
if [[ -z "${WORKLOG:-}" ]]; then
  resolve_project_slug "${PROJECT_SLUG:-}" || true
  WORKLOG="$(resolve_worklog_dir "$TICKET" "${DEV_WORKFLOW_PROJECT_SLUG_RESOLVED:-}" || true)"
fi
if [[ -z "${WORKLOG:-}" ]]; then
  echo "ERROR: worklog not found for ticket=$TICKET project=${PROJECT_SLUG:-${DEV_WORKFLOW_PROJECT_SLUG_RESOLVED:-auto}}" >&2
  echo "Searched walk-up from cwd/git for workspaces/*/worklogs/$TICKET" >&2
  echo "Hint: cd into the user project, or set DEV_WORKFLOW_WORKSPACES_ROOT / --project <slug>" >&2
  exit 2
fi

PROJECT_HOME="${DEV_WORKFLOW_PROJECT_HOME:-$(cd "$WORKLOG/../.." && pwd)}"
PROJECT_SLUG="${DEV_WORKFLOW_PROJECT_SLUG_RESOLVED:-$(basename "$PROJECT_HOME")}"
echo "resolved: project=$PROJECT_SLUG home=$PROJECT_HOME worklog=$WORKLOG" >&2
INDEX="$WORKLOG/INDEX.md"
SPEC="$WORKLOG/02-spec.md"
CREPORT="$WORKLOG/03-conflict-report.md"
QALOG="$WORKLOG/03-qa-log.md"
PLAN="$WORKLOG/04-plan.md"
IMPL="$WORKLOG/05-impl-log.md"
REVIEW="$WORKLOG/06-review-qa.md"
TESTEV="$WORKLOG/06b-test-evidence.md"
SHIP="$WORKLOG/07-ship.md"
DK_INDEX="$PROJECT_HOME/domain-knowledge/INDEX.md"
PROJECT_MD="$PROJECT_HOME/PROJECT.md"

file_ok() { [[ -f "$1" ]]; }

# --- WAIVE parse from INDEX ---
if file_ok "$INDEX"; then
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(G[0-8][^|]*)\| ]]; then
      WAIVES+=("$line")
    fi
  done < <(grep -E '^\s*-\s*G[0-8]' "$INDEX" 2>/dev/null || true)
fi

waived() {
  local gate="$1"
  local w
  if [[ "$STRICT" -eq 1 && "$gate" == "G8" ]]; then
    return 1
  fi
  for w in "${WAIVES[@]:-}"; do
    if [[ "$w" == *"$gate"* ]]; then
      local pipes
      pipes="$(awk -F'|' '{print NF}' <<<"$w")"
      if [[ "$pipes" -ge 4 ]]; then
        if [[ "$w" =~ [Mm]oney|[Pp]ermission|[Ll]egacy ]]; then
          if [[ ! "$w" =~ [Pp][Mm] ]]; then
            continue
          fi
        fi
        return 0
      fi
    fi
  done
  return 1
}

maybe_fail() {
  local gate="$1"
  local msg="$2"
  if waived "$gate"; then
    warn "$gate WAIVED: $msg"
  else
    fail "$gate FAIL: $msg"
  fi
}

ui_ticket() {
  if file_ok "$SPEC" && grep -qiE 'Touches UI\?.*☑ Yes|Touches UI\?.*\[x\] Yes|Touches UI\?\*\*.*Yes' "$SPEC"; then
    return 0
  fi
  return 1
}

# --- G0 ---
if need_gate G0; then
  file_ok "$PROJECT_MD" || maybe_fail G0 "missing PROJECT.md at $PROJECT_HOME"
  file_ok "$DK_INDEX" || maybe_fail G0 "missing domain-knowledge/INDEX.md"
  if file_ok "$DK_INDEX"; then
    if grep -qiE 'Needs learning:.*☐ yes|Needs learning:\s*yes' "$DK_INDEX" 2>/dev/null; then
      if grep -qE 'Needs learning:.*☑ yes|Needs learning:.*\[x\] yes|\*\*yes\*\*' "$DK_INDEX" 2>/dev/null; then
        maybe_fail G0 "Needs learning still yes on domain-knowledge INDEX"
      else
        warn "G0: check Needs learning manually on $DK_INDEX"
      fi
    fi
  fi
fi

# --- G1 ---
if need_gate G1; then
  file_ok "$SPEC" || maybe_fail G1 "missing 02-spec.md"
  if file_ok "$SPEC"; then
    grep -qE 'Scenario AC|Given' "$SPEC" || maybe_fail G1 "02-spec missing Scenario AC / Given section"
    if ! grep -qE '\|[[:space:]]*AC-[0-9]+[[:space:]]*\|[[:space:]]*[^|[:space:]]+' "$SPEC"; then
      maybe_fail G1 "no filled AC-xx row (Given empty / template only)"
    fi
    if ui_ticket; then
      grep -qE 'UI states|Happy' "$SPEC" || maybe_fail G1 "Touches UI=Yes but UI states section missing/empty marker"
    fi
  fi
fi

# --- G2 ---
if need_gate G2; then
  file_ok "$CREPORT" || maybe_fail G2 "missing 03-conflict-report.md"
  if file_ok "$CREPORT"; then
    grep -qE 'claim_id|C-[0-9]+' "$CREPORT" || warn "G2: no claim_id rows detected — confirm report filled"
    if grep -qE '## G2' "$CREPORT" && grep -qE '☐ PASS.*☑ FAIL|☐ PASS[[:space:]]+☐ FAIL —|G2.*☑ FAIL' "$CREPORT"; then
      maybe_fail G2 "03-conflict-report marks G2 FAIL"
    fi
    if grep -qE '☐ PASS[[:space:]]+☐ FAIL' "$CREPORT" && ! grep -qE '☑ PASS|\[x\] PASS' "$CREPORT"; then
      warn "G2: G2 PASS not checked — confirm all non-MATCH conflicts decided"
    fi
  fi
fi

# --- G3 user sign-off ---
if need_gate G3; then
  file_ok "$INDEX" || maybe_fail G3 "missing INDEX.md (need G3 user sign-off)"
  if file_ok "$INDEX"; then
    if ! grep -qiE 'G3 user sign-off:.*☑ PASS|G3 user sign-off:.*\[x\] PASS|Signed off by:[[:space:]]*[A-Za-z0-9]' "$INDEX"; then
      maybe_fail G3 "user sign-off missing — run :confirm and record Signed off by / G3 PASS"
    fi
    if grep -qiE 'G3 user sign-off:.*☑ FAIL|G3 user sign-off:.*\[x\] FAIL' "$INDEX"; then
      maybe_fail G3 "G3 user sign-off marked FAIL"
    fi
  fi
fi

# --- G4 plan ---
if need_gate G4; then
  file_ok "$PLAN" || maybe_fail G4 "missing 04-plan.md"
  if file_ok "$PLAN"; then
    grep -qE '\|[[:space:]]*[0-9]+[[:space:]]*\|' "$PLAN" || maybe_fail G4 "04-plan has no task rows"
  fi
fi

# --- G5 no open Qs ---
if need_gate G5; then
  file_ok "$QALOG" || maybe_fail G5 "missing 03-qa-log.md"
  if file_ok "$QALOG"; then
    open_n="$(grep -cE '☐ OPEN|\| OPEN \|' "$QALOG" 2>/dev/null || true)"
    open_n="${open_n:-0}"
    if [[ "$open_n" -gt 0 ]]; then
      pure_open="$(grep -E '☐ OPEN' "$QALOG" | grep -cvE 'CONFIRMED|ANSWERED' || true)"
      pure_open="${pure_open:-0}"
      if [[ "$pure_open" -gt 0 ]]; then
        maybe_fail G5 "$pure_open OPEN question(s) in 03-qa-log.md"
      fi
    fi
  fi
fi

# --- G6 build+coverage ---
if need_gate G6; then
  file_ok "$IMPL" || maybe_fail G6 "missing 05-impl-log.md"
  if file_ok "$IMPL"; then
    grep -qE 'Coverage map' "$IMPL" || maybe_fail G6 "05-impl-log missing Coverage map section"
    if grep -qE '☐ MISSING|\| MISSING \|' "$IMPL"; then
      maybe_fail G6 "coverage map still has MISSING"
    fi
    if grep -qE '☐ FAIL' "$IMPL" && ! grep -qE '☑ PASS|\[x\] PASS' "$IMPL"; then
      warn "G6: FAIL boxes present and no PASS checked — verify tests"
    fi
    if ! grep -qE '☑ PASS|\[x\] PASS|Result:.*PASS' "$IMPL"; then
      maybe_fail G6 "no PASS evidence in 05-impl-log (check Result column)"
    fi
  fi
fi

# --- G7 review evidence ---
if need_gate G7; then
  file_ok "$REVIEW" || maybe_fail G7 "missing 06-review-qa.md"
  if file_ok "$REVIEW"; then
    grep -qE 'AC evidence|How verified' "$REVIEW" || maybe_fail G7 "06-review-qa missing AC evidence / How verified"
    empty_how="$(grep -E '\|[[:space:]]*(AC|NEG|PERM|EDGE)-[0-9]+[[:space:]]*\|[[:space:]]*\|' "$REVIEW" 2>/dev/null | wc -l | tr -d ' ' || true)"
    empty_how="${empty_how:-0}"
    if [[ "${empty_how}" -gt 0 ]]; then
      maybe_fail G7 "$empty_how AC evidence row(s) missing How verified"
    fi
    if ui_ticket; then
      grep -qE 'UI checklist|Happy' "$REVIEW" || maybe_fail G7 "UI ticket but UI checklist section missing"
    fi
    if ! grep -qE '☑ PASS|\[x\] PASS' "$REVIEW"; then
      warn "G7: PASS not clearly checked on 06-review-qa"
    fi
  fi
fi

# --- G8 test evidence ---
if need_gate G8; then
  file_ok "$TESTEV" || maybe_fail G8 "missing 06b-test-evidence.md"
  if file_ok "$TESTEV"; then
    if grep -qE 'paste test runner output here|# paste test runner output' "$TESTEV"; then
      maybe_fail G8 "test run output still placeholder"
    fi
    if ! grep -qE '```' "$TESTEV"; then
      maybe_fail G8 "test run output missing code fence"
    fi
    if grep -qiE 'Overall:.*☑ FAIL|Overall:.*\[x\] FAIL|\*\*Overall:\*\*.*☑ FAIL|\*\*Overall:\*\*.*\[x\] FAIL' "$TESTEV"; then
      maybe_fail G8 "Overall marked FAIL in 06b-test-evidence"
    fi
    if grep -qE '☑ FAIL|\[x\] FAIL' "$TESTEV" && ! grep -qiE 'Overall:.*☑ PASS|Overall:.*\[x\] PASS|G8 verdict:.*☑ PASS|G8 verdict:.*\[x\] PASS' "$TESTEV"; then
      maybe_fail G8 "suite FAIL checked without Overall/G8 PASS"
    fi
    if ! grep -qiE 'Overall:.*☑ PASS|Overall:.*\[x\] PASS|G8 verdict:.*☑ PASS|G8 verdict:.*\[x\] PASS' "$TESTEV"; then
      maybe_fail G8 "Overall/G8 PASS not checked"
    fi
    if ! grep -qiE '\*\*Dev:\*\*[[:space:]]*[A-Za-z0-9]|Dev:[[:space:]]*[A-Za-z0-9]' "$TESTEV"; then
      maybe_fail G8 "sign-off Dev name missing"
    fi
    if ui_ticket || grep -qiE 'Touches UI\?.*☑ Yes|Touches UI\?.*\[x\] Yes' "$TESTEV"; then
      if ! grep -qE '\|[[:space:]]*AC-[0-9]+[[:space:]]*\|[[:space:]]*[^|[:space:]]+' "$TESTEV"; then
        if [[ "$STRICT" -eq 1 ]]; then
          maybe_fail G8 "UI ticket requires screenshot/recording path in evidence table"
        else
          warn "G8: UI ticket but screenshot paths look empty"
        fi
      fi
    fi
    if [[ "$STRICT" -eq 1 ]]; then
      out_lines="$(awk '/## Test run output/,/## Screenshots/{if($0 ~ /```/){c++} else if(c==1 && NF) print}' "$TESTEV" 2>/dev/null | wc -l | tr -d ' ' || true)"
      out_lines="${out_lines:-0}"
      if [[ "${out_lines}" -lt 2 ]]; then
        maybe_fail G8 "strict: test output too thin (need real runner excerpt)"
      fi
    fi
  fi
fi

# --- ship artifact (advisory unless present and empty) ---
if file_ok "$SHIP"; then
  :
else
  if [[ "$(gate_rank "$MIN_GATE")" -ge 8 ]]; then
    warn "07-ship.md not present yet — fill via :ship after G8 PASS"
  fi
fi

# --- INDEX existence ---
file_ok "$INDEX" || warn "missing worklog INDEX.md"

# --- output ---
if [[ "$JSON" -eq 1 ]]; then
  python3 - <<PY
import json
print(json.dumps({
  "ticket": "$TICKET",
  "project": "$PROJECT_SLUG",
  "worklog": "$WORKLOG",
  "min_gate": "$MIN_GATE",
  "strict": bool($STRICT),
  "fails": $(printf '%s\n' "${FAILS[@]:-}" | python3 -c 'import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))'),
  "warns": $(printf '%s\n' "${WARNS[@]:-}" | python3 -c 'import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))'),
  "ok": $([[ ${#FAILS[@]} -eq 0 ]] && echo true || echo false),
}, indent=2))
PY
else
  echo "check-gates: ticket=$TICKET project=$PROJECT_SLUG min=$MIN_GATE strict=$STRICT"
  echo "worklog: $WORKLOG"
  if [[ ${#WARNS[@]} -gt 0 ]]; then
    echo "WARNINGS:"
    printf '  - %s\n' "${WARNS[@]}"
  fi
  if [[ ${#FAILS[@]} -gt 0 ]]; then
    echo "FAILURES:"
    printf '  - %s\n' "${FAILS[@]}"
    echo "RESULT: FAIL (${#FAILS[@]} issue(s))"
    exit 1
  fi
  echo "RESULT: PASS"
fi

exit 0
