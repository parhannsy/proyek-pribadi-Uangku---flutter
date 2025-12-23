// lib/application/flow/arus_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangku/application/flow/arus_state.dart'; 
import 'package:uangku/data/models/arus_model.dart';
import 'package:uangku/data/repositories/arus_repository.dart'; 
import 'package:uangku/data/models/enums/arus_type.dart';

class ArusCubit extends Cubit<ArusState> {
  final ArusRepository _repository;

  ArusCubit(this._repository) : super(ArusState.initial());

  /// Mengubah tab aktif (Income/Expense) tanpa memicu reload database
  void toggleTab(ArusType newType) { 
    if (state.currentActiveTab != newType) {
      emit(state.copyWith(currentActiveTab: newType));
    }
  }

  /// METHOD UTAMA: Load data berdasarkan periode
  /// Mendukung pembersihan data lama otomatis (Retention Policy 6 Bulan)
  Future<void> initialize({int? month, int? year}) async {
    // 1. Ambil target bulan dan tahun
    final int targetMonth = month ?? state.startDate.month;
    final int targetYear = year ?? state.startDate.year;
    
    // 2. Update state ke loading
    emit(state.copyWith(
      isLoading: true,
      failureMessage: null,
      startDate: DateTime(targetYear, targetMonth, 1),
    ));

    try {
      // 3. MENTOR ADDITION: Auto-Cleanup (Pembersihan Data > 6 Bulan)
      // Kita jalankan tanpa 'await' agar proses pemuatan data utama tidak terhambat.
      // Ini adalah praktek profesional untuk maintenance task.
      _repository.deleteOldTransactions(6).catchError((e) {
        // Cukup log saja jika gagal, jangan gagalkan proses load data utama
        print("Log Maintenance: Gagal menghapus data lama -> $e");
      });

      // 4. Future.wait untuk performa (Concurrency)
      final results = await Future.wait([
        _repository.getAllArus(month: targetMonth, year: targetYear),
        _repository.getTotalIncome(month: targetMonth, year: targetYear),
        _repository.getTotalExpense(month: targetMonth, year: targetYear),
      ]);
      
      emit(state.copyWith(
        aruses: results[0] as List<Arus>,
        totalIncome: results[1] as double,
        totalExpense: results[2] as double,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        failureMessage: 'Gagal sinkronisasi data: ${e.toString()}',
      ));
    }
  }

  /// Menyimpan transaksi baru
  Future<void> createNewArus(Arus newArus) async {
    emit(state.copyWith(isLoading: true));

    try {
      await _repository.createArus(newArus);

      // Refresh pada periode yang sedang dilihat saat ini
      await initialize(
        month: state.startDate.month,
        year: state.startDate.year,
      ); 
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        failureMessage: 'Gagal menyimpan data: $e',
      ));
    }
  }

  /// Menghapus transaksi berdasarkan ID
  Future<void> deleteTransaction(int id) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _repository.deleteArus(id);
      
      // Refresh pada periode yang sedang aktif
      await initialize(
        month: state.startDate.month,
        year: state.startDate.year,
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        failureMessage: 'Gagal menghapus data: $e',
      ));
    }
  }

  /// Update Periode (Panggil ini saat user pilih tanggal di kalender)
  Future<void> updatePeriod(DateTime selectedDate) async {
    await initialize(
      month: selectedDate.month,
      year: selectedDate.year,
    );
  }
}