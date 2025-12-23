// lib/data/models/debt_model.dart

import 'package:flutter/foundation.dart';

@immutable
class DebtModel {
  final String id;
  
  // Detail Peminjaman
  final String borrower; // Nama Platform / Pihak yang memberi hutang
  final String purpose;  // Kebutuhan meminjam

  // Detail Tanggal
  final DateTime dateBorrowed; // Tanggal meminjam
  final int dueDateDay;       // Tanggal jatuh tempo (misal: tanggal 25)

  // Detail Angsuran/Tenor
  final int totalTenor;         // Total tenor (misal: 12 bulan)
  final int remainingTenor;     // Sisa tenor
  final int amountPerTenor;     // Biaya/Nominal per tenor (angka, bukan string)

  // Status
  final bool isCompleted;      // Apakah hutang sudah lunas?

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
  
  // ===============================================
  // 1. Factory Constructor from Map (Dari DB/JSON)
  // ===============================================
  factory DebtModel.fromMap(Map<String, dynamic> map) {
    // Helper function untuk konversi aman dari dynamic ke int
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
      // Menggunakan casting ke num lalu toInt() untuk menghindari error double subtype
      dueDateDay: toIntSafe(map['dueDateDay']),
      totalTenor: toIntSafe(map['totalTenor']),
      remainingTenor: toIntSafe(map['remainingTenor']),
      amountPerTenor: toIntSafe(map['amountPerTenor']),
      // Konversi status lunas
      isCompleted: toIntSafe(map['isCompleted']) == 1, 
    );
  }

  // ===============================================
  // 2. Method to Map (Untuk disimpan ke DB/JSON)
  // ===============================================
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

  // ===============================================
  // 3. Helper Method: Mendapatkan Jatuh Tempo Bulan Depan
  // ===============================================
  DateTime get nextDueDate {
    DateTime now = DateTime.now();
    DateTime nextDate = DateTime(now.year, now.month, dueDateDay);

    if (nextDate.isBefore(now)) {
      nextDate = DateTime(now.year, now.month + 1, dueDateDay);
    }
    return nextDate;
  }
  
  // ===============================================
  // 4. Method copyWith (untuk State Management)
  // ===============================================
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