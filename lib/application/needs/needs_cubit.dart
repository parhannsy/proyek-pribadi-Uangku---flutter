// lib/application/needs/needs_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangku/application/needs/needs_state.dart';
import 'package:uangku/data/models/needs_model.dart';
import 'package:uangku/data/repositories/needs_repository.dart';

class NeedsCubit extends Cubit<NeedsState> {
  final NeedsRepository _repository;

  NeedsCubit(this._repository) : super(NeedsInitial());

  // ===============================================
  // 1. READ: Memuat semua data kebutuhan
  // ===============================================
  Future<void> loadNeeds() async {
    try {
      emit(NeedsLoading());
      final needs = await _repository.getAllNeeds();
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
      
      final updatedNeeds = await _repository.getAllNeeds();
      
      emit(NeedsOperationSuccess(
        message: "Kategori ${need.category} berhasil disimpan!",
        needs: _listSort(updatedNeeds),
      ));
    } catch (e) {
      emit(NeedsLoadFailure(message: "Gagal menambah kategori: ${e.toString()}"));
    }
  }

  // ===============================================
  // 3. UPDATE: Memperbarui data kategori (BARU)
  // ===============================================
  Future<void> updateNeed(NeedsModel need) async {
    try {
      // MENTOR NOTE: Di level repository, pastikan query menggunakan ID untuk update
      await _repository.updateNeed(need);
      
      // Ambil data terbaru setelah update agar UI tetap sinkron
      final updatedNeeds = await _repository.getAllNeeds();
      
      emit(NeedsOperationSuccess(
        message: "Kategori ${need.category} berhasil diperbarui!",
        needs: _listSort(updatedNeeds),
      ));
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
      final updatedNeeds = await _repository.getAllNeeds();
      
      emit(NeedsOperationSuccess(
        message: "Kategori berhasil dihapus",
        needs: _listSort(updatedNeeds),
      ));
    } catch (e) {
      emit(NeedsLoadFailure(message: "Gagal menghapus kategori: ${e.toString()}"));
    }
  }

  // ===============================================
  // HELPER: Sorting (Private)
  // ===============================================
  List<NeedsModel> _listSort(List<NeedsModel> list) {
    // Sorting berdasarkan nama kategori agar UI tidak lompat-lompat
    return list..sort((a, b) => a.category.toLowerCase().compareTo(b.category.toLowerCase()));
  }
}