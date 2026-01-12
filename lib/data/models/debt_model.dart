// lib/data/models/debt_model.dart

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

  // MENTOR FIX: Logika Jatuh Tempo yang Objektif
  // Mengambil jatuh tempo bulan berjalan tanpa lompat otomatis ke bulan depan
  DateTime get currentMonthDueDate {
    DateTime now = DateTime.now();
    try {
      return DateTime(now.year, now.month, dueDateDay);
    } catch (e) {
      // Handle jika tanggal 31 di bulan yang hanya sampai 30
      return DateTime(now.year, now.month + 1, 0); 
    }
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

  // Tambahkan method ini di dalam class DebtModel di lib/data/models/debt_model.dart

List<int> get overdueTenorIndices {
  if (isCompleted) return [];

  List<int> overdueIndices = [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Kita hitung dari tenor pertama (bulan setelah dateBorrowed)
  // hingga tenor terakhir yang seharusnya sudah dibayar sampai hari ini.
  for (int i = 1; i <= totalTenor; i++) {
    // Hitung tanggal jatuh tempo untuk tenor ke-i
    DateTime scheduledDate = DateTime(
      dateBorrowed.year,
      dateBorrowed.month + i,
      dueDateDay,
    );

    // Jika jadwalnya sudah lewat dari hari ini
    if (scheduledDate.isBefore(today) || scheduledDate.isAtSameMomentAs(today)) {
      // Cek apakah tenor ini sudah dibayar?
      // Logika: Jika tenor ke-i lebih besar dari jumlah tenor yang sudah dibayar
      int paidTenorCount = totalTenor - remainingTenor;
      if (i > paidTenorCount) {
        overdueIndices.add(i);
      }
    }
  }
  return overdueIndices;
}
}