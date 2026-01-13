import 'package:sqflite/sqflite.dart';
import 'package:uangku/data/models/needs_model.dart';
import 'package:uangku/data/repositories/needs_repository.dart';
import 'package:uangku/data/services/database_service.dart';

class NeedsRepositoryImpl implements NeedsRepository {
  final DatabaseService _dbService;
  static const String tableName = 'needs';
  static const String tableArus = 'arus';
  static const String tableSnapshot = 'need_snapshots';

  NeedsRepositoryImpl(this._dbService);

  String _getPeriodString(int? month, int? year) {
    final now = DateTime.now();
    final m = (month ?? now.month).toString().padLeft(2, '0');
    final y = (year ?? now.year).toString();
    return "$m-$y";
  }

  @override
  Future<List<NeedsModel>> getAllNeeds({int? month, int? year}) async {
    final db = await _dbService.database;
    final period = _getPeriodString(month, year);

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

  @override
  Future<void> syncSnapshot(int month, int year) async {
    final db = await _dbService.database;
    final period = _getPeriodString(month, year);

    final now = DateTime.now();
    final currentPeriod = _getPeriodString(now.month, now.year);
    
    // Cek apakah snapshot sudah ada
    final List<Map<String, dynamic>> existing = await db.query(
      tableSnapshot,
      where: 'period = ?',
      whereArgs: [period],
      limit: 1,
    );

    // MENTOR LOGIC: Buat snapshot jika belum ada, 
    // ATAU update jika ini adalah periode bulan berjalan agar datanya sinkron
    if (existing.isEmpty || period == currentPeriod) {
      final List<Map<String, dynamic>> currentNeeds = await db.query(tableName);
      if (currentNeeds.isEmpty) return;

      final batch = db.batch();
      for (var need in currentNeeds) {
        batch.insert(
          tableSnapshot,
          {
            'period': period,
            'need_id': need['id'],
            'category_name': need['category'],
            'budget_limit': need['budget_limit'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMonthlySummary() async {
    final db = await _dbService.database;

    // 1. BACKFILL LOGIC: Tetap dipertahankan untuk integritas data lama
    final List<Map<String, dynamic>> missingPeriods = await db.rawQuery('''
      SELECT DISTINCT strftime('%m-%Y', timestamp / 1000, 'unixepoch') as period
      FROM $tableArus
      WHERE need_id IS NOT NULL 
      AND period NOT IN (SELECT DISTINCT period FROM $tableSnapshot)
    ''');

    for (var row in missingPeriods) {
      final parts = row['period'].toString().split('-');
      await syncSnapshot(int.parse(parts[0]), int.parse(parts[1]));
    }

    // 2. QUERY DENGAN PENGURUTAN KRONOLOGIS
    // MENTOR NOTE: Kita memecah period menjadi Year dan Month di level SQL 
    // agar bisa diurutkan secara matematis (DESC).
    return await db.rawQuery('''
      SELECT 
        s.period,
        SUM(s.budget_limit) as total_budget_limit,
        (
          SELECT COALESCE(SUM(amount), 0)
          FROM $tableArus
          WHERE need_id IS NOT NULL 
          AND strftime('%m-%Y', timestamp / 1000, 'unixepoch') = s.period
        ) as total_spent,
        SUBSTR(s.period, 4, 4) as year_part,
        SUBSTR(s.period, 1, 2) as month_part
      FROM $tableSnapshot s
      GROUP BY s.period
      ORDER BY year_part DESC, month_part DESC
      LIMIT 6
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
    // Langsung update snapshot bulan berjalan
    final now = DateTime.now();
    await syncSnapshot(now.month, now.year);
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
    // Langsung update snapshot bulan berjalan
    final now = DateTime.now();
    await syncSnapshot(now.month, now.year);
  }

  @override
  Future<void> deleteNeed(String id) async {
    final db = await _dbService.database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    // Catatan: Di snapshot data tetap ada untuk menjaga histori
  }
}