// lib/application/flow/arus_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uangku/data/models/arus_model.dart'; 
import 'package:uangku/data/models/enums/arus_type.dart'; 

part 'arus_state.freezed.dart';

@freezed
class ArusState with _$ArusState {
  const factory ArusState({
    // Status Loading
    @Default(true) bool isLoading,

    // Data Utama (Daftar Transaksi)
    @Default([]) List<Arus> aruses,
    
    // Status Tab yang Aktif
    required ArusType currentActiveTab, 

    // Rekapitulasi Keuangan
    @Default(0.0) double totalIncome,
    @Default(0.0) double totalExpense,
    
    // Anchor Periode (Cukup satu DateTime sebagai jangkar bulan/tahun)
    // KOREKSI MENTOR: endDate dihapus karena kita menggunakan query strftime MM-YYYY
    required DateTime startDate,

    // Status Error
    String? failureMessage,
  }) = _ArusState;

  factory ArusState.initial() {
    final now = DateTime.now();
    
    return ArusState(
      isLoading: true,
      // Default ke tanggal 1 bulan berjalan
      startDate: DateTime(now.year, now.month, 1),
      currentActiveTab: ArusType.expense, 
    );
  }
}