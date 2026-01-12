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

  // MENTOR REVISION: Ganti getActiveDebts menjadi getAllDebts
  // Agar state mengandung SEMUA data (aktif & lunas) untuk kebutuhan filtering di UI.
  Future<void> loadActiveDebts() async {
  try {
    emit(DebtLoading());
    final debts = await _repository.getAllDebts();
    
    // MENTOR TIP: Sortir agar yang hampir jatuh tempo atau terlambat ada di atas
    debts.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      return a.dueDateDay.compareTo(b.dueDateDay);
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
      final updatedList = await _repository.getAllDebts(); // AMBIL SEMUA
      emit(DebtLoadSuccess(debts: updatedList));
      emit(const DebtOperationSuccess(message: 'Data hutang berhasil ditambahkan.')); 
    } catch (e) {
      if (lastState is DebtLoadSuccess) {
        emit(DebtLoadSuccess(debts: lastState.debts));
      }
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
      // Ambil data terbaru dari database
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

      // Eksekusi Simpan
      await _repository.updateDebt(updatedDebt);
      await _arusRepository.createArus(newArus); 

      // MENTOR REVISION: Refresh dengan getAllDebts agar data lunas tetap masuk ke state
      final updatedList = await _repository.getAllDebts();
      
      emit(DebtLoadSuccess(debts: updatedList));
      emit(const DebtOperationSuccess(message: 'Pembayaran tenor berhasil dicatat!'));
      
    } catch (e) {
      if (lastState is DebtLoadSuccess) {
        emit(DebtLoadSuccess(debts: lastState.debts));
      }
      emit(DebtOperationFailure("Gagal memproses pembayaran: ${e.toString()}"));
    }
  }

  Future<void> completeDebt(String debtId) async {
    final lastState = state;
    try {
      emit(DebtOperationInProgress());
      await _repository.completeDebt(debtId); 
      
      // MENTOR REVISION: Selalu gunakan getAllDebts
      final updatedList = await _repository.getAllDebts();
      emit(DebtLoadSuccess(debts: updatedList));
      emit(const DebtOperationSuccess(message: 'Hutang telah ditandai sebagai lunas.')); 
    } catch (e) {
      if (lastState is DebtLoadSuccess) {
        emit(DebtLoadSuccess(debts: lastState.debts));
      }
      emit(DebtOperationFailure("Gagal menyelesaikan hutang: ${e.toString()}"));
    }
  }
}