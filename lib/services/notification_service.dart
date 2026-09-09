import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

/// Replaces the original web app's push-notification reminders with two
/// local daily notifications at 11:00 and 19:00.
///
/// NOTE on fidelity: the original backend could silently skip a reminder
/// server-side once you'd already answered that day. A pure local-notification
/// approach can't check "did I answer today?" at the exact fire moment
/// without a background task, so instead we cancel *today's* remaining
/// reminder(s) as soon as you answer correctly, and re-arm tomorrow's pair
/// the next time the app is opened (see [resync]). Good enough in practice,
/// but not a literal 1:1 port.
class NotificationService {
  static const _morningId = 1001;
  static const _eveningId = 1002;
  static const _prefsKey = 'reminders_enabled';

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);
    if (enabled) {
      await resync();
    } else {
      await _plugin.cancel(_morningId);
      await _plugin.cancel(_eveningId);
    }
  }

  /// Call on app start/resume: (re)schedules today's or tomorrow's 11:00 /
  /// 19:00 reminder for whichever of those times hasn't passed yet.
  static Future<void> resync() async {
    if (!await isEnabled()) return;
    await init();
    await _scheduleNext(_morningId, 11, 0, 'Today\'s curiosity is waiting',
        'You haven\'t read today\'s fact yet — takes about a minute.');
    await _scheduleNext(_eveningId, 19, 0, 'Keep your streak alive',
        'Quick reminder: today\'s fact & quiz are still open.');
  }

  /// Call after a correct/any quiz submission today: pulls today's
  /// still-pending reminder(s) so you don't get nagged after you've engaged.
  static Future<void> cancelTodayReminders() async {
    final now = DateTime.now();
    for (final entry in {_morningId: 11, _eveningId: 19}.entries) {
      final fireTime = DateTime(now.year, now.month, now.day, entry.value);
      if (fireTime.isAfter(now)) {
        await _plugin.cancel(entry.key);
      }
    }
  }

  static Future<void> _scheduleNext(
      int id, int hour, int minute, String title, String body) async {
    final next = _nextInstanceOf(hour, minute);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      next,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily reminders',
          channelDescription: 'Reminders to read today\'s fact and quiz',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
