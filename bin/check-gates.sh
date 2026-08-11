#!/usr/bin/env bash
# check-gates.sh — gate checker for dev-workflow (v0.4.0).
# Exit 0 = PASS. Exit 1 = FAIL. Exit 2 = usage/path error.
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
VERIFY_NET=0
JSON=0
FAILS=()
WARNS=()
WAIVES=()
RISK="P1"

usage() {
  cat <<EOF
Usage: $(basename "$0") <Ticket_ID> [--project <slug>] [--min G0|…|G9] [--strict] [--verify-net] [--json]

Default --min G8. Merge: --min G9 --strict (implies --verify-net).
--strict: CI-native verify; no P2 soft; no G8 WAIVE; enable --verify-net.
G3 requires INDEX phrase + 03b-human-confirm.md (no AI names).
P0: 02b-security.md. Pilot:yes on INDEX requires pilot log row at G9.

Exit: 0 PASS · 1 FAIL · 2 usage/path error
EOF
}

gate_rank() {
  case "$1" in
    G0) echo 0 ;; G1) echo 1 ;; G2) echo 2 ;; G3) echo 3 ;;
    G4) echo 4 ;; G5) echo 5 ;; G6) echo 6 ;; G7) echo 7 ;;
    G8) echo 8 ;; G9) echo 9 ;;
    *) echo 99 ;;
  esac
}

need_gate() {
  local g="$1"
  [[ "$(gate_rank "$g")" -le "$(gate_rank "$MIN_GATE")" ]]
}

p2_soft_gate() {
  local g="$1"
  [[ "$RISK" == "P2" && "$STRICT" -eq 0 && ( "$g" == "G2" || "$g" == "G4" || "$g" == "G5" || "$g" == "G7" ) ]]
}

fail() { FAILS+=("$1"); }
warn() { WARNS+=("$1"); }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_SLUG="${2:-}"; shift 2 ;;
    --min) MIN_GATE="${2:-G8}"; shift 2 ;;
    --strict) STRICT=1; shift ;;
    --verify-net) VERIFY_NET=1; shift ;;
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

# --strict implies network verify when CI URLs are checked
if [[ "$STRICT" -eq 1 ]]; then
  VERIFY_NET=1
fi

if [[ -n "$PROJECT_SLUG" ]]; then
  export DEV_WORKFLOW_PROJECT_SLUG="$PROJECT_SLUG"
fi
WORKLOG="$(resolve_worklog_dir "$TICKET" "${PROJECT_SLUG:-}" || true)"
if [[ -z "${WORKLOG:-}" ]]; then
  resolve_project_slug "${PROJECT_SLUG:-}" || true
  WORKLOG="$(resolve_worklog_dir "$TICKET" "${DEV_WORKFLOW_PROJECT_SLUG_RESOLVED:-}" || true)"
fi
if [[ -z "${WORKLOG:-}" ]]; then
  echo "ERROR: worklog not found for ticket=$TICKET" >&2
  exit 2
fi

PROJECT_HOME="${DEV_WORKFLOW_PROJECT_HOME:-$(cd "$WORKLOG/../.." && pwd)}"
PROJECT_SLUG="${DEV_WORKFLOW_PROJECT_SLUG_RESOLVED:-$(basename "$PROJECT_HOME")}"
echo "resolved: project=$PROJECT_SLUG home=$PROJECT_HOME worklog=$WORKLOG" >&2

INDEX="$WORKLOG/INDEX.md"
SPEC="$WORKLOG/02-spec.md"
SECURITY="$WORKLOG/02b-security.md"
HCONFIRM="$WORKLOG/03b-human-confirm.md"
CREPORT="$WORKLOG/03-conflict-report.md"
QALOG="$WORKLOG/03-qa-log.md"
PLAN="$WORKLOG/04-plan.md"
IMPL="$WORKLOG/05-impl-log.md"
REVIEW="$WORKLOG/06-review-qa.md"
TESTEV="$WORKLOG/06b-test-evidence.md"
SHIP="$WORKLOG/07-ship.md"
DK_INDEX="$PROJECT_HOME/domain-knowledge/INDEX.md"
PROJECT_MD="$PROJECT_HOME/PROJECT.md"
PILOT_DIR="$PROJECT_HOME/pilot"

file_ok() { [[ -f "$1" ]]; }

detect_risk() {
  RISK="P1"
  local f
  for f in "$SPEC" "$INDEX"; do
    file_ok "$f" || continue
    if grep -qE '☑ P0|\[x\] P0|\[X\] P0' "$f" 2>/dev/null; then RISK="P0"; return; fi
  done
  for f in "$SPEC" "$INDEX"; do
    file_ok "$f" || continue
    if grep -qE '☑ P2|\[x\] P2|\[X\] P2' "$f" 2>/dev/null; then RISK="P2"; return; fi
  done
  for f in "$SPEC" "$INDEX"; do
    file_ok "$f" || continue
    if grep -qE '☑ P1|\[x\] P1|\[X\] P1' "$f" 2>/dev/null; then RISK="P1"; return; fi
  done
}

table_val() {
  local file="$1" key="$2"
  awk -F'|' -v k="$key" '
    tolower($0) ~ tolower(k) {
      v=$3
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
      print v
      exit
    }
  ' "$file" 2>/dev/null || true
}

detect_risk
REQUIRE_MACHINE=0
if [[ "$STRICT" -eq 1 || "$RISK" == "P0" || "$RISK" == "P1" ]]; then
  REQUIRE_MACHINE=1
fi
# --strict implies native verify of local artifacts
VERIFY_NATIVE=0
if [[ "$STRICT" -eq 1 || "$RISK" == "P0" ]]; then
  VERIFY_NATIVE=1
fi

if file_ok "$INDEX"; then
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(G[0-9][^|]*)\| ]]; then
      WAIVES+=("$line")
    fi
  done < <(grep -E '^\s*-\s*G[0-9]' "$INDEX" 2>/dev/null || true)
fi

waived() {
  local gate="$1"
  local w
  if [[ "$gate" == "G8" && ( "$STRICT" -eq 1 || "$RISK" == "P0" ) ]]; then
    return 1
  fi
  if [[ "$gate" == "G3" && "$RISK" == "P0" ]]; then
    return 1
  fi
  for w in "${WAIVES[@]:-}"; do
    if [[ "$w" == *"$gate"* ]]; then
      local pipes
      pipes="$(awk -F'|' '{print NF}' <<<"$w")"
      if [[ "$pipes" -ge 4 ]]; then
        if [[ "$w" =~ [Mm]oney|[Pp]ermission|[Ll]egacy|[Pp][Ii][Ii] ]]; then
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
    return
  fi
  if p2_soft_gate "$gate"; then
    warn "$gate SOFT(P2): $msg"
    return
  fi
  fail "$gate FAIL: $msg"
}

ui_ticket() {
  if file_ok "$SPEC" && grep -qiE 'Touches UI\?.*☑ Yes|Touches UI\?.*\[x\] Yes|Touches UI\?\*\*.*Yes' "$SPEC"; then
    return 0
  fi
  return 1
}

placeholderish() {
  local v="$1"
  [[ -z "$v" || "$v" =~ ^\[.*\]$ || "$v" == "…" || "$v" == "..." ]]
}

field_nonempty() {
  local file="$1" label="$2"
  local line
  line="$(grep -i "$label" "$file" 2>/dev/null | head -1 || true)"
  [[ -n "$line" ]] || return 1
  [[ ! "$line" =~ \.\.\.|… ]] || return 1
  return 0
}

verify_junit_file() {
  local path="$1"
  # resolve relative to cwd or worklog
  local f="$path"
  if [[ ! -f "$f" && -f "$WORKLOG/$path" ]]; then f="$WORKLOG/$path"; fi
  if [[ ! -f "$f" && -f "$PROJECT_HOME/$path" ]]; then f="$PROJECT_HOME/$path"; fi
  if [[ ! -f "$f" ]]; then
    maybe_fail G8 "CI-native: junit/log path not found: $path"
    return
  fi
  if grep -qE 'failures="[1-9][0-9]*"|errors="[1-9][0-9]*"|<failure|<error' "$f" 2>/dev/null; then
    maybe_fail G8 "CI-native: junit/log reports failures/errors: $f"
  fi
}

verify_sha_git() {
  local sha="$1"
  local head="" root=""
  if git -C "$PROJECT_HOME" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    root="$PROJECT_HOME"
    head="$(git -C "$PROJECT_HOME" rev-parse HEAD 2>/dev/null || true)"
  elif git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
    head="$(git rev-parse HEAD 2>/dev/null || true)"
  else
    warn "G8: no git repo to verify SHA against"
    return
  fi
  [[ -n "$head" ]] || return
  if [[ "$head" == "$sha"* || "$sha" == "$head"* || "$head" == "${sha:0:7}"* ]]; then
    return
  fi
  if [[ "$WORKLOG" == *"/fixtures/"* ]]; then
    warn "G8: fixture SHA $sha != HEAD ${head:0:12} (skipped hard fail)"
    return
  fi
  maybe_fail G8 "CI-native: Commit SHA $sha does not match git HEAD ${head:0:12}…"
}

verify_ci_url() {
  local url="$1"
  [[ "$url" =~ ^https?:// ]] || return
  if [[ "$VERIFY_NET" -ne 1 ]]; then
    warn "G8: CI URL present (use --verify-net to HTTP-check)"
    return
  fi
  if command -v curl >/dev/null 2>&1; then
    if ! curl -fsI --max-time 8 "$url" >/dev/null 2>&1; then
      maybe_fail G8 "CI-native: CI URL not reachable: $url"
    fi
  else
    warn "G8: curl missing — skip --verify-net"
  fi
}

# --- G0 ---
if need_gate G0; then
  file_ok "$PROJECT_MD" || maybe_fail G0 "missing PROJECT.md at $PROJECT_HOME"
  file_ok "$DK_INDEX" || maybe_fail G0 "missing domain-knowledge/INDEX.md"
fi

# --- G1 ---
if need_gate G1; then
  file_ok "$SPEC" || maybe_fail G1 "missing 02-spec.md"
  if file_ok "$SPEC"; then
    grep -qE 'Scenario AC|Given' "$SPEC" || maybe_fail G1 "02-spec missing Scenario AC / Given section"
    if ! grep -qE '\|[[:space:]]*AC-[0-9]+[[:space:]]*\|[[:space:]]*[^|[:space:]]+' "$SPEC"; then
      maybe_fail G1 "no filled AC-xx row (Given empty / template only)"
    fi
    if ! grep -qiE '☑ P[012]|\[x\] P[012]|\[X\] P[012]' "$SPEC" && \
       ! grep -qiE '☑ P[012]|\[x\] P[012]|\[X\] P[012]' "$INDEX" 2>/dev/null; then
      maybe_fail G1 "Risk tier P0/P1/P2 not set on spec or INDEX"
    fi
    if ui_ticket; then
      grep -qE 'UI states|Happy' "$SPEC" || maybe_fail G1 "Touches UI=Yes but UI states section missing"
    fi
  fi
  # P0 security mini-gate
  if [[ "$RISK" == "P0" ]]; then
    file_ok "$SECURITY" || maybe_fail G1 "P0 requires 02b-security.md (see references/security.md)"
    if file_ok "$SECURITY"; then
      grep -qiE 'Threat note|Abuse cases|Mitigations' "$SECURITY" || maybe_fail G1 "02b-security missing threat note"
      if grep -qiE 'Threat note|Asset at risk' "$SECURITY" && grep -qE 'other: …|other: \.\.\.|Asset at risk:.*…' "$SECURITY"; then
        maybe_fail G1 "02b-security threat note still placeholder"
      fi
      if ! grep -qE '☑ PASS|\[x\] PASS' "$SECURITY"; then
        maybe_fail G1 "02b-security needs at least one PASS in Secrets/PII or contract table"
      fi
    fi
  fi
fi

# --- G2 ---
if need_gate G2; then
  file_ok "$CREPORT" || maybe_fail G2 "missing 03-conflict-report.md"
  if file_ok "$CREPORT"; then
    if grep -qE '## G2' "$CREPORT" && grep -qE 'G2.*☑ FAIL' "$CREPORT"; then
      maybe_fail G2 "03-conflict-report marks G2 FAIL"
    fi
  fi
fi

# --- G3 ---
if need_gate G3; then
  file_ok "$INDEX" || maybe_fail G3 "missing INDEX.md (need CONFIRM G3:)"
  file_ok "$HCONFIRM" || maybe_fail G3 "missing 03b-human-confirm.md (anti-forge human confirm file)"
  confirm_ok_phrase() {
    local src="$1"
    grep -qE "CONFIRM G3:[[:space:]]*$TICKET[[:space:]]+[A-Za-z0-9_. -]+[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}" "$src"
  }
  banned_ai_name() {
    local src="$1"
    grep -qiE "CONFIRM G3(-PM)?:[[:space:]]*$TICKET[[:space:]]+(AI|ChatGPT|Claude|Copilot|Cursor|Assistant|Bot)\\b" "$src"
  }
  if file_ok "$INDEX"; then
    confirm_ok_phrase "$INDEX" || maybe_fail G3 "INDEX missing CONFIRM G3: $TICKET <name> <YYYY-MM-DD>"
    banned_ai_name "$INDEX" && maybe_fail G3 "INDEX CONFIRM uses forbidden AI/tool name"
  fi
  if file_ok "$HCONFIRM"; then
    confirm_ok_phrase "$HCONFIRM" || maybe_fail G3 "03b-human-confirm.md missing CONFIRM G3 phrase"
    banned_ai_name "$HCONFIRM" && maybe_fail G3 "03b-human-confirm CONFIRM uses forbidden AI/tool name"
    grep -qiE 'Source:.*user-message' "$HCONFIRM" || maybe_fail G3 "03b-human-confirm must set Source: user-message"
    if [[ "$RISK" == "P0" ]]; then
      grep -qE "CONFIRM G3-PM:[[:space:]]*$TICKET[[:space:]]+[A-Za-z0-9_. -]+[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}" "$HCONFIRM" \
        || maybe_fail G3 "P0 requires CONFIRM G3-PM in 03b-human-confirm.md"
      banned_ai_name "$HCONFIRM" && true
      grep -qiE "CONFIRM G3-PM:[[:space:]]*$TICKET[[:space:]]+(AI|ChatGPT|Claude|Copilot|Cursor|Assistant|Bot)\\b" "$HCONFIRM" \
        && maybe_fail G3 "CONFIRM G3-PM uses forbidden AI/tool name"
    fi
  fi
  if file_ok "$INDEX" && [[ "$RISK" == "P0" ]]; then
    grep -qE "CONFIRM G3-PM:[[:space:]]*$TICKET[[:space:]]+[A-Za-z0-9_. -]+[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}" "$INDEX" \
      || maybe_fail G3 "P0 requires CONFIRM G3-PM on INDEX"
  fi
fi

# --- G4 ---
if need_gate G4; then
  file_ok "$PLAN" || maybe_fail G4 "missing 04-plan.md"
  if file_ok "$PLAN"; then
    grep -qE '\|[[:space:]]*[0-9]+[[:space:]]*\|' "$PLAN" || maybe_fail G4 "04-plan has no task rows"
  fi
fi

# --- G5 ---
if need_gate G5; then
  file_ok "$QALOG" || maybe_fail G5 "missing 03-qa-log.md"
  if file_ok "$QALOG"; then
    pure_open="$(grep -E '☐ OPEN' "$QALOG" 2>/dev/null | grep -cvE 'CONFIRMED|ANSWERED' || true)"
    pure_open="${pure_open:-0}"
    if [[ "$pure_open" -gt 0 ]]; then
      maybe_fail G5 "$pure_open OPEN question(s) in 03-qa-log.md"
    fi
  fi
fi

# --- G6 ---
if need_gate G6; then
  file_ok "$IMPL" || maybe_fail G6 "missing 05-impl-log.md"
  if file_ok "$IMPL"; then
    grep -qE 'Coverage map' "$IMPL" || maybe_fail G6 "05-impl-log missing Coverage map section"
    if grep -qE '☐ MISSING|\| MISSING \|' "$IMPL"; then
      maybe_fail G6 "coverage map still has MISSING"
    fi
    if ! grep -qE '☑ PASS|\[x\] PASS|Result:.*PASS' "$IMPL"; then
      maybe_fail G6 "no PASS evidence in 05-impl-log"
    fi
  fi
fi

# --- G7 ---
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
  fi
fi

# --- G8 ---
if need_gate G8; then
  file_ok "$TESTEV" || maybe_fail G8 "missing 06b-test-evidence.md"
  if file_ok "$TESTEV"; then
    if grep -qE 'paste test runner output here|# paste test runner output' "$TESTEV"; then
      maybe_fail G8 "test run output still placeholder"
    fi
    if ! grep -qE '```' "$TESTEV"; then
      maybe_fail G8 "test run output missing code fence"
    fi
    if grep -qiE 'Overall:.*☑ FAIL|Overall:.*\[x\] FAIL' "$TESTEV"; then
      maybe_fail G8 "Overall marked FAIL in 06b-test-evidence"
    fi
    if ! grep -qiE 'Overall:.*☑ PASS|Overall:.*\[x\] PASS|G8 verdict:.*☑ PASS|G8 verdict:.*\[x\] PASS' "$TESTEV"; then
      maybe_fail G8 "Overall/G8 PASS not checked"
    fi
    if ! grep -qiE '\*\*Dev:\*\*[[:space:]]*[A-Za-z0-9]|Dev:[[:space:]]*[A-Za-z0-9]' "$TESTEV"; then
      maybe_fail G8 "sign-off Dev name missing"
    fi

    sha="$(table_val "$TESTEV" "Commit SHA")"
    ci="$(table_val "$TESTEV" "CI run URL")"
    junit="$(table_val "$TESTEV" "JUnit")"
    if [[ -z "$junit" ]]; then junit="$(table_val "$TESTEV" "log path")"; fi

    if [[ "$REQUIRE_MACHINE" -eq 1 ]]; then
      if placeholderish "$sha" || [[ ! "$sha" =~ [0-9a-fA-F]{7,} ]]; then
        maybe_fail G8 "machine evidence: Commit SHA missing/invalid"
      fi
      if placeholderish "$ci" && placeholderish "$junit"; then
        maybe_fail G8 "machine evidence: need CI run URL or junit/xml/log path"
      fi
      if ! placeholderish "$ci" && [[ ! "$ci" =~ [Hh]ttps?:// ]] && [[ "$ci" != "N/A-local" ]]; then
        if placeholderish "$junit"; then
          maybe_fail G8 "machine evidence: CI URL must be http(s) or N/A-local with junit path"
        fi
      fi
    fi

    # CI-native verification
    if [[ "$VERIFY_NATIVE" -eq 1 ]]; then
      if ! placeholderish "$sha" && [[ "$sha" =~ [0-9a-fA-F]{7,} ]]; then
        verify_sha_git "$sha"
      fi
      if ! placeholderish "$junit"; then
        verify_junit_file "$junit"
      elif [[ "$ci" == "N/A-local" ]]; then
        maybe_fail G8 "CI-native: N/A-local requires existing junit/log path"
      fi
      if ! placeholderish "$ci" && [[ "$ci" =~ ^https?:// ]]; then
        verify_ci_url "$ci"
      fi
    fi

    if ui_ticket || grep -qiE 'Touches UI\?.*☑ Yes|Touches UI\?.*\[x\] Yes' "$TESTEV"; then
      if ! grep -qE '\|[[:space:]]*AC-[0-9]+[[:space:]]*\|[[:space:]]*[^|[:space:]]+' "$TESTEV"; then
        if [[ "$STRICT" -eq 1 || "$RISK" == "P0" ]]; then
          maybe_fail G8 "UI ticket requires screenshot/recording path"
        else
          warn "G8: UI ticket but screenshot paths look empty"
        fi
      fi
    fi
    if [[ "$STRICT" -eq 1 || "$RISK" == "P0" ]]; then
      out_lines="$(awk '/## Test run output/,/## Screenshots/{if($0 ~ /```/){c++} else if(c==1 && NF) print}' "$TESTEV" 2>/dev/null | wc -l | tr -d ' ' || true)"
      out_lines="${out_lines:-0}"
      if [[ "${out_lines}" -lt 2 ]]; then
        maybe_fail G8 "strict/P0: test output too thin"
      fi
    fi
  fi
fi

# --- G9 ---
if need_gate G9; then
  file_ok "$SHIP" || maybe_fail G9 "missing 07-ship.md"
  if file_ok "$SHIP"; then
    grep -qiE '## Ship safety|### Migration|### Feature flag|### Rollback' "$SHIP" \
      || maybe_fail G9 "07-ship missing Ship safety sections"
    if ! field_nonempty "$SHIP" "Rollback steps"; then
      if [[ "$RISK" != "P2" ]]; then
        maybe_fail G9 "Rollback steps empty/placeholder"
      else
        warn "G9: P2 rollback looks empty — confirm N/A"
      fi
    fi
    if [[ "$RISK" == "P0" || "$RISK" == "P1" ]]; then
      grep -qiE 'Has migration|Backward compatible|Migration' "$SHIP" || maybe_fail G9 "Migration section incomplete"
      grep -qiE 'Flag name|Feature flag|dark launch|N/A' "$SHIP" || maybe_fail G9 "Feature flag section incomplete"
      grep -qiE '### Canary|Canary %' "$SHIP" || maybe_fail G9 "Canary/soak section missing"
      canary_line="$(grep -i 'Canary %' "$SHIP" | head -1 || true)"
      if [[ -z "$canary_line" ]] || [[ "$canary_line" =~ \.\.\.|… ]]; then
        maybe_fail G9 "Canary % empty/placeholder"
      elif echo "$canary_line" | grep -qiE 'N/?A'; then
        reason="$(python3 -c "
import re,sys
s=sys.argv[1]
m=re.search(r'N/?A\s*[\(\[—:\-]*\s*(.*)', s, re.I)
print((m.group(1) if m else '').strip(' )]*'))
" "$canary_line" 2>/dev/null || true)"
        if [[ ${#reason} -lt 10 ]]; then
          maybe_fail G9 "Canary N/A needs reason ≥10 chars (e.g. N/A (internal tool only))"
        fi
      fi
      if ! field_nonempty "$SHIP" "Soak time"; then
        maybe_fail G9 "Soak time empty/placeholder"
      fi
      if ! field_nonempty "$SHIP" "on-call"; then
        maybe_fail G9 "Alert/owner on-call empty/placeholder"
      fi
      grep -qiE 'SLO|error-budget|error budget' "$SHIP" || maybe_fail G9 "SLO/error-budget note missing"
      # dashboard / log query must be URL or long concrete query
      dash="$(grep -iE 'Dashboard or log query' "$SHIP" | head -1 || true)"
      dash_val="$(echo "$dash" | sed -E 's/.*:[[:space:]]*//;s/\*//g;s/^[[:space:]]+//;s/[[:space:]]+$//')"
      if placeholderish "$dash_val" || [[ "$dash_val" =~ ^\.\.\.|… ]]; then
        maybe_fail G9 "Dashboard/log query empty"
      elif [[ ! "$dash_val" =~ ^https?:// ]] && [[ ${#dash_val} -lt 15 ]]; then
        maybe_fail G9 "Dashboard/log query must be http(s) URL or concrete query ≥15 chars"
      fi
    fi
  fi

  # Pilot mode: INDEX Pilot: ☑ yes → require ticket mentioned in pilot log
  if file_ok "$INDEX" && grep -qE 'Pilot:.*☑ yes|Pilot:.*\[x\] yes|Pilot:.*\[X\] yes' "$INDEX" 2>/dev/null; then
    pilot_hit=0
    if [[ -d "$PILOT_DIR" ]]; then
      if grep -R -l --include='PILOT*.md' -E "$TICKET" "$PILOT_DIR" >/dev/null 2>&1; then
        pilot_hit=1
      fi
    fi
    if [[ "$pilot_hit" -ne 1 ]]; then
      maybe_fail G9 "Pilot:yes but ticket $TICKET not found in $PILOT_DIR/PILOT*.md"
    fi
  fi
fi

file_ok "$INDEX" || warn "missing worklog INDEX.md"
echo "risk=$RISK machine_required=$REQUIRE_MACHINE verify_native=$VERIFY_NATIVE verify_net=$VERIFY_NET" >&2

if [[ "$JSON" -eq 1 ]]; then
  python3 - <<PY
import json
print(json.dumps({
  "ticket": "$TICKET",
  "project": "$PROJECT_SLUG",
  "worklog": "$WORKLOG",
  "min_gate": "$MIN_GATE",
  "risk": "$RISK",
  "strict": bool($STRICT),
  "verify_native": bool($VERIFY_NATIVE),
  "verify_net": bool($VERIFY_NET),
  "machine_required": bool($REQUIRE_MACHINE),
  "fails": $(printf '%s\n' "${FAILS[@]:-}" | python3 -c 'import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))'),
  "warns": $(printf '%s\n' "${WARNS[@]:-}" | python3 -c 'import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))'),
  "ok": $([[ ${#FAILS[@]} -eq 0 ]] && echo true || echo false),
}, indent=2))
PY
else
  echo "check-gates: ticket=$TICKET project=$PROJECT_SLUG min=$MIN_GATE risk=$RISK strict=$STRICT"
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
