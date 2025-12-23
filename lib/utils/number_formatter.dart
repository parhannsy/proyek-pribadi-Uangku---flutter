// lib/utils/number_formatter.dart

import 'package:intl/intl.dart';
// WAJIB: Tambahkan package 'intl' ke pubspec.yaml

class NumberFormatter {
  NumberFormatter(int totalAmount);

  // Menghilangkan konstruktor yang tidak diperlukan. Semua method akan static.

  /// Mengubah angka menjadi format Rupiah (Contoh: 1500000 -> Rp 1.500.000)
  static String formatRupiah(int amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }
  
  /// Mengubah angka menjadi format ribuan (Contoh: 1500000 -> 1.500.000)
  static String formatThousand(int amount) {
    final formatter = NumberFormat('#,##0', 'id');
    return formatter.format(amount);
  }
  
  /// Mengubah angka besar menjadi format jutaan (Contoh: 15000000 -> 15 jt)
  static String formatMillion(int amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} M';
    } else if (amount >= 1000000) {
      // Menggunakan format .toStringAsFixed(1) untuk memastikan ada satu angka desimal jika diperlukan
      String formatted = (amount / 1000000).toStringAsFixed(1);
      // Menghilangkan .0 jika angka genap (misalnya 12.0 menjadi 12)
      return '${formatted.replaceAll(RegExp(r'\.0$'), '')} jt';
    }
    // Jika kurang dari 1 Juta, kembalikan format ribuan
    return formatThousand(amount);
  }
}