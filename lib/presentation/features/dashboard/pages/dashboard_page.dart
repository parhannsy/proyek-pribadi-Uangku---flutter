// lib/presentation/features/dashboard/pages/dashboard_page.dart

import 'package:flutter/material.dart';
// Import widget yang sudah dipisah
import 'package:uangku/presentation/features/dashboard/widgets/balance_summary_card.dart';
import 'package:uangku/presentation/features/dashboard/widgets/arus_keuangan_chart.dart';
import 'package:uangku/presentation/features/dashboard/widgets/recent_transaction_list.dart';
import 'package:uangku/presentation/features/dashboard/widgets/piutang_list.dart';
import 'package:uangku/presentation/shared/widgets/animated_slider.dart'; // Import AnimatedSlider

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi list dari semua widget yang ingin dianimasikan
    final List<Widget> dashboardItems = [
      // 1. Kartu Ringkasan Saldo
      const BalanceSummaryCard(), 
      
      const SizedBox(height: 24), // Jarak dihitung sebagai satu item animasi

      // 2. Grafik Arus Keuangan Bulanan
      const ArusKeuanganChart(), 
      
      const SizedBox(height: 24),

      // 3. Daftar Transaksi Terbaru
      const RecentTransactionsList(), 
      
      const SizedBox(height: 24),

      // 4. Piutang (Angsuran Terdekat)
      const PiutangList(),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // ===================================
          // APLIKASI ANIMATED SLIDER PADA SEMUA ITEM
          // ===================================
          ...List.generate(dashboardItems.length, (index) {
            // Kita bungkus setiap item (termasuk SizedBox) dengan AnimatedSlider
            return AnimatedSlider(
              index: index,
              child: dashboardItems[index],
            );
          }),
          // ===================================
        ],
      ),
    );
  }
}