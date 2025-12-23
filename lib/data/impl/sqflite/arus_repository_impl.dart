// lib/data/impl/sqflite/arus_repository_impl.dart

import 'package:sqflite/sqflite.dart';
import 'package:uangku/data/models/arus_model.dart';
import 'package:uangku/data/repositories/arus_repository.dart'; 
import 'package:uangku/data/services/database_service.dart';

class ArusRepositoryImpl implements ArusRepository {
  final DatabaseService _dbService;
  static const String tableName = 'arus';

  ArusRepositoryImpl(this._dbService);

  /// Query pembuatan tabel. 
  static String get createTableQuery => '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT NOT NULL,      
      category TEXT NOT NULL,
      amount REAL NOT NULL,
      description TEXT,
      timestamp INTEGER NOT NULL,  
      is_recurring INTEGER NOT NULL,
      debt_id TEXT, 
      image_path TEXT,
      need_id TEXT
    );
  ''';

  /// Helper untuk mendapatkan string periode 'MM-YYYY'.
  String _getPeriodString(int? month, int? year) {
    final now = DateTime.now();
    final m = (month ?? now.month).toString().padLeft(2, '0');
    final y = (year ?? now.year).toString();
    return "$m-$y";
  }

  @override
  Future<void> createArus(Arus arus) async {
    final db = await _dbService.database;
    await db.insert(
      tableName,
      arus.toSqfliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateArus(Arus arus) async {
    final db = await _dbService.database;
    if (arus.id == null) {
      throw Exception("ID Arus tidak boleh null saat update.");
    }
    await db.update(
      tableName,
      arus.toSqfliteMap(),
      where: 'id = ?',
      whereArgs: [arus.id],
    );
  }

  @override
  Future<void> deleteArus(int id) async {
    final db = await _dbService.database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================================================
  // LOGIKA PERIODIK (BERDASARKAN BULAN & TAHUN)
  // =========================================================

  @override
  Future<List<Arus>> getAllArus({int? month, int? year}) async {
    final db = await _dbService.database;
    final period = _getPeriodString(month, year);

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: "strftime('%m-%Y', timestamp / 1000, 'unixepoch') = ?",
      whereArgs: [period],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => Arus.fromSqfliteMap(map)).toList();
  }

  @override
  Future<double> getTotalIncome({int? month, int? year}) async {
    final db = await _dbService.database;
    final period = _getPeriodString(month, year);

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM $tableName 
      WHERE type = 'income' 
      AND strftime('%m-%Y', timestamp / 1000, 'unixepoch') = ?
    ''', [period]);

    return (result.first['total'] as num? ?? 0).toDouble();
  }

  @override
  Future<double> getTotalExpense({int? month, int? year}) async {
    final db = await _dbService.database;
    final period = _getPeriodString(month, year);

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM $tableName 
      WHERE type = 'expense' 
      AND strftime('%m-%Y', timestamp / 1000, 'unixepoch') = ?
    ''', [period]);

    return (result.first['total'] as num? ?? 0).toDouble();
  }

  // =========================================================
  // LOGIKA RANGE (UNTUK LAPORAN KHUSUS)
  // =========================================================

  @override
  Future<List<Arus>> getArusByDateRange(int startDate, int endDate) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => Arus.fromSqfliteMap(map)).toList();
  }

  @override
  Future<double> getTotalExpenseByDateRange(int startDate, int endDate) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM $tableName 
      WHERE type = 'expense' AND timestamp >= ? AND timestamp <= ?
    ''', [startDate, endDate]);

    return (result.first['total'] as num? ?? 0).toDouble();
  }

  @override
  Future<double> getTotalIncomeByDateRange(int startDate, int endDate) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM $tableName 
      WHERE type = 'income' AND timestamp >= ? AND timestamp <= ?
    ''', [startDate, endDate]);

    return (result.first['total'] as num? ?? 0).toDouble();
  }

  // =========================================================
  // MAINTENANCE & AUTO-CLEANUP
  // =========================================================

  @override
  Future<void> deleteOldTransactions(int monthsLimit) async {
    final db = await _dbService.database;
    try {
      // Menghapus data yang lebih lama dari X bulan dari sekarang
      await db.delete(
        tableName,
        where: "date(timestamp / 1000, 'unixepoch') < date('now', ?)",
        whereArgs: ['-$monthsLimit months'],
      );
    } catch (e) {
      // Log error tanpa menghentikan aliran aplikasi utama
      print("Maintenance Error (DeleteOld): $e");
    }
  }
}