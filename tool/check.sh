#!/usr/bin/env bash
# "Done means checked": dart format, flutter analyze, flutter test (the same
# steps as CI), and it refreshes docs/code-map.html. Prints a short summary and
# the failing tests; exits 0 only when analyze and the tests pass. Takes ~2 min.
#
#   tool/check.sh [log dir]      (default: build/check, gitignored)
#
# Full outputs: <log dir>/analyze.log, <log dir>/test.log. The tests run under
# `timeout 600` because a failing widget test can hang instead of failing.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
export ANDROID_HOME=~/Android/Sdk PATH=~/development/flutter/bin:~/Android/Sdk/platform-tools:$PATH

logs=${1:-build/check}
mkdir -p "$logs"
status=0

# 1. Format (rewrites files in place).
if format=$(dart format lib test 2>&1); then
  echo "format:  $(tail -n 1 <<<"$format")"
else
  echo "format:  FAILED"; echo "$format" | tail -n 20; status=1
fi

# 2. Code map: the file only changes when the code did. Warnings don't fail.
if map=$(uv run --quiet tool/code_map.py 2>&1); then
  echo "map:     $map"
else
  echo "map:     FAILED"; echo "$map" | tail -n 20; status=1
fi

# 3. Analyze: any issue (info included) fails, as in CI.
if flutter analyze >"$logs/analyze.log" 2>&1; then
  echo "analyze: no issues"
else
  echo "analyze: FAILED ($(grep -c ' • ' "$logs/analyze.log") issues, $logs/analyze.log)"
  grep ' • ' "$logs/analyze.log" | head -n 20 | sed 's/^ */  /'
  status=1
fi

# 4. Tests.
timeout 600 flutter test --reporter expanded >"$logs/test.log" 2>&1
code=$?
last=$(grep -E '^[0-9]+:[0-9]+ \+[0-9]+' "$logs/test.log" | tail -n 1)
counts=$(grep -oE '\+[0-9]+( ~[0-9]+)?( -[0-9]+)?' <<<"$last" | head -n 1)
# A killed run can exit 0 with failures counted; trust the "-N" too.
if [[ $code == 0 && $counts == *-* ]]; then code=1; fi
if [[ $code == 0 ]]; then
  echo "test:    passed ($counts)"
elif [[ $code == 124 ]]; then
  echo "test:    TIMED OUT after 600 s ($counts so far; $logs/test.log)"
  echo "  last test running: ${last#*: }"
  status=1
else
  echo "test:    FAILED ($counts; $logs/test.log)"
  # Flutter lists the failures at the end; fall back to the [E] lines.
  if grep -q '^Failing tests:' "$logs/test.log"; then
    sed -n '/^Failing tests:/,$p' "$logs/test.log" | tail -n +2 | grep -v '^$' | head -n 30
  else
    grep -E '\[E\]$' "$logs/test.log" | sed -E 's/^[0-9:]+ [^:]*: /  /' | head -n 30
  fi
  status=1
fi

exit $status
