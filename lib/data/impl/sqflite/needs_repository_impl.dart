import 'package:sqflite/sqflite.dart';
import 'package:uangku/data/models/needs_model.dart';
import 'package:uangku/data/repositories/needs_repository.dart';
import 'package:uangku/data/services/database_service.dart';

class NeedsRepositoryImpl implements NeedsRepository {
  final DatabaseService _dbService;
  static const String tableName = 'needs';
  static const String tableArus = 'arus';

  NeedsRepositoryImpl(this._dbService);

  /// Helper untuk menyeragamkan format periode dengan ArusRepositoryImpl
  String _getPeriodString(int? month, int? year) {
    final now = DateTime.now();
    final m = (month ?? now.month).toString().padLeft(2, '0');
    final y = (year ?? now.year).toString();
    return "$m-$y"; // Format MM-YYYY sesuai ArusRepositoryImpl
  }

  @override
  Future<List<NeedsModel>> getAllNeeds({int? month, int? year}) async {
    final db = await _dbService.database;
    final period = _getPeriodString(month, year);

    /// MENTOR NOTE: Mengambil data kebutuhan beserta total terpakai di bulan terkait
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        n.*, 
        (
          SELECT COALESCE(SUM(amount), 0) 
          FROM $tableArus 
          WHERE need_id = n.id 
          AND strftime('%m-%Y', timestamp / 1000, 'unixepoch') = ?
        ) as used_amount
      FROM $tableName n
    ''', [period]);
    
    return maps.map((map) => NeedsModel.fromMap(map)).toList();
  }

  /// MENTOR ADDITION: Fungsi untuk Riwayat Per Bulan
  @override
  Future<List<Map<String, dynamic>>> getMonthlySummary() async {
    final db = await _dbService.database;
    
    // Query ini mengelompokkan pengeluaran berdasarkan bulan dan tahun (MM-YYYY)
    // Lalu mengambil total budget yang ada saat ini sebagai pembanding.
    return await db.rawQuery('''
      SELECT 
        strftime('%m-%Y', timestamp / 1000, 'unixepoch') as period,
        SUM(amount) as total_spent,
        (SELECT SUM(budget_limit) FROM $tableName) as total_budget_limit,
        MAX(timestamp) as latest_timestamp
      FROM $tableArus
      WHERE need_id IS NOT NULL
      GROUP BY period
      ORDER BY latest_timestamp DESC
    ''');
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
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}