import 'package:uangku/data/models/needs_model.dart';

abstract class NeedsRepository {
  /// Mengambil semua kategori anggaran beserta kalkulasi pengeluaran terpakai 
  /// yang difilter berdasarkan [month] dan [year] tertentu.
  /// Jika tidak diisi, maka akan mengambil data keseluruhan (Default).
  Future<List<NeedsModel>> getAllNeeds({int? month, int? year});

  Future<List<Map<String, dynamic>>> getMonthlySummary();
  
  Future<void> addNeed(NeedsModel need);
  Future<void> updateNeed(NeedsModel need);
  Future<void> deleteNeed(String id);
}