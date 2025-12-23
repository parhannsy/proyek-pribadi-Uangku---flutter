// lib/data/repositories/debt_repository.dart

import 'package:uangku/data/models/debt_model.dart';

/// Kontrak (Interface) untuk semua operasi terkait data Piutang/Hutang.
/// Implementasi konkret (misalnya: Sqflite, Firebase) akan mengikuti kontrak ini.
abstract class DebtRepository {
  
  /// Mengambil semua catatan hutang/piutang yang aktif (belum lunas).
  ///

  Future<List<DebtModel>> getActiveDebts();

  /// Mengambil semua catatan hutang/piutang, termasuk yang sudah lunas.
  ///
  Future<List<DebtModel>> getAllDebts();

  /// Menyimpan catatan hutang/piutang baru ke penyimpanan data.
  ///
  /// @param debt DebtModel yang akan ditambahkan.
  Future<void> addDebt(DebtModel debt);

  /// Mengupdate data hutang/piutang yang sudah ada di penyimpanan data.
  ///
  /// Fungsi ini digunakan untuk mencatat perubahan pada DebtModel, seperti 
  /// pengurangan remainingTenor atau perubahan data detail lainnya.
  /// @param debt DebtModel yang sudah dimodifikasi (memiliki ID yang sama).
  Future<void> updateDebt(DebtModel debt);

  /// Menandai hutang/piutang sebagai lunas sepenuhnya.
  ///
  /// @param debtId ID unik dari hutang yang akan dilunasi.
  Future<void> completeDebt(String debtId);
}