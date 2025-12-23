// lib/data/impl/sqflite/debt_repository_impl.dart (REVISI FINAL)

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:uangku/data/models/debt_model.dart';
import 'package:uangku/data/repositories/debt_repository.dart';
import 'package:uangku/data/services/database_service.dart';

const Uuid _uuid = Uuid(); 

class DebtRepositoryImpl implements DebtRepository {
  final DatabaseService _dbService;
  final String _tableName = 'debts';

  DebtRepositoryImpl(this._dbService);

  // Helper: Konversi Map (dari DB) ke DebtModel
  DebtModel _fromMap(Map<String, dynamic> map) {
    return DebtModel.fromMap(map); 
  }

  // Helper: Konversi DebtModel ke Map (untuk disimpan ke DB)
  Map<String, dynamic> _toMap(DebtModel debt) {
    return debt.toMap(); 
  }
  
  // =========================================================================
  // IMPLEMENTASI KONTRAK DEBT REPOSITORY
  // =========================================================================

  @override
  Future<void> addDebt(DebtModel debt) async {
    final db = await _dbService.database;
    // Jika ID belum ada (misalnya dari form), tambahkan ID unik baru
    final DebtModel debtWithId = debt.id.isEmpty 
        ? debt.copyWith(id: _uuid.v4()) 
        : debt;

    await db.insert(
      _tableName,
      _toMap(debtWithId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // FUNGSI BARU/REVISI: Update data hutang yang sudah ada (Digunakan oleh payTenor)
  @override
  Future<void> updateDebt(DebtModel debt) async {
    final db = await _dbService.database;
    
    // Pastikan ID sudah ada untuk operasi update
    if (debt.id.isEmpty) {
      throw Exception('Debt ID tidak boleh kosong saat melakukan update.');
    }

    // Hanya update kolom yang relevan dari model (Sqflite akan menimpa)
    await db.update(
      _tableName,
      _toMap(debt), // Kirim seluruh DebtModel yang sudah dimodifikasi
      where: 'id = ?',
      whereArgs: [debt.id],
    );
  }

  @override
  Future<List<DebtModel>> getAllDebts() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'dateBorrowed DESC',
    );

    return List.generate(maps.length, (i) {
      return _fromMap(maps[i]);
    });
  }

  @override
  Future<List<DebtModel>> getActiveDebts() async {
    final db = await _dbService.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'isCompleted = ?',
      whereArgs: [0], // 0 = false (belum lunas)
      orderBy: 'dateBorrowed DESC', 
    );

    return List.generate(maps.length, (i) {
      return _fromMap(maps[i]);
    });
  }

  @override
  Future<void> completeDebt(String id) async {
    final db = await _dbService.database;
    
    await db.update(
      _tableName,
      // Ketika lunas, set isCompleted=1 dan remainingTenor=0
      {'isCompleted': 1, 'remainingTenor': 0}, 
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // CATATAN MENTOR: Implementasi recordTenorPayment dihapus 
  // karena telah diganti oleh updateDebt di kontrak DebtRepository.
  // Logika pengurangan remainingTenor dilakukan di DebtCubit.
}