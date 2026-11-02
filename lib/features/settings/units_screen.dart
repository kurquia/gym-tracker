import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';

/// Short unit names, as shown in Settings and next to numbers.
String lengthUnitLabel(LengthUnit u) => switch (u) {
  LengthUnit.cm => 'cm',
  LengthUnit.inch => 'in',
};

/// Weight, distance and body-measurement units. Weights are always stored
/// in kg; the unit only changes what is shown and typed.
class UnitsScreen extends ConsumerWidget {
  const UnitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final settings =
        ref.watch(settingsProvider).value ?? SettingsDao.defaultSettings;

    return Scaffold(
      appBar: AppBar(title: const Text('Units')),
      body: ListView(
        children: [
          SegmentedSetting(
            title: 'Weight',
            options: const {WeightUnit.kg: 'kg', WeightUnit.lb: 'lb'},
            selected: settings.weightUnit,
            onChanged: (u) => db.settingsDao.updateSettings(
              SettingsTableCompanion(weightUnit: Value(u)),
            ),
          ),
          SegmentedSetting(
            title: 'Distance',
            options: const {DistanceUnit.km: 'km', DistanceUnit.mi: 'mi'},
            selected: settings.distanceUnit,
            onChanged: (u) => db.settingsDao.updateSettings(
              SettingsTableCompanion(distanceUnit: Value(u)),
            ),
          ),
          SegmentedSetting(
            title: 'Body measurements',
            options: const {LengthUnit.cm: 'cm', LengthUnit.inch: 'in'},
            selected: settings.lengthUnit,
            onChanged: (u) => db.settingsDao.updateSettings(
              SettingsTableCompanion(lengthUnit: Value(u)),
            ),
          ),
        ],
      ),
    );
  }
}

/// One setting as a segmented button: `[ kg | lb ]`.
class SegmentedSetting<T> extends StatelessWidget {
  const SegmentedSetting({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: SegmentedButton<T>(
        showSelectedIcon: false,
        segments: [
          for (final MapEntry(key: value, value: label) in options.entries)
            ButtonSegment(value: value, label: Text(label)),
        ],
        selected: {selected},
        onSelectionChanged: (s) => onChanged(s.single),
      ),
    );
  }
}
