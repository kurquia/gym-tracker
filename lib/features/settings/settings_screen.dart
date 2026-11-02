import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import 'backup_screen.dart';
import 'dates_screen.dart';
import 'units_screen.dart';
import 'workout_settings_screen.dart';

/// The Settings tab: a list of the settings pages, and About.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsProvider).value ?? SettingsDao.defaultSettings;
    final lastBackup = ref.watch(lastBackupProvider).value;
    Widget link(IconData icon, String title, String subtitle, String route) =>
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(route),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          link(
            Icons.straighten,
            'Units',
            [
              settings.weightUnit.name,
              settings.distanceUnit.name,
              lengthUnitLabel(settings.lengthUnit),
            ].join(' · '),
            '/settings/units',
          ),
          link(
            Icons.calendar_today_outlined,
            'Dates',
            'Week starts on ${firstWeekdayLabel(settings.firstWeekday)}',
            '/settings/dates',
          ),
          link(
            Icons.timer_outlined,
            'Workout',
            '${restStyleLabels[settings.restStyle]} · '
                'rest alert: ${restAlertLabels[settings.restAlert]!.toLowerCase()}',
            '/settings/workout',
          ),
          link(
            Icons.backup_outlined,
            'Backup',
            'Last: ${formatBackupTime(lastBackup)}',
            '/settings/backup',
          ),
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text('English (Spanish coming later)'),
          ),
          const ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text('Theme'),
            subtitle: Text('Dark (light and custom colours coming later)'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Gym Tracker',
              applicationVersion: '1.0.0',
              applicationIcon: Image.asset(
                'assets/icon/icon.png',
                width: 48,
                height: 48,
              ),
              children: const [
                SizedBox(height: 16),
                Text(
                  'App icon: "Atlas" by Delapouite, game-icons.net, CC BY 3.0.\n'
                  'Font: TeX Gyre Schola, GUST Font License.\n'
                  '3D body: based on Z-Anatomy (CC BY-SA 4.0), built on '
                  'BodyParts3D, © The Database Center for Life Science. The '
                  'body model is shared under CC BY-SA 4.0.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
