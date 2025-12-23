// lib/data/impl/sqflite/needs_repository_impl.dart

import 'package:sqflite/sqflite.dart';
import 'package:uangku/data/models/needs_model.dart';
import 'package:uangku/data/repositories/needs_repository.dart';
import 'package:uangku/data/services/database_service.dart';

class NeedsRepositoryImpl implements NeedsRepository {
  final DatabaseService _dbService;
  static const String tableName = 'needs';
  static const String tableArus = 'arus'; // Pastikan nama tabel transaksi benar

  NeedsRepositoryImpl(this._dbService);

  @override
  Future<List<NeedsModel>> getAllNeeds() async {
    final db = await _dbService.database;

    /// MENTOR NOTE: Teknik "Subquery" atau "Left Join" untuk menghitung usedAmount.
    /// Ini memastikan angka yang muncul di grafik 100% akurat sesuai riwayat transaksi.
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        n.*, 
        COALESCE(SUM(a.amount), 0) as used_amount
      FROM $tableName n
      LEFT JOIN $tableArus a ON n.id = a.need_id
      GROUP BY n.id
    ''');
    
    return maps.map((map) => NeedsModel.fromMap(map)).toList();
  }

  @override
  Future<void> addNeed(NeedsModel need) async {
    final db = await _dbService.database;
    await db.insert(
      tableName,
      need.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateNeed(NeedsModel need) async {
    final db = await _dbService.database;
    await db.update(
      tableName,
      need.toMap(),
      where: 'id = ?',
      whereArgs: [need.id],
    );
  }

  @override
  Future<void> deleteNeed(String id) async {
    final db = await _dbService.database;
    // MENTOR NOTE: Di dunia profesional, sebelum menghapus kategori, 
    // kita harus memutuskan apakah transaksi terkait ikut dihapus atau di-null-kan.
    // Di sini kita asumsikan set null pada transaksi terkait (jika didukung schema).
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}