#!/usr/bin/env bash
# pilot-score.sh — score a PILOT-*.md file (machine Scores block).
# Exit 0 = meets expert success bar. Exit 1 = miss. Exit 2 = usage.
set -euo pipefail

FILE="${1:-}"
if [[ -z "$FILE" || ! -f "$FILE" ]]; then
  echo "Usage: $0 <path/to/PILOT-v0.4.md>" >&2
  exit 2
fi

get() {
  local k="$1"
  grep -E "^${k}=" "$FILE" | tail -1 | cut -d= -f2- | tr -d '[:space:]' || echo ""
}

req() {
  local k="$1" v
  v="$(get "$k")"
  if [[ -z "$v" || ! "$v" =~ ^[0-9]+$ ]]; then
    echo "FAIL: missing/invalid $k in Scores (machine) block" >&2
    exit 1
  fi
  echo "$v"
}

bm=$(req baseline_miss_spec)
pm=$(req pilot_miss_spec)
br=$(req baseline_reopen)
pr=$(req pilot_reopen)
be=$(req baseline_escape)
pe=$(req pilot_escape)
gb=$(req gate_blocks)
tc=$(req tickets_completed)

ok=1
half() {
  # ceil(baseline/2) using integers: (b+1)/2
  local b="$1"
  echo $(( (b + 1) / 2 ))
}

check_metric() {
  local name="$1" base="$2" pilot="$3"
  local lim
  lim="$(half "$base")"
  if [[ "$pilot" -gt "$lim" ]]; then
    echo "FAIL: $name pilot=$pilot > target≤$lim (baseline=$base)" >&2
    ok=0
  else
    echo "PASS: $name pilot=$pilot ≤ $lim (baseline=$base)"
  fi
}

echo "pilot-score: $FILE"
if [[ "$tc" -lt 10 ]]; then
  echo "FAIL: tickets_completed=$tc < 10" >&2
  ok=0
else
  echo "PASS: tickets_completed=$tc"
fi

check_metric miss-spec "$bm" "$pm"
check_metric reopen "$br" "$pr"
check_metric escape "$be" "$pe"

if [[ "$gb" -lt 1 ]]; then
  echo "FAIL: gate_blocks=$gb < 1" >&2
  ok=0
else
  echo "PASS: gate_blocks=$gb"
fi

if [[ "$ok" -eq 1 ]]; then
  echo "RESULT: PASS (expert success bar met)"
  exit 0
fi
echo "RESULT: FAIL"
exit 1
