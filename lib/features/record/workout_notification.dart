import 'dart:async';
import 'dart:io';
import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../shared/format.dart';

/// What the workout notification shows: [title], the clock below it, then
/// [text]. The clock ticks from [ticksFrom] (up from it, or down to it if
/// [countDown]); with [ticksFrom] null it stands at [stoppedAt].
typedef NotificationContent = ({
  String title,
  DateTime? ticksFrom,
  bool countDown,
  Duration stoppedAt,
  String text,
});

/// What follows the last ticked set: the next exercise mid-round of a
/// superset or a drop set, else when the rest ends ([RestStyle.clock]) or that it has
/// ([RestStyle.countdown]); null with no ticked set or no rest.
String? restStatus(ActiveWorkout workout, RestStyle style, DateTime now) {
  final last = workout.lastTicked;
  if (last == null) return null;
  // Mid-round of a superset: straight on to the next exercise.
  if (workout.nextInRound(last) case final next?
      when last.restSeconds == null) {
    return 'Now: ${next.exercise.name}';
  }
  if (workout.dropFollows(last) && last.restSeconds == null) {
    return 'Now: drop set';
  }
  final end = workout.restEndAt(now);
  if (end == null) return null;
  return switch (style) {
    RestStyle.clock => 'Next set at ${formatClock(end)}',
    RestStyle.countdown => 'Rest over',
  };
}

/// The notification for [workout] at [now]; null when no workout is open.
NotificationContent? notificationContent(
  ActiveWorkout? workout,
  RestStyle style,
  DateTime now,
) {
  if (workout == null) return null;
  final session = workout.session;
  final running = session.clockRunningSince != null;

  // The rest runs on the workout clock: a paused clock pauses it too.
  final left = workout.restLeft(now);
  if (style == RestStyle.countdown && left != null) {
    // One timer only: the rest, not the workout clock.
    return (
      title: workout.title,
      ticksFrom: running ? now.add(left) : null,
      countDown: true,
      stoppedAt: left,
      text: running ? 'Rest' : 'Rest paused',
    );
  }

  final nextSet = restStatus(workout, style, now);
  return (
    title: workout.title,
    ticksFrom: running
        ? session.clockRunningSince!.subtract(session.clockBanked)
        : null,
    countDown: false,
    stoppedAt: workout.clockAt(now),
    text: [if (!running) 'Paused', ?nextSet].join(' · '),
  );
}

/// When the rest in progress ends, on the wall clock; null when there is
/// none, it is over, or the clock (and so the rest) is paused.
DateTime? restAlertAt(ActiveWorkout? workout, DateTime now) {
  if (workout == null || workout.session.clockRunningSince == null) return null;
  final left = workout.restLeft(now);
  return left == null ? null : now.add(left);
}

/// The Android channel for [alert]. A channel's sound and vibration are
/// fixed once created, so each choice gets its own id.
String restAlertChannel(RestAlert alert) => 'rest_alert_${alert.name}';

const _toggleClockAction = 'toggle_clock';

/// The notification's Pause/Resume button. Android runs this in a background
/// isolate, even when the app is closed; it toggles the clock and redraws the
/// notification itself in case the app isn't running to do it.
@pragma('vm:entry-point')
Future<void> onNotificationAction(NotificationResponse response) async {
  if (response.actionId != _toggleClockAction) return;
  DartPluginRegistrant.ensureInitialized();
  final db = AppDatabase.open();
  try {
    final workout = await db.workoutsDao.activeWorkout();
    if (workout == null) return;
    await db.workoutsDao.toggleClock(workout.session.id);
    await WorkoutNotification(requestPermission: false).update(
      await db.workoutsDao.activeWorkout(),
      await db.settingsDao.watchSettings().first,
      () {},
    );
  } finally {
    await db.close();
  }
}

/// Keeps one ongoing, silent Android notification in step with the open
/// workout (drawn natively by packages/clock_notification), and schedules the rest alert (vibration and/or sound when a rest
/// ends, delivered by Android even with the app closed). Tapping either opens the app.
class WorkoutNotification {
  WorkoutNotification({this.requestPermission = true});

  /// False in the background isolate, which has no screen to ask on.
  final bool requestPermission;

  final _plugin = FlutterLocalNotificationsPlugin();
  static const _clockNotification = MethodChannel('clock_notification');
  static const _alertId = 2; // 1: the workout notification (native)
  static const _icon = 'ic_stat_workout';

  Future<void>? _ready;
  (NotificationContent?, NotificationClock)? _shown;
  Timer? _refresh;

