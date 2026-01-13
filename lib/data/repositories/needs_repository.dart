import 'package:uangku/data/models/needs_model.dart';

abstract class NeedsRepository {
  /// Mengambil semua kategori anggaran aktif beserta pengeluaran terpakai 
  /// yang difilter berdasarkan [month] dan [year].
  Future<List<NeedsModel>> getAllNeeds({int? month, int? year});

  /// Mengambil ringkasan riwayat bulanan dari tabel snapshot.
  Future<List<Map<String, dynamic>>> getMonthlySummary();

  /// Menyalin data kategori aktif ke dalam tabel snapshot untuk periode tertentu.
  /// Dipanggil setiap kali load data atau perubahan budget di bulan berjalan.
  Future<void> syncSnapshot(int month, int year);
  
  Future<void> addNeed(NeedsModel need);
  Future<void> updateNeed(NeedsModel need);
  Future<void> deleteNeed(String id);
}