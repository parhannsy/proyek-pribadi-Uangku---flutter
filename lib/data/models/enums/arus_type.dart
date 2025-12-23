// lib/data/models/enums/arus_type.dart

import 'package:flutter/material.dart';

enum ArusType {
 // Pemasukan
 income,
 
 // Pengeluaran
 expense,
}

// Extension untuk memudahkan konversi dan tampilan
extension ArusTypeExtension on ArusType {
 
 /// Mengkonversi Enum menjadi String yang mudah dibaca (misalnya untuk UI).
 String get name {
  switch (this) {
   case ArusType.income:
    return 'Pemasukan';
   case ArusType.expense:
    return 'Pengeluaran';
  }
 }

 /// Mendapatkan representasi nilai String mentah (sering digunakan untuk Database).
 // Perhatikan: ini adalah built-in `.name` di Dart versi terbaru, tapi extension ini aman.
 String get value {
  switch (this) {
   case ArusType.income:
    return 'income';
   case ArusType.expense:
    return 'expense';
  }
 }

 /// Mendapatkan warna representatif (misalnya untuk chart atau ikon).
 Color get color {
  switch (this) {
   case ArusType.income:
    // Ganti dengan warna hijau yang Anda tentukan
    return Colors.green; 
   case ArusType.expense:
    // Ganti dengan warna merah yang Anda tentukan
    return Colors.red; 
  }
 }
}

/// Fungsi helper untuk mengkonversi String dari database kembali ke Enum.
ArusType getArusTypeFromString(String? type) {
 if (type == 'income') {
  return ArusType.income;
 }
 // Defaultkan ke expense jika string tidak dikenali atau null
 return ArusType.expense;
}