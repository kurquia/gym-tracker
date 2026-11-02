import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';

/// Names for the rest-alert choices, as in Settings and the workout menu.
const restAlertLabels = {
  RestAlert.vibrationAndSound: 'Vibration + sound',
  RestAlert.vibration: 'Vibration',
  RestAlert.sound: 'Sound',
  RestAlert.off: 'Off',
};

/// Names for the rest styles ("Clock" in Settings and the workout menu).
const restStyleLabels = {
  RestStyle.clock: 'Timer',
  RestStyle.countdown: 'Rest countdown',
};

/// The notification clock styles.
const _clockLabels = {
  NotificationClock.live: 'Live clock',
  NotificationClock.redrawn: 'Plain text',
};
const _clockSubtitles = {
  NotificationClock.live:
      'On its own line, ticked by Android, also with the app closed',
  NotificationClock.redrawn:
      'Rewritten by the app every second; stops if the phone closes the app',
};

/// How rests are shown (Clock) and announced (Rest alert), and how the
/// notification shows the clock. The same settings are in the workout
/// menu (⋮) on the Record screen, except the notification's.
class WorkoutSettingsScreen extends ConsumerWidget {
  const WorkoutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final settings =
        ref.watch(settingsProvider).value ?? SettingsDao.defaultSettings;
    final heading = Theme.of(context).textTheme.titleSmall;

    Widget radios<T>(
      T selected,
      Map<T, String> labels,
      SettingsTableCompanion Function(T value) change, {
      Map<T, String>? subtitles,
    }) => RadioGroup<T>(
      groupValue: selected,
      onChanged: (v) => db.settingsDao.updateSettings(change(v as T)),
      child: Column(
        children: [
          for (final MapEntry(key: value, value: label) in labels.entries)
            RadioListTile<T>(
              value: value,
              title: Text(label),
              subtitle: subtitles == null ? null : Text(subtitles[value]!),
            ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Workout')),
      body: ListView(
        children: [
          ListTile(title: Text('Clock', style: heading)),
          radios(
            settings.restStyle,
            restStyleLabels,
            (s) => SettingsTableCompanion(restStyle: Value(s)),
          ),
          const Divider(),
          ListTile(
            title: Text('Rest alert', style: heading),
            subtitle: const Text(
              'When a rest ends, also with the screen locked. The sound is '
              "the phone's notification sound, on the alarm volume.",
            ),
          ),
          radios(
            settings.restAlert,
            restAlertLabels,
            (a) => SettingsTableCompanion(restAlert: Value(a)),
          ),
          const Divider(),
          ListTile(title: Text('Notification clock', style: heading)),
          radios(
            settings.notificationClock,
            _clockLabels,
            (c) => SettingsTableCompanion(notificationClock: Value(c)),
            subtitles: _clockSubtitles,
          ),
        ],
      ),
    );
  }
}
