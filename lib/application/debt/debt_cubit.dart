// lib/application/debt/debt_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangku/application/debt/debt_state.dart';
import 'package:uangku/data/models/debt_model.dart';
import 'package:uangku/data/models/arus_model.dart'; 
import 'package:uangku/data/models/enums/arus_type.dart';
import 'package:uangku/data/repositories/debt_repository.dart';
import 'package:uangku/data/repositories/arus_repository.dart';

class DebtCubit extends Cubit<DebtState> {
  final DebtRepository _repository;
  final ArusRepository _arusRepository;

  DebtCubit(this._repository, this._arusRepository) : super(DebtInitial());

  /// Helper Internal untuk menghitung skor prioritas
  /// Semakin RENDAH skor, semakin TINGGI posisinya di daftar
  int _calculatePriorityScore(DebtModel debt, DateTime today) {
    if (debt.isCompleted) return 1000; // Paling bawah

    final nextDueDate = debt.nextDueDate;
    final diff = nextDueDate.difference(today).inDays;

    // 1. Prioritas Utama: Nunggak dari bulan-bulan lalu (Overdue parah)
    final bool hasPastMonthDebt = debt.overdueTenorIndices.any((index) {
      DateTime d = DateTime(debt.dateBorrowed.year, debt.dateBorrowed.month + index, debt.dueDateDay);
      return d.isBefore(DateTime(today.year, today.month, 1));
    });
    if (hasPastMonthDebt) return 1;

    // 2. Prioritas Kedua: Jatuh tempo HARI INI
    if (diff == 0) return 2;

    // 3. Prioritas Ketiga: Sudah lewat tanggal di bulan berjalan (Nunggak baru)
    if (diff < 0) return 3;

    // 4. Prioritas Keempat: Mepeet (Radius 7 hari ke depan)
    if (diff <= 7) return 4;

    // 5. Prioritas Kelima: Aman (Masih jauh)
    return 5;
  }

  Future<void> loadActiveDebts() async {
    try {
      emit(DebtLoading());
      final debts = await _repository.getAllDebts();
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // MENTOR REVISION: Urutan Berdasarkan Skala Prioritas Risiko
      debts.sort((a, b) {
        int scoreA = _calculatePriorityScore(a, today);
        int scoreB = _calculatePriorityScore(b, today);

        if (scoreA != scoreB) {
          return scoreA.compareTo(scoreB);
        }

        // Jika skor prioritas sama, urutkan berdasarkan tanggal terdekat
        return a.nextDueDate.compareTo(b.nextDueDate);
      });

      emit(DebtLoadSuccess(debts: debts));
    } catch (e) {
      emit(DebtLoadFailure(message: "Gagal memuat data: ${e.toString()}"));
    }
  }

  Future<void> addDebt(DebtModel debt) async {
    final lastState = state;
    try {
      emit(DebtOperationInProgress());
      await _repository.addDebt(debt);
      await loadActiveDebts(); // Gunakan loadActiveDebts agar sorting terpanggil
      emit(const DebtOperationSuccess(message: 'Data hutang berhasil ditambahkan.')); 
    } catch (e) {
      if (lastState is DebtLoadSuccess) emit(DebtLoadSuccess(debts: lastState.debts));
      emit(DebtOperationFailure("Gagal menambah hutang: ${e.toString()}"));
    }
  }

  Future<void> payTenor({
    required String debtId,
    required DateTime paymentDate,
    required String? imagePath, 
    required List<int> selectedTenors, 
  }) async {
    final lastState = state;
    if (selectedTenors.isEmpty) {
      emit(const DebtOperationFailure('Pilih minimal satu tenor untuk dibayar.'));
      return;
    }

    emit(DebtOperationInProgress());
    try {
      final allDebts = await _repository.getAllDebts(); 
      final debtIndex = allDebts.indexWhere((d) => d.id == debtId);
      if (debtIndex == -1) throw Exception('Data hutang tidak ditemukan.');

      final existingDebt = allDebts[debtIndex];
      final int newRemaining = (existingDebt.remainingTenor - selectedTenors.length).clamp(0, existingDebt.totalTenor);
      
      final updatedDebt = existingDebt.copyWith(
        remainingTenor: newRemaining,
        isCompleted: newRemaining == 0,
      );

      final double totalAmount = (existingDebt.amountPerTenor * selectedTenors.length).toDouble();
      final String tenorTags = selectedTenors.join(',');
      
      final newArus = Arus(
        type: ArusType.expense,
        category: 'Tagihan',
        amount: totalAmount,
        description: 'Bayar cicilan ${existingDebt.borrower} [T:$tenorTags]', 
        timestamp: paymentDate, 
        isRecurring: false,
        debtId: debtId, 
        imagePath: imagePath,
        needId: null, 
      );

      await _repository.updateDebt(updatedDebt);
      await _arusRepository.createArus(newArus); 

      await loadActiveDebts(); // Refresh dengan sorting terbaru
      emit(const DebtOperationSuccess(message: 'Pembayaran tenor berhasil dicatat!'));
    } catch (e) {
      if (lastState is DebtLoadSuccess) emit(DebtLoadSuccess(debts: lastState.debts));
      emit(DebtOperationFailure("Gagal memproses pembayaran: ${e.toString()}"));
    }
  }

  Future<void> completeDebt(String debtId) async {
    final lastState = state;
    try {
      emit(DebtOperationInProgress());
      await _repository.completeDebt(debtId); 
      await loadActiveDebts(); // Refresh dengan sorting terbaru
      emit(const DebtOperationSuccess(message: 'Hutang telah ditandai sebagai lunas.')); 
    } catch (e) {
      if (lastState is DebtLoadSuccess) emit(DebtLoadSuccess(debts: lastState.debts));
      emit(DebtOperationFailure("Gagal menyelesaikan hutang: ${e.toString()}"));
    }
  }
}