// lib/data/models/arus_model.dart

import 'package:uangku/data/models/enums/arus_type.dart';

class Arus {
  final int? id;
  final ArusType type;
  final String category;
  final double amount;
  final String? description;
  final DateTime timestamp;
  final bool isRecurring;
  final String? debtId;    // Relasi untuk modul Hutang (LAMA)
  final String? imagePath; // Path gambar (V3)
  final String? needId;    // Relasi untuk modul Kebutuhan (BARU - V4)

  Arus({
    this.id,
    required this.type,
    required this.category,
    required this.amount,
    this.description,
    required this.timestamp,
    this.isRecurring = false,
    this.debtId,
    this.imagePath,
    this.needId, // Tambahkan di constructor
  });

  // Konversi dari Map SQLite ke Object Dart
  factory Arus.fromSqfliteMap(Map<String, dynamic> map) {
    return Arus(
      id: map['id'],
      type: map['type'] == 'income' ? ArusType.income : ArusType.expense,
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      description: map['description'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isRecurring: map['is_recurring'] == 1,
      debtId: map['debt_id'],
      imagePath: map['image_path'],
      needId: map['need_id'], // Map ke variabel baru
    );
  }

  // Konversi dari Object Dart ke Map SQLite
  Map<String, dynamic> toSqfliteMap() {
    return {
      'id': id,
      'type': type == ArusType.income ? 'income' : 'expense',
      'category': category,
      'amount': amount,
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'is_recurring': isRecurring ? 1 : 0,
      'debt_id': debtId,
      'image_path': imagePath,
      'need_id': needId, // Simpan ke kolom baru
    };
  }

  // Penting untuk update state di Cubit
  Arus copyWith({
    int? id,
    ArusType? type,
    String? category,
    double? amount,
    String? description,
    DateTime? timestamp,
    bool? isRecurring,
    String? debtId,
    String? imagePath,
    String? needId,
  }) {
    return Arus(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isRecurring: isRecurring ?? this.isRecurring,
      debtId: debtId ?? this.debtId,
      imagePath: imagePath ?? this.imagePath,
      needId: needId ?? this.needId,
    );
  }
}