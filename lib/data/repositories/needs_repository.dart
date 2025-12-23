// lib/data/repositories/needs_repository.dart

import 'package:uangku/data/models/needs_model.dart';

abstract class NeedsRepository {
  /// Mengambil semua kategori anggaran beserta kalkulasi pengeluaran terpakai secara real-time
  Future<List<NeedsModel>> getAllNeeds();
  
  Future<void> addNeed(NeedsModel need);
  Future<void> updateNeed(NeedsModel need);
  Future<void> deleteNeed(String id);
}