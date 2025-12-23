// lib/data/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uangku/data/impl/sqflite/arus_repository_impl.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  
  // MENTOR NOTE: Konsisten di Versi 6
  static const int _version = 6; 
  static const String _dbName = 'uangku_data.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, 
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE debts (
        id TEXT PRIMARY KEY,
        borrower TEXT NOT NULL,
        purpose TEXT NOT NULL,
        dateBorrowed INTEGER NOT NULL,
        dueDateDay INTEGER NOT NULL,
        totalTenor INTEGER NOT NULL,
        remainingTenor INTEGER NOT NULL,
        amountPerTenor REAL NOT NULL,
        isCompleted INTEGER NOT NULL 
      );
    ''');
    
    await db.execute('''
      CREATE TABLE needs (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        budget_limit INTEGER NOT NULL,
        color_value INTEGER NOT NULL
      );
    ''');

    await db.execute(ArusRepositoryImpl.createTableQuery);
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 6) {
      // MENTOR NOTE: Cara aman migrasi adalah mengecek kolom sebelum menambahkannya
      var tableInfo = await db.rawQuery('PRAGMA table_info(arus)');
      bool hasNeedId = tableInfo.any((column) => column['name'] == 'need_id');

      if (!hasNeedId) {
        await db.execute("ALTER TABLE arus ADD COLUMN need_id TEXT");
      }

      // Recreate tabel needs untuk memastikan struktur budgeting terbaru
      await db.execute("DROP TABLE IF EXISTS needs");
      await db.execute('''
        CREATE TABLE needs (
          id TEXT PRIMARY KEY,
          category TEXT NOT NULL,
          budget_limit INTEGER NOT NULL,
          color_value INTEGER NOT NULL
        );
      ''');
      print("Database Migrated to V6: Column check and table recreation success");
    }
  }
}