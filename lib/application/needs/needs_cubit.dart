import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangku/application/needs/needs_state.dart';
import 'package:uangku/data/models/needs_model.dart';
import 'package:uangku/data/repositories/needs_repository.dart';

class NeedsCubit extends Cubit<NeedsState> {
  final NeedsRepository _repository;

  NeedsCubit(this._repository) : super(NeedsInitial());

  // ===============================================
  // 1. READ: Memuat data kebutuhan (BULAN BERJALAN)
  // ===============================================
  Future<void> loadNeeds() async {
    try {
      emit(NeedsLoading());
      
      // MENTOR FIX: Ambil periode bulan dan tahun sekarang
      final now = DateTime.now();
      
      // Kirim parameter waktu ke repository agar filter dilakukan di level Database
      final needs = await _repository.getAllNeeds(
        month: now.month,
        year: now.year,
      );
      
      emit(NeedsLoadSuccess(needs: _listSort(needs)));
    } catch (e) {
      emit(NeedsLoadFailure(message: "Gagal memuat data: ${e.toString()}"));
    }
  }

  // ===============================================
  // 2. CREATE: Menambah kategori anggaran baru
  // ===============================================
  Future<void> addNeed(NeedsModel need) async {
    try {
      await _repository.addNeed(need);
      
      // Refresh data dengan filter bulan sekarang
      await loadNeeds();
      
      final currentState = state;
      if (currentState is NeedsLoadSuccess) {
        emit(NeedsOperationSuccess(
          message: "Kategori ${need.category} berhasil disimpan!",
          needs: currentState.needs,
        ));
      }
    } catch (e) {
      emit(NeedsLoadFailure(message: "Gagal menambah kategori: ${e.toString()}"));
    }
  }

  // ===============================================
  // 3. UPDATE: Memperbarui data kategori
  // ===============================================
  Future<void> updateNeed(NeedsModel need) async {
    try {
      await _repository.updateNeed(need);
      
      await loadNeeds();
      
      final currentState = state;
      if (currentState is NeedsLoadSuccess) {
        emit(NeedsOperationSuccess(
          message: "Kategori ${need.category} berhasil diperbarui!",
          needs: currentState.needs,
        ));
      }
    } catch (e) {
      emit(NeedsLoadFailure(message: "Gagal memperbarui kategori: ${e.toString()}"));
    }
  }

  // ===============================================
  // 4. DELETE: Menghapus kategori kebutuhan
  // ===============================================
  Future<void> deleteNeed(String id) async {
    try {
      await _repository.deleteNeed(id);
      
      await loadNeeds();
      
      final currentState = state;
      if (currentState is NeedsLoadSuccess) {
        emit(NeedsOperationSuccess(
          message: "Kategori berhasil dihapus",
          needs: currentState.needs,
        ));
      }
    } catch (e) {
      emit(NeedsLoadFailure(message: "Gagal menghapus kategori: ${e.toString()}"));
    }
  }

  // ===============================================
  // HELPER: Sorting (Private)
  // ===============================================
  List<NeedsModel> _listSort(List<NeedsModel> list) {
    return list..sort((a, b) => a.category.toLowerCase().compareTo(b.category.toLowerCase()));
  }
}