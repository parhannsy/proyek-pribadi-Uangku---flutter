import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/timezone.dart' as tz;

import 'package:timezone/data/latest_all.dart' as tz;



class NotificationService {

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();



  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();



  Future<void> init() async {

    tz.initializeTimeZones();

   

    const AndroidInitializationSettings androidSettings =

        AndroidInitializationSettings('@mipmap/ic_launcher'); // Gunakan icon app kamu



    const InitializationSettings initSettings = InitializationSettings(

      android: androidSettings,

    );



    await _notifications.initialize(initSettings);

  }



  /// Jadwalkan notifikasi untuk tenor hutang

  Future<void> scheduleDebtReminder({

    required int id, // Gunakan hash dari DebtID atau index

    required String title,

    required String body,

    required DateTime scheduledDate,

  }) async {

    // Jangan jadwalkan jika tanggal sudah lewat

    if (scheduledDate.isBefore(DateTime.now())) return;



    await _notifications.zonedSchedule(

      id,

      title,

      body,

      tz.TZDateTime.from(scheduledDate, tz.local),

      const NotificationDetails(

        android: AndroidNotificationDetails(

          'debt_reminders',

          'Pengingat Hutang',

          importance: Importance.max,

          priority: Priority.high,

        ),

      ),

      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

    );

  }



  /// Batalkan notifikasi jika hutang lunas

  Future<void> cancelNotification(int id) async {

    await _notifications.cancel(id);

  }

}