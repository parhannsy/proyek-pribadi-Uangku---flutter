// lib/data/models/needs_model.dart

import 'package:flutter/material.dart';

class NeedsModel {
  final String id;
  final String category;
  final int budgetLimit;
  final int usedAmount; 
  final int colorValue;

  NeedsModel({
    required this.id,
    required this.category,
    required this.budgetLimit,
    this.usedAmount = 0,
    required this.colorValue,
  });

  Color get color => Color(colorValue);
  int get remainingAmount => budgetLimit - usedAmount;

  double get percentageUsed {
    if (budgetLimit <= 0) return 0.0;
    return (usedAmount / budgetLimit).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'budget_limit': budgetLimit,
      'color_value': colorValue,
    };
  }

  factory NeedsModel.fromMap(Map<String, dynamic> map) {
    return NeedsModel(
      id: map['id'] as String,
      category: map['category'] as String,
      budgetLimit: map['budget_limit'] as int,
      colorValue: map['color_value'] as int,
      // MENTOR NOTE: Mengambil used_amount langsung dari hasil JOIN query
      // Menggunakan casting num lalu toInt() untuk menghindari error tipe data double dari SUM()
      usedAmount: (map['used_amount'] as num? ?? 0).toInt(),
    );
  }

  NeedsModel copyWith({
    String? id,
    String? category,
    int? budgetLimit,
    int? usedAmount,
    int? colorValue,
  }) {
    return NeedsModel(
      id: id ?? this.id,
      category: category ?? this.category,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      usedAmount: usedAmount ?? this.usedAmount,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}