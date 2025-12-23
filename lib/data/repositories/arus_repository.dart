// lib/data/repositories/arus_repository.dart

import 'package:uangku/data/models/arus_model.dart';

abstract class ArusRepository {
  // ==========================================================
  // Operasi CRUD Dasar
  // ==========================================================
  
  /// Menyimpan transaksi arus kas baru
  Future<void> createArus(Arus arus);

  /// Memperbarui data transaksi yang sudah ada
  Future<void> updateArus(Arus arus);

  /// Menghapus transaksi berdasarkan ID (AUTOINCREMENT)
  Future<void> deleteArus(int id);

  // ==========================================================
  // Operasi Dashboard (Fokus pada Periode Bulan/Tahun)
  // ==========================================================

  /// Mengambil semua data arus kas pada bulan dan tahun tertentu
  Future<List<Arus>> getAllArus({int? month, int? year});

  /// Menghitung total pemasukan pada periode tertentu
  Future<double> getTotalIncome({int? month, int? year});

  /// Menghitung total pengeluaran pada periode tertentu
  Future<double> getTotalExpense({int? month, int? year});

  // ==========================================================
  // Operasi Laporan & Analisa (Fokus pada Range Tanggal)
  // ==========================================================

  /// Mengambil data arus kas dalam rentang timestamp tertentu (milliseconds)
  Future<List<Arus>> getArusByDateRange(int startDate, int endDate);

  /// Menghitung total pengeluaran dalam rentang timestamp tertentu (milliseconds)
  Future<double> getTotalExpenseByDateRange(int startDate, int endDate);

  /// Menghitung total pemasukan dalam rentang timestamp tertentu (milliseconds)
  Future<double> getTotalIncomeByDateRange(int startDate, int endDate);

  // ==========================================================
  // Operasi Pemeliharaan (Maintenance)
  // ==========================================================

  /// MENTOR ADDITION: Menghapus otomatis data yang sudah terlampau lama (Data Retention)
  /// Digunakan untuk menjaga performa database agar tetap ringan.
  /// [monthsLimit] menentukan berapa bulan data akan dipertahankan.
  Future<void> deleteOldTransactions(int monthsLimit);
}