import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    try {
      final TimezoneInfo timeZoneName =
          await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(
        tz.getLocation(timeZoneName.localizedName?.name ?? "Asia/Jakarta"),
      );
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await _notificationsPlugin.initialize(settings: initSettings);
    _isInitialized = true;
  }

  Future<bool> requestPermission() async {
    if (!_isInitialized) await init();

    bool granted = false;

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? result = await androidImplementation
          ?.requestNotificationsPermission();

      await androidImplementation?.requestExactAlarmsPermission();

      granted = result ?? false;
    } else if (Platform.isIOS) {
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      granted = result ?? false;
    }

    return granted;
  }

  Future<void> showInstantNotification({
    required String stringId,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await init();

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_channel',
        'Instant Notifications',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
        largeIcon: DrawableResourceAndroidBitmap('fintale_logo'),
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: stringId.hashCode,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  Future<void> scheduleCustomNotification({
    required String stringId,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_isInitialized) await init();

    int notificationId = stringId.hashCode;
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notificationsPlugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'scheduled_custom_channel',
          'Scheduled Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
          largeIcon: DrawableResourceAndroidBitmap('fintale_logo'),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> scheduleRoutineNotification({
    required String stringId,
    required String title,
    required String body,
    required int minute,
    required int hour,
    String? payload,
  }) async {
    if (!_isInitialized) await init();

    int notificationId = stringId.hashCode;

    if (await isNotificationScheduled(notificationId)) return;

    await _notificationsPlugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'scheduled_routine_channel',
          'Routine Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
          largeIcon: DrawableResourceAndroidBitmap('fintale_logo'),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await init();
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancelNotificationByStringId(String stringId) async {
    if (!_isInitialized) await init();
    await _notificationsPlugin.cancel(id: stringId.hashCode);
  }

  Future<bool> isNotificationScheduled(int id) async {
    if (!_isInitialized) await init();
    final List<PendingNotificationRequest> pendingNotifications =
        await _notificationsPlugin.pendingNotificationRequests();
    return pendingNotifications.any((notification) => notification.id == id);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
