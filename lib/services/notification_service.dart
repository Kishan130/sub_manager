import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/subscription.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); 

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
        
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: initSettings);
    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    if (!_isInitialized) await initialize();
    
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> cancelAllAlerts() async {
    if (!_isInitialized) await initialize();
    await _plugin.cancelAll();
    debugPrint('All scheduled billing alerts cancelled.');
  }

  Future<void> scheduleSubscriptionAlerts(List<Subscription> subscriptions) async {
    if (!_isInitialized) await initialize();
    
    await cancelAllAlerts();

    final now = DateTime.now();

    for (final sub in subscriptions) {
      if (sub.nextBillingDate == null) continue;

      if (sub.nextBillingDate!.isBefore(now)) continue;

      final billingDate = sub.nextBillingDate!;
      
      final threeDaysBefore = DateTime(
        billingDate.year,
        billingDate.month,
        billingDate.day - 3,
        10, 0, 0,
      );

      final oneDayBefore = DateTime(
        billingDate.year,
        billingDate.month,
        billingDate.day - 1,
        10, 0, 0,
      );

      if (threeDaysBefore.isAfter(now)) {
        await _scheduleNotification(
          id: sub.id.hashCode,
          title: 'Upcoming Bill: ${sub.name}',
          body: 'Your subscription of \u20B9${sub.cost.toStringAsFixed(2)} is due in 3 days.',
          scheduledDate: threeDaysBefore,
        );
      }

      if (oneDayBefore.isAfter(now)) {
        await _scheduleNotification(
          id: sub.id.hashCode ^ 0x01, 
          title: 'Reminder: ${sub.name} is due tomorrow!',
          body: 'Your subscription of \u20B9${sub.cost.toStringAsFixed(2)} is renewing tomorrow.',
          scheduledDate: oneDayBefore,
        );
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'billing_alerts',
      'Billing Alerts',
      channelDescription: 'Reminders for upcoming subscription renewals',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      color: Color(0xFF6200EA),
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    // flutter_local_notifications 21.0.0 uses named arguments for all parameters
    // and uiLocalNotificationDateInterpretation has been removed.
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    
    debugPrint('Scheduled alert [ID: $id] "$title" for $tzDate');
  }
}
