import 'package:drift/drift.dart';

import '../database.dart';

part 'settings_dao.g.dart';

/// Reads and saves the single row of app settings.
@DriftAccessor(tables: [SettingsTable])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.attachedDatabase);

  static const defaultSettings = AppSettings(
    id: 1,
    weightUnit: WeightUnit.kg,
    distanceUnit: DistanceUnit.km,
    lengthUnit: LengthUnit.cm,
    restStyle: RestStyle.clock,
    restAlert: RestAlert.vibrationAndSound,
    firstWeekday: FirstWeekday.monday,
    notificationClock: NotificationClock.live,
  );

  Stream<AppSettings> watchSettings() =>
      (select(settingsTable)..where((s) => s.id.equals(1)))
          .watchSingleOrNull()
          .map((s) => s ?? defaultSettings);

  /// Writes the given fields; the others keep their value.
  Future<void> updateSettings(SettingsTableCompanion changes) =>
      into(settingsTable)
          .insertOnConflictUpdate(changes.copyWith(id: const Value(1)));
}
