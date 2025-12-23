// lib/presentation/features/piutang/widgets/debt_summary_card.dart (REVISI FINAL)

import 'package:flutter/material.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/utils/number_formatter.dart'; // Import Helper

class DebtSummaryCard extends StatelessWidget {
  // PERUBAHAN UTAMA: Gunakan INT untuk perhitungan yang akurat
  final int totalDebt;
  final int paidAmount;
  
  // remainingDebt bisa dihitung dari totalDebt - paidAmount,
  // namun kita biarkan dihitung dari luar jika memang ada logic sisa utang yang lebih kompleks.
  final int remainingDebt; 

  const DebtSummaryCard({
    super.key,
    required this.totalDebt,
    required this.paidAmount,
    required this.remainingDebt,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Perhitungan Dinamis (Mengatasi Masalah Persentase)
    double paidPercentage = 0.0;
    if (totalDebt > 0) {
      // Pastikan pembagian dilakukan pada tipe double
      paidPercentage = paidAmount / totalDebt; 
    }
    // Batasi persentase maksimal 1.0 (100%)
    paidPercentage = paidPercentage.clamp(0.0, 1.0); 

    // 2. Format Nominal untuk Tampilan UI
    final String formattedTotalDebt = NumberFormatter.formatRupiah(totalDebt);
    final String formattedPaidAmount = NumberFormatter.formatRupiah(paidAmount);
    final String formattedRemainingDebt = NumberFormatter.formatRupiah(remainingDebt);


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Total Hutang
          Text(
            'Perjalanan total hutang anda',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            formattedTotalDebt, // Total Hutang
            style: const TextStyle(
              color: AppColors.accentGold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Progress Bar (Paid Amount) - Sekarang bersih tanpa teks di dalamnya
          Stack(
            children: [
              // Latar belakang bar (sisa hutang)
              Container(
                height: 10, // Dikecilkan agar lebih minimalis
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              
              // Bar pembayaran (dinamis)
              LayoutBuilder(
                builder: (context, constraints) {
                  final double paidWidth = constraints.maxWidth * paidPercentage;
                  
                  return Container(
                    width: paidWidth, // MENGGUNAKAN LEBAR HASIL PERHITUNGAN
                    height: 10, // Dikecilkan agar lebih minimalis
                    decoration: BoxDecoration(
                      color: AppColors.accentGold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 8),

          // Detail Pembayaran (Dibayar dan Sisa) - Poin Perubahan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Kolom Kiri: Jumlah Dibayar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sudah Dibayar',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedPaidAmount, // Pindah ke sini
                    style: const TextStyle(
                      color: AppColors.positiveGreen, 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
              
              // Kolom Kanan: Sisa Hutang
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Sisa Belum Dibayar',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedRemainingDebt, 
                    style: const TextStyle(
                      color: AppColors.negativeRed, 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}