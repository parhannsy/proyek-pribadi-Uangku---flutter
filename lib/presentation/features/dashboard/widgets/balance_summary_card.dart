// lib/presentation/features/dashboard/widgets/balance_summary_card.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';

class BalanceSummaryCard extends StatelessWidget {
  const BalanceSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    // DATA DUMMY
    const String totalBalance = 'Rp 1.234.567';
    const String statusKeuangan = '-Rp 1.234.567';
    const String uangDibutuhkan = 'Rp 1.234.567';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        // Tetap start (rata kiri) agar judul "Uang tersedia saat ini" tetap rata kiri
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          // -------------------------------------------------------------
          // BAGIAN 1: SALDO UTAMA (Uang tersedia saat ini)
          // -------------------------------------------------------------
          
          Text(
            'Uang tersedia saat ini',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 4),

          Text(
            totalBalance,
            style: TextStyle(
              color: AppColors.accentGold,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 16), 

          // -------------------------------------------------------------
          // BAGIAN 2: DETAIL RINGKASAN (Status & Kebutuhan) - DI DALAM CONTAINER
          // -------------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Status Keuangan
                Expanded(
                  child: Column(
                    // PERUBAHAN: Mengubah CrossAxisAlignment.start menjadi CrossAxisAlignment.center
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Status keuangan',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        // PERUBAHAN: Menambahkan textAlign.center
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        statusKeuangan,
                        style: TextStyle(
                          color: AppColors.negativeRed,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        // PERUBAHAN: Menambahkan textAlign.center
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Divider Vertikal
                Container(
                  height: 40, 
                  width: 1, 
                  color: AppColors.textSecondary.withOpacity(0.3)
                ),
                
                const SizedBox(width: 8),
                
                // Uang Dibutuhkan
                Expanded(
                  child: Column(
                    // PERUBAHAN: Mengubah CrossAxisAlignment.start menjadi CrossAxisAlignment.center
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'uang dibutuhkan',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        // PERUBAHAN: Menambahkan textAlign.center
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        uangDibutuhkan,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        // PERUBAHAN: Menambahkan textAlign.center
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}