#!/usr/bin/env bash
# After a schema bump (and `dart run build_runner build`): writes the drift
# schema snapshot of the new version and regenerates the migration-test
# helpers. Not `drift_dev make-migrations`: it also writes an unused
# 2,800-line database.steps.dart.
#
#   tool/schema_snapshot.sh
#
# Commit drift_schemas/ and test/drift/default/generated/ with the bump.
set -euo pipefail
cd "$(dirname "$0")/.."
export ANDROID_HOME=~/Android/Sdk PATH=~/development/flutter/bin:~/Android/Sdk/platform-tools:$PATH

[[ ${1:-} == -h || ${1:-} == --help ]] && { sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0; }

[[ -f lib/data/database.g.dart ]] ||
  { echo "lib/data/database.g.dart is missing (a syntax error makes build_runner delete it): fix, rerun build_runner" >&2; exit 1; }
version=$(grep -oP 'schemaVersion => \K[0-9]+' lib/data/database.dart)
if [[ lib/data/database.dart -nt lib/data/database.g.dart || lib/data/tables.dart -nt lib/data/database.g.dart ]]; then
  echo "warning: database.dart/tables.dart are newer than database.g.dart: did build_runner run after the last edit?"
fi

dart run drift_dev schema dump lib/data/database.dart drift_schemas/default/
dart run drift_dev schema generate --data-classes --companions \
  drift_schemas/default/ test/drift/default/generated/

[[ -f drift_schemas/default/drift_schema_v$version.json ]] ||
  { echo "no drift_schemas/default/drift_schema_v$version.json after the dump" >&2; exit 1; }
[[ -f test/drift/default/generated/schema_v$version.dart ]] ||
  { echo "no test/drift/default/generated/schema_v$version.dart after generate" >&2; exit 1; }
echo "snapshot v$version written; now: tool/check.sh (migration_test.dart upgrades every snapshot to v$version)"