  /// When the scheduled rest alert goes off; [_alertKnown] is false until
  /// this instance has scheduled or cancelled it (an alert from earlier may
  /// still be pending, e.g. in the background isolate).
  DateTime? _alertAt;
  String? _alertChannel;
  bool _alertKnown = false;

  Future<void> _init() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_icon),
      ),
      onDidReceiveBackgroundNotificationResponse: onNotificationAction,
    );
    if (!requestPermission) return;
    // Android 13+ asks once; later calls return the stored answer.
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> update(
    ActiveWorkout? workout,
    AppSettings settings,
    void Function() onChange,
  ) async {
    final now = DateTime.now();
    final content = notificationContent(workout, settings.restStyle, now);
    final clock = settings.notificationClock;
    _refresh?.cancel();
    // A countdown ending changes the content by itself.
    if (content?.ticksFrom case final at? when content!.countDown) {
      _refresh = Timer(at.difference(now), onChange);
    }
    // The workout stream fires on every keystroke; only real changes go out.
    if ((content, clock) != _shown) {
      _shown = (content, clock);
      await _show(content, clock);
    }
    await _scheduleAlert(
      settings.restAlert == RestAlert.off ? null : restAlertAt(workout, now),
      settings.restAlert,
    );
  }

  Future<void> _show(
    NotificationContent? content,
    NotificationClock clock,
  ) async {
    if (content == null) {
      if (_ready != null) await _clockNotification.invokeMethod('cancel');
      return;
    }
    // Also registers the Pause/Resume handler, which the native side calls
    // through flutter_local_notifications.
    await (_ready ??= _init());
    await _clockNotification.invokeMethod('show', {
      'title': content.title,
      'text': content.text,
      'ticksFrom': content.ticksFrom?.millisecondsSinceEpoch,
      'countDown': content.countDown,
      'stoppedMs': content.stoppedAt.inMilliseconds,
      'button': content.ticksFrom != null ? 'Pause' : 'Resume',
      'action': _toggleClockAction,
      'icon': _icon,
      'redrawn': clock == NotificationClock.redrawn,
    });
  }

  Future<void> _scheduleAlert(DateTime? at, RestAlert alert) async {
    final channel = restAlertChannel(alert);
    final old = _alertAt;
    final same = at == null || old == null
        ? at == old
        : at.difference(old).abs() < const Duration(seconds: 1) &&
              channel == _alertChannel;
    if (_alertKnown && same) return;
    final pending = !_alertKnown || (old?.isAfter(DateTime.now()) ?? false);
    _alertKnown = true;
    _alertAt = at;
    _alertChannel = channel;

    if (at == null) {
      // A fired alert stays in the shade until it times out.
      if (pending && _ready != null) await _plugin.cancel(id: _alertId);
      return;
    }
    await (_ready ??= _init());
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      // Only the current combination stays in Android's notification settings.
      for (final c in await android.getNotificationChannels() ?? const []) {
        if (c.id.startsWith('rest_alert') && c.id != channel) {
          await android.deleteNotificationChannel(channelId: c.id);
        }
      }
    }
    final exact = await android?.canScheduleExactNotifications() ?? false;
    await _plugin.zonedSchedule(
      id: _alertId,
      title: 'Rest over',
      body: 'Time for the next set',
      scheduledDate: tz.TZDateTime.from(at, tz.UTC),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          'Rest alert',
          channelDescription: 'When a rest ends',
          icon: _icon,
          importance: Importance.high,
          priority: Priority.high,
          // The phone's notification sound, on the alarm volume, so it
          // sounds with the phone on vibrate too.
          playSound: alert.sounds,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          enableVibration: alert.vibrates,
          // Two short buzzes.
          vibrationPattern: alert.vibrates
              ? Int64List.fromList([0, 200, 150, 200])
              : null,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          timeoutAfter: 60000,
        ),
      ),
    );
  }

  void dispose() => _refresh?.cancel();
}

/// Mirrors the open workout in the notification shade. Android only; watched
/// once at the app root.
final workoutNotificationProvider = Provider<void>((ref) {
  if (!Platform.isAndroid) return;
  final notification = WorkoutNotification();
  ref.onDispose(notification.dispose);

  void sync() {
    final settings =
        ref.read(settingsProvider).value ?? SettingsDao.defaultSettings;
    notification.update(ref.read(activeWorkoutProvider).value, settings, sync);
  }

  ref.listen(activeWorkoutProvider, (_, _) => sync());
  ref.listen(settingsProvider, (_, _) => sync());
  sync();
});
