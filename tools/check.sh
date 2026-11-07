#!/bin/sh
# Everything that must hold before a push, in one place (CI runs exactly this):
#   texture import policy → Godot import → tests (data schema included) → every generated doc up to date.
#     sh tools/check.sh            # from the repo root; Godot from $SANGUO_GODOT (default: the path every skill uses)
#     sh tools/check.sh --fast     # skip the Godot import (nothing new under godot/data/art)
# Exits non-zero on the first failure, saying which step.
set -u
cd "$(dirname "$0")/.." || exit 1
G="${SANGUO_GODOT:-/f/workspace/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe}"
PY="${PYTHON:-python}"
fail() { echo "check.sh: FAILED at $1" >&2; exit 1; }

echo "== texture import policy"
"$PY" tools/import_policy.py --check || fail "import policy (run: python tools/import_policy.py --write, then the Godot import)"

if [ "${1:-}" != "--fast" ]; then
	echo "== godot import"
	timeout 1200 "$G" --headless --path godot --import >/dev/null 2>&1
	"$PY" tools/import_policy.py --check || fail "import policy after import (new art came in: python tools/import_policy.py --write)"
fi

echo "== tests"
LOG="${TMPDIR:-/tmp}/sanguo-tests.log"
timeout 600 "$G" --headless --path godot --script res://tests/run_tests.gd >"$LOG" 2>&1
code=$?
grep -E "^  FAIL|^        |passed, " "$LOG"
[ $code -eq 124 ] && fail "tests (timed out — a script that does not parse?)"
grep -q "passed, 0 failed" "$LOG" || fail "tests (full log: $LOG)"

echo "== generated docs"
for gen in chapter_stats roster chapter_docs; do
	out=$("$PY" tools/$gen.py --check 2>&1) || { echo "$out" | tail -5; fail "docs ($gen.py output is stale: regenerate it — chapter_stats / roster take --write, chapter_docs no flag)"; }
	echo "$out" | tail -1
done
echo "check.sh: all good"
