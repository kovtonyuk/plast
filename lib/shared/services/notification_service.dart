import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/event_model.dart';
import '../models/first_unit_member_model.dart';
import '../models/goal_model.dart';
import '../../../l10n/app_localizations.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Lazily create the plugin only on mobile; on web we keep a no-op service
  // because flutter_local_notifications is not supported on the web.
  final FlutterLocalNotificationsPlugin? _notifications =
      kIsWeb ? null : FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const _androidChannel = AndroidNotificationChannel(
    'plast_events',
    'Події Пласту',
    description: 'Сповіщення про події',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_isInitialized) return;
    if (kIsWeb) {
      _isInitialized = true;
      return;
    }

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications!.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (!kIsWeb) {
      final androidPlugin = _notifications!
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(_androidChannel);
    }

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Notification tapped
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await _notifications!
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications!
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final result = await androidPlugin?.requestNotificationsPermission();
      // Also request exact alarm permission for Android 12+
      await androidPlugin?.requestExactAlarmsPermission();
      return result ?? false;
    }
    return false;
  }

  Future<void> scheduleEventNotification(EventModel event, AppLocalizations l10n) async {
    if (kIsWeb) return;
    if (event.remindBeforeMinutes == null) return;

    await initialize();

    final notificationTime = event.startDate.subtract(
      Duration(minutes: event.remindBeforeMinutes!),
    );

    if (notificationTime.isBefore(DateTime.now())) return;

    final title = _getEventTypeTitle(event.eventType, l10n);
    final body = event.remindBeforeMinutes == 0
        ? 'Подія "${event.title}" починається зараз'
        : 'Подія "${event.title}" ($title) почнеться через ${_formatDuration(event.remindBeforeMinutes!)}';

    await _notifications!.zonedSchedule(
      event.id.hashCode,
      title,
      body,
      tz.TZDateTime.from(notificationTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: event.id,
    );
  }

  Future<void> cancelEventNotification(String eventId) async {
    if (kIsWeb) return;
    await _notifications?.cancel(eventId.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await _notifications?.cancelAll();
  }

  Future<void> scheduleBirthdayNotification(FirstUnitMemberModel member) async {
    if (kIsWeb) return;
    if (member.dateOfBirth == null) return;

    await initialize();

    final now = DateTime.now();
    final birthday = member.dateOfBirth!;

    // Calculate next birthday
    var nextBirthday = DateTime(now.year, birthday.month, birthday.day);

    // If birthday has passed this year, schedule for next year
    if (nextBirthday.isBefore(now) || nextBirthday.isAtSameMomentAs(now)) {
      nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
    }

    // Schedule for 10:00 AM Kyiv time (UTC+3) the day before
    final notificationDate = tz.TZDateTime(
      tz.local,
      nextBirthday.year,
      nextBirthday.month,
      nextBirthday.day,
      10, // 10 AM
      0,
      0,
    ).subtract(const Duration(days: 1));

    // If the notification time has passed, don't schedule
    if (notificationDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    final memberName = '${member.firstName} ${member.lastName}';

    await _notifications!.zonedSchedule(
      member.id.hashCode,
      'Нагадування про день народження',
      'Завтра день народження у $memberName!',
      notificationDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: member.id,
    );
  }

  Future<void> cancelBirthdayNotification(String memberId) async {
    if (kIsWeb) return;
    await _notifications?.cancel(memberId.hashCode);
  }

  Future<void> scheduleGoalNotification(GoalModel goal) async {
    if (kIsWeb) return;
    await initialize();

    final notificationTime = goal.targetDate;

    if (notificationTime.isBefore(DateTime.now())) return;

    // Schedule for 10:00 AM Kyiv time (UTC+3)
    final notificationDate = tz.TZDateTime(
      tz.local,
      notificationTime.year,
      notificationTime.month,
      notificationTime.day,
      10, // 10 AM
      0,
      0,
    );

    // If the notification time has passed, don't schedule
    if (notificationDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notifications!.zonedSchedule(
      goal.id.hashCode,
      'Нагадування про ціль',
      'Сьогодні крайній день для цілі "${goal.title}"!',
      notificationDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: goal.id,
    );
  }

  Future<void> cancelGoalNotification(String goalId) async {
    if (kIsWeb) return;
    await _notifications?.cancel(goalId.hashCode);
  }

  Future<void> scheduleBirthdayNotificationFull(
    FirstUnitMemberModel member,
  ) async {
    if (kIsWeb) return;
    if (member.dateOfBirth == null) return;

    await initialize();

    // Scheduling birthday notifications for ${member.firstName} ${member.lastName}

    final now = DateTime.now();
    final birthday = member.dateOfBirth!;

    var nextBirthday = DateTime(now.year, birthday.month, birthday.day);

    if (nextBirthday.isBefore(now) || nextBirthday.isAtSameMomentAs(now)) {
      nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
    }

    final memberName = '${member.firstName} ${member.lastName}';

    final birthdayDate = tz.TZDateTime(
      tz.local,
      nextBirthday.year,
      nextBirthday.month,
      nextBirthday.day,
      10,
      0,
      0,
    );

    final dayBeforeBirthday = birthdayDate.subtract(const Duration(days: 1));

    if (dayBeforeBirthday.isAfter(tz.TZDateTime.now(tz.local))) {
      // Scheduling day-before notification
      await _notifications!.zonedSchedule(
        '${member.id}_day_before'.hashCode,
        'Нагадування про день народження',
        'Завтра день народження у $memberName!',
        dayBeforeBirthday,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: member.id,
      );
      // Day-before notification scheduled
    }

    if (birthdayDate.isAfter(tz.TZDateTime.now(tz.local))) {
      // Scheduling birthday notification
      await _notifications!.zonedSchedule(
        member.id.hashCode,
        'День народження!',
        'Сьогодні день народження у $memberName! 🎉',
        birthdayDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: member.id,
      );
      // Birthday notification scheduled
    }
  }

  Future<void> cancelBirthdayNotificationsFull(String memberId) async {
    if (kIsWeb) return;
    await _notifications?.cancel(memberId.hashCode);
    await _notifications?.cancel('${memberId}_day_before'.hashCode);
  }

  String _getEventTypeTitle(String eventType, AppLocalizations l10n) {
    switch (eventType) {
      case 'training':
        return l10n.training;
      case 'camp':
        return l10n.camp;
      case 'event':
        return l10n.event;
      case 'goal':
        return l10n.goal;
      default:
        return l10n.event;
    }
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes хв';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      return '$hours год';
    } else {
      final days = minutes ~/ 1440;
      return '$days днів';
    }
  }

  static List<ReminderOption> reminderOptions(AppLocalizations l10n) => [
    ReminderOption(value: 0, label: l10n.reminderAtStart),
    ReminderOption(value: 5, label: l10n.reminder5min),
    ReminderOption(value: 15, label: l10n.reminder15min),
    ReminderOption(value: 30, label: l10n.reminder30min),
    ReminderOption(value: 60, label: l10n.reminder1hour),
    ReminderOption(value: 120, label: l10n.reminder2hours),
    ReminderOption(value: 1440, label: l10n.reminder1day),
    ReminderOption(value: 2880, label: l10n.reminder2days),
    ReminderOption(value: 10080, label: l10n.reminder1week),
  ];
}

class ReminderOption {
  final int value;
  final int label;

  const ReminderOption({required this.value, required this.label});
}
