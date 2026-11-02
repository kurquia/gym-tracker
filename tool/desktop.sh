#!/usr/bin/env bash
# (Re)starts the Linux desktop app in debug mode, detached, and waits until it
# runs or fails to build. Stops a running one first (flutter run + the app).
#
#   tool/desktop.sh [--backup [label]] [-- flutter run args…]
#
#   --backup [label]  copy ~/Documents/gym_tracker.sqlite (after stopping the
#                     app) to ~/Documents/gym_tracker_backups/
#                     gym_tracker-desktop-v<schema>-<date>[-<label>].sqlite
#   -- …              extra flutter run arguments, e.g. -- --dart-define=VARIANT=b
#
# The flutter run output goes to build/desktop.log; its VM service URI is printed.
# Waits up to 10 min for the first build.
set -euo pipefail
cd "$(dirname "$0")/.."
export ANDROID_HOME=~/Android/Sdk PATH=~/development/flutter/bin:~/Android/Sdk/platform-tools:$PATH

db=~/Documents/gym_tracker.sqlite
backups=~/Documents/gym_tracker_backups
log=build/desktop.log
backup=no label="" extra=()
while (($#)); do
  case $1 in
    --backup)
      backup=yes
      if [[ ${2:-} && $2 != -* ]]; then label=$2; shift; fi ;;
    --) shift; extra=("$@"); break ;;
    -h|--help) sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $1 (see --help)" >&2; exit 2 ;;
  esac
  shift
done

# Stop: the flutter tool (a dart process running "run -d linux") and the app.
bundle="$PWD/build/linux/x64/debug/bundle/gym_tracker"
stopped=no
for pattern in "flutter_tools\.snapshot run .*-d linux" "$bundle"; do
  if pkill -f -- "$pattern"; then stopped=yes; fi
done
if [[ $stopped == yes ]]; then
  for _ in $(seq 20); do
    pgrep -f -- "$bundle" >/dev/null || break
    sleep 0.5
  done
  if pgrep -f -- "$bundle" >/dev/null; then
    pkill -9 -f -- "$bundle" || true
  fi
  echo "stopped the running desktop app"
else
  echo "no desktop app was running"
fi

if [[ $backup == yes ]]; then
  mkdir -p "$backups"
  version=$(sqlite3 "$db" 'pragma user_version')
  name="gym_tracker-desktop-v$version-$(date +%F)${label:+-$label}"
  dest="$backups/$name.sqlite"
  [[ -e $dest ]] && dest="$backups/$name-$(date +%H%M%S).sqlite"
  sqlite3 "$db" ".backup '$dest'"
  check=$(sqlite3 "$dest" 'pragma integrity_check' 2>&1) || true
  echo "backup:  $dest (v$version, integrity $check)"
  [[ $check == ok ]] || exit 1
fi

# Start detached (its own session, so it outlives this shell).
mkdir -p "$(dirname "$log")"
setsid nohup flutter run -d linux --debug "${extra[@]}" </dev/null >"$log" 2>&1 &
pid=$!
echo "started flutter run (pid $pid), log $log; waiting for the build …"

for _ in $(seq 600); do
  if grep -q 'Flutter run key commands' "$log"; then
    echo "running: the desktop app is up"
    grep -m 1 -o 'Dart VM Service .* at: .*' "$log" || true
    exit 0
  fi
  if ! kill -0 "$pid" 2>/dev/null; then
    echo "FAILED: flutter run exited before the app started; end of $log:"
    tail -n 30 "$log"
    exit 1
  fi
  sleep 1
done
echo "TIMED OUT after 10 min waiting for the app; end of $log:"
tail -n 30 "$log"
exit 1
