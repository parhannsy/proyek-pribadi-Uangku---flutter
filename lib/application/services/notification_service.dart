// lib/application/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:uangku/utils/number_formatter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(initSettings);
  }

  /// Menjadwalkan rangkaian notifikasi selama 7 hari (H-6 sampai Hari H) pada pukul 07:00
  Future<void> scheduleDebtReminderSequence({
    required String debtId,
    required String borrower,
    required String purpose,
    required int amount,
    required DateTime dueDate,
  }) async {
    // Bersihkan jadwal lama untuk hutang ini sebelum menjadwalkan ulang
    await cancelNotificationSequence(debtId.hashCode);

    for (int i = 0; i < 7; i++) {
      // i=0 adalah Hari H, i=1 adalah H-1, dst.
      final scheduledDate = dueDate.subtract(Duration(days: i));
      
      // Target jam 7 pagi
      final targetTime = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        7, 0, 0,
      );

      // Jika waktu target sudah lewat dari waktu sekarang, abaikan hari tersebut
      if (targetTime.isBefore(DateTime.now())) continue;

      // ID unik untuk setiap hari dalam sekuens (hash + index hari)
      final notificationId = debtId.hashCode + i;

      String label = i == 0 ? "HARI INI" : "$i hari lagi";

      await _notifications.zonedSchedule(
        notificationId,
        'Tagihan $label: $borrower',
        'Segera bayar cicilan $purpose sebesar ${NumberFormatter.formatRupiah(amount)}',
        tz.TZDateTime.from(targetTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'debt_reminders_sequence',
            'Pengingat Harian Hutang',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  /// Membatalkan seluruh rangkaian 7 hari untuk satu hutang tertentu
  Future<void> cancelNotificationSequence(int debtHashId) async {
    for (int i = 0; i < 7; i++) {
      await _notifications.cancel(debtHashId + i);
    }
  }
}