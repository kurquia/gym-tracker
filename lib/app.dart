import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/providers.dart';
import 'features/record/workout_notification.dart';
import 'router.dart';
import 'shared/theme.dart';

/// The app itself: theme, router, the workout notification kept in step with
/// the open workout, and the daily backup.
class GymTrackerApp extends ConsumerStatefulWidget {
  const GymTrackerApp({super.key});

  @override
  ConsumerState<GymTrackerApp> createState() => _GymTrackerAppState();
}

class _GymTrackerAppState extends ConsumerState<GymTrackerApp> {
  final _router = buildRouter();
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // The daily automatic backup: checked at start and when the app goes to
    // the background (it runs only if the newest is over a day old).
    _lifecycle = AppLifecycleListener(onHide: _dailyBackup);
    WidgetsBinding.instance.addPostFrameCallback((_) => _dailyBackup());
  }

  void _dailyBackup() =>
      ref.read(backupsProvider)?.autoInBackground(daily: true);

  @override
  void dispose() {
    _lifecycle.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(workoutNotificationProvider);
    return MaterialApp.router(
      title: 'Gym Tracker',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: _router,
    );
  }
}
