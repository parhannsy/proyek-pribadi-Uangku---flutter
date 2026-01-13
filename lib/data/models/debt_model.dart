import 'package:flutter/foundation.dart';

@immutable
class DebtModel {
  final String id;
  final String borrower; 
  final String purpose;  

  final DateTime dateBorrowed; 
  final int dueDateDay;       

  final int totalTenor;         
  final int remainingTenor;     
  final int amountPerTenor;     

  final bool isCompleted;      

  const DebtModel({
    required this.id,
    required this.borrower,
    required this.purpose,
    required this.dateBorrowed,
    required this.dueDateDay,
    required this.totalTenor,
    required this.remainingTenor,
    required this.amountPerTenor,
    this.isCompleted = false,
  }) : assert(dueDateDay >= 1 && dueDateDay <= 31, 'dueDateDay must be between 1 and 31');

  // ==========================================================
  // MENTOR FIX: INTERNAL DATE HELPER
  // ==========================================================
  
  /// Menghitung tanggal jatuh tempo untuk tenor ke-N secara aman.
  /// Menangani masalah overflow tgl 29/30/31 di bulan pendek (Februari).
  DateTime _calculateDueDateForTenor(int tenorIndex) {
    int year = dateBorrowed.year;
    int month = dateBorrowed.month + tenorIndex;

    // Normalisasi tahun dan bulan
    while (month > 12) {
      month -= 12;
      year += 1;
    }

    // Cari hari terakhir di bulan tersebut
    // DateTime dengan day: 0 akan mengambil hari terakhir bulan sebelumnya
    int lastDayInMonth = DateTime(year, month + 1, 0).day;
    int actualDay = dueDateDay > lastDayInMonth ? lastDayInMonth : dueDateDay;

    return DateTime(year, month, actualDay);
  }

  // ==========================================================
  // GETTERS
  // ==========================================================

  /// Mengambil tanggal jatuh tempo untuk tenor yang sedang berjalan saat ini.
  DateTime get nextDueDate {
    if (isCompleted) return dateBorrowed;

    // Tenor yang harus dibayar adalah setelah tenor yang sudah lunas
    final int nextTenorIndex = (totalTenor - remainingTenor) + 1;
    
    // Pastikan index tidak melebihi total tenor
    final int targetIndex = nextTenorIndex > totalTenor ? totalTenor : nextTenorIndex;
    
    return _calculateDueDateForTenor(targetIndex);
  }

  /// Alias untuk kompatibilitas widget
  DateTime get currentMonthDueDate => nextDueDate;

  /// Mengambil daftar indeks tenor yang sudah melewati jatuh tempo tapi belum dibayar.
  List<int> get overdueTenorIndices {
    if (isCompleted) return [];

    List<int> overdueIndices = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final int paidTenorCount = totalTenor - remainingTenor;

    for (int i = 1; i <= totalTenor; i++) {
      DateTime scheduledDate = _calculateDueDateForTenor(i);

      // Jika tanggal sudah lewat hari ini dan index tenor belum dibayar
      if (scheduledDate.isBefore(today)) {
        if (i > paidTenorCount) {
          overdueIndices.add(i);
        }
      }
    }
    return overdueIndices;
  }

  // ==========================================================
  // MAPPING & UTILS
  // ==========================================================

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    int toIntSafe(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    return DebtModel(
      id: map['id']?.toString() ?? '',
      borrower: map['borrower'] as String? ?? '',
      purpose: map['purpose'] as String? ?? '',
      dateBorrowed: map['dateBorrowed'] != null 
          ? DateTime.parse(map['dateBorrowed'] as String)
          : DateTime.now(),
      dueDateDay: toIntSafe(map['dueDateDay']),
      totalTenor: toIntSafe(map['totalTenor']),
      remainingTenor: toIntSafe(map['remainingTenor']),
      amountPerTenor: toIntSafe(map['amountPerTenor']),
      isCompleted: toIntSafe(map['isCompleted']) == 1, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'borrower': borrower,
      'purpose': purpose,
      'dateBorrowed': dateBorrowed.toIso8601String(),
      'dueDateDay': dueDateDay,
      'totalTenor': totalTenor,
      'remainingTenor': remainingTenor,
      'amountPerTenor': amountPerTenor,
      'isCompleted': isCompleted ? 1 : 0, 
    };
  }

  DebtModel copyWith({
    String? id,
    String? borrower,
    String? purpose,
    DateTime? dateBorrowed,
    int? dueDateDay,
    int? totalTenor,
    int? remainingTenor,
    int? amountPerTenor,
    bool? isCompleted,
  }) {
    return DebtModel(
      id: id ?? this.id,
      borrower: borrower ?? this.borrower,
      purpose: purpose ?? this.purpose,
      dateBorrowed: dateBorrowed ?? this.dateBorrowed,
      dueDateDay: dueDateDay ?? this.dueDateDay,
      totalTenor: totalTenor ?? this.totalTenor,
      remainingTenor: remainingTenor ?? this.remainingTenor,
      amountPerTenor: amountPerTenor ?? this.amountPerTenor,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}