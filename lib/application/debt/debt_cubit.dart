// lib/application/debt/debt_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangku/application/debt/debt_state.dart';
import 'package:uangku/data/models/debt_model.dart';
import 'package:uangku/data/models/arus_model.dart'; 
import 'package:uangku/data/models/enums/arus_type.dart';
import 'package:uangku/data/repositories/debt_repository.dart';
import 'package:uangku/data/repositories/arus_repository.dart';
import 'package:uangku/application/services/notification_service.dart';

class DebtCubit extends Cubit<DebtState> {
  final DebtRepository _repository;
  final ArusRepository _arusRepository;
  final NotificationService _notificationService = NotificationService();

  DebtCubit(this._repository, this._arusRepository) : super(DebtInitial());

  int _calculatePriorityScore(DebtModel debt, DateTime today) {
    if (debt.isCompleted) return 1000;

    final nextDueDate = debt.nextDueDate;
    final diff = nextDueDate.difference(today).inDays;

    final bool hasPastMonthDebt = debt.overdueTenorIndices.any((index) {
      DateTime d = DateTime(debt.dateBorrowed.year, debt.dateBorrowed.month + index, debt.dueDateDay);
      return d.isBefore(DateTime(today.year, today.month, 1));
    });
    if (hasPastMonthDebt) return 1;
    if (diff == 0) return 2;
    if (diff < 0) return 3;
    if (diff <= 7) return 4;
    return 5;
  }

  /// Helper untuk menjadwalkan notifikasi beruntun 7 hari (pukul 07:00)
  Future<void> _scheduleNextReminder(DebtModel debt) async {
    if (debt.isCompleted) {
      await _notificationService.cancelNotificationSequence(debt.id.hashCode);
      return;
    }

    await _notificationService.scheduleDebtReminderSequence(
      debtId: debt.id,
      borrower: debt.borrower,
      purpose: debt.purpose,
      amount: debt.amountPerTenor,
      dueDate: debt.nextDueDate,
    );
  }

  Future<void> loadActiveDebts() async {
    try {
      emit(DebtLoading());
      final debts = await _repository.getAllDebts();
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      debts.sort((a, b) {
        int scoreA = _calculatePriorityScore(a, today);
        int scoreB = _calculatePriorityScore(b, today);
        if (scoreA != scoreB) return scoreA.compareTo(scoreB);
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
      
      // Jadwalkan pengingat beruntun
      await _scheduleNextReminder(debt);

      await loadActiveDebts();
      emit(const DebtOperationSuccess(message: 'Hutang berhasil ditambah & pengingat diaktifkan.')); 
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
      
      final newArus = Arus(
        type: ArusType.expense,
        category: 'Tagihan',
        amount: totalAmount,
        description: 'Bayar cicilan ${existingDebt.borrower} [T:${selectedTenors.join(',')}]', 
        timestamp: paymentDate, 
        isRecurring: false,
        debtId: debtId, 
        imagePath: imagePath,
        needId: null, 
      );

      await _repository.updateDebt(updatedDebt);
      await _arusRepository.createArus(newArus); 

      // Perbarui rangkaian pengingat untuk tenor berikutnya
      await _scheduleNextReminder(updatedDebt);

      await loadActiveDebts(); 
      emit(const DebtOperationSuccess(message: 'Pembayaran berhasil dicatat!'));
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
      
      // Batalkan semua sisa pengingat 7 hari
      await _notificationService.cancelNotificationSequence(debtId.hashCode);

      await loadActiveDebts();
      emit(const DebtOperationSuccess(message: 'Hutang telah ditandai sebagai lunas.')); 
    } catch (e) {
      if (lastState is DebtLoadSuccess) emit(DebtLoadSuccess(debts: lastState.debts));
      emit(DebtOperationFailure("Gagal menyelesaikan hutang: ${e.toString()}"));
    }
  }
}