import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';

/// "Monday", as shown in Settings.
String firstWeekdayLabel(FirstWeekday d) => switch (d) {
  FirstWeekday.monday => 'Monday',
  FirstWeekday.sunday => 'Sunday',
  FirstWeekday.saturday => 'Saturday',
};

/// The day weeks start on, for the Statistics calendar and week numbers.
class DatesScreen extends ConsumerWidget {
  const DatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final settings =
        ref.watch(settingsProvider).value ?? SettingsDao.defaultSettings;

    return Scaffold(
      appBar: AppBar(title: const Text('Dates')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Week starts on'),
            trailing: DropdownButton<FirstWeekday>(
              value: settings.firstWeekday,
              underline: const SizedBox(),
              items: [
                for (final d in FirstWeekday.values)
                  DropdownMenuItem(value: d, child: Text(firstWeekdayLabel(d))),
              ],
              onChanged: (d) => db.settingsDao.updateSettings(
                SettingsTableCompanion(firstWeekday: Value(d!)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
