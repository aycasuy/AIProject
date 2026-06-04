import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    tz.initializeTimeZones(); // Zaman dilimlerini başlat

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Uygulama ikonun

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Bildirime tıklandı! Yük (Payload): ${response.payload}");
      },
    );
    // 🌟 ÇÖZÜM 1: ANDROID 13+ İÇİN BİLDİRİM VE ALARM İZNİ İSTEME KODU 🌟
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      await androidImplementation
          .requestNotificationsPermission(); // Bildirim izni
      await androidImplementation
          .requestExactAlarmsPermission(); // Tam saatinde alarm izni
    }
    // Android 13+ bildirim izni ve exact alarm izni burada istenir.
  }

  // 🌟 GÜNLÜK ANTRENMAN HATIRLATICISI KURMA
  Future<void> scheduleDailyWorkoutReminder(String username) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'daily_workout_channel',
          'Günlük Antrenman',
          channelDescription: 'Günlük kişisel egzersiz hatırlatıcıları',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFF118AB2),
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    // Her akşam saat 20:00 için ayarla
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      20, // Saat 20
      00, // Dakika 00
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // 🌟 GÜNCEL VERSİYON (Hatalı uiLocalNotificationDate satırı silindi)
    await _notificationsPlugin.zonedSchedule(
      id: 1,
      title: 'Zaman Daralıyor! 🔥',
      body:
          'Hey $username, bugünkü kişisel zayıf nokta antrenmanın seni bekliyor. Hemen tıkla ve serini koru!',
      scheduledDate: scheduledDate,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'open_daily_workout',
    );
  }

  // İstenirse bildirimi iptal etme
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // 🚨 HATA AYIKLAMA İÇİN ANINDA BİLDİRİM TESTİ
}
