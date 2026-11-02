#!/usr/bin/env bash
# Renders layout variants with the screenshot test and puts them side by side,
# so the user can pick one. No code is edited: each run passes
# --dart-define=VARIANT=<name>, which lib/shared/variant.dart exposes as the
# const `designVariant` for the widget under review. A name the widget doesn't
# check (e.g. "current") renders the code as it is.
#
#   tool/variants.sh [--out DIR] [--only shot1,shot2] [--crop X,Y,W,H] "<test name>" VARIANT…
#
#   "<test name>"  a testWidgets name in test/screenshot_test.dart
#   --out DIR      default build/variants/<test name> (gitignored)
#   --only …       stitch only these shots (PNG names without .png)
#   --crop …       cut this box from every shot, in PNG pixels (2×: 824 × 1784)
#
# Output: DIR/<variant>/*.png (+ test.log), DIR/<shot>.png side by side.
set -euo pipefail
cd "$(dirname "$0")/.."
export ANDROID_HOME=~/Android/Sdk PATH=~/development/flutter/bin:~/Android/Sdk/platform-tools:$PATH

out="" stitch_args=()
while (($#)); do
  case $1 in
    --out) out=$2; shift 2 ;;
    --only|--crop) stitch_args+=("$1" "$2"); shift 2 ;;
    -h|--help) sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "unknown option: $1 (see --help)" >&2; exit 2 ;;
    *) break ;;
  esac
done
(($# >= 2)) || { echo "usage: tool/variants.sh [options] \"<test name>\" VARIANT… (see --help)" >&2; exit 2; }
test_name=$1; shift
grep -q "'$test_name'" test/screenshot_test.dart ||
  { echo "no test named '$test_name' in test/screenshot_test.dart" >&2; exit 2; }
out=$(realpath -m "${out:-build/variants/${test_name// /_}}")

dirs=()
for v in "$@"; do
  dir="$out/$v"
  rm -rf "$dir"; mkdir -p "$dir"
  echo "rendering $v …"
  if ! SCREENSHOT_DIR="$dir" timeout 600 flutter test test/screenshot_test.dart \
    --plain-name "$test_name" --dart-define=VARIANT="$v" >"$dir/test.log" 2>&1; then
    echo "FAILED: variant $v, see $dir/test.log:"
    grep -E '\[E\]|EXCEPTION|Expected|Error' "$dir/test.log" | head -n 15
    exit 1
  fi
  if ! compgen -G "$dir/*.png" >/dev/null; then
    echo "no screenshots for $v: was the test skipped? ($dir/test.log)"; exit 1
  fi
  dirs+=("$dir")
done

uv run --quiet tool/stitch_variants.py --out "$out" "${stitch_args[@]}" "${dirs[@]}"
