// lib/presentation/features/dashboard/widgets/arus_keuangan_chart.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';

class ArusKeuanganChart extends StatelessWidget {
  const ArusKeuanganChart({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -------------------------------------------------------------
        // HEADER (Diluar Box Dekorasi)
        // -------------------------------------------------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Arus keuangan',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Grafik perbandingan terhadap pemasukan',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),

        // Period Selector (Sekarang sudah StatefulWidget)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: _PeriodSelector(),
        ),
        
        const SizedBox(height: 12),

        // -------------------------------------------------------------
        // BODY (Didalam Box Dekorasi: GRAFIK)
        // -------------------------------------------------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            width: double.infinity,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chart Placeholder
                SizedBox(
                  height: 180,
                  child: Center( // Mengganti Container dengan SizedBox/Center yang lebih efisien
                    child: Text(
                      'Placeholder Grafik Garis (fl_chart)',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
                // Padding 8 di bawah grafik
                SizedBox(height: 8), 
              ],
            ),
          ),
        ),
        
        // -------------------------------------------------------------
        // FOOTER (Diluar Box Dekorasi: LINK DETAIL)
        // -------------------------------------------------------------
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                // 
              },
              child: Text(
                'Lihat detail Arus →',
                style: TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24), 
      ],
    );
  }
}

// =========================================================================
// PERUBAHAN UTAMA: _PeriodSelector diubah menjadi StatefulWidget
// =========================================================================

class _PeriodSelector extends StatefulWidget {
  const _PeriodSelector();

  @override
  State<_PeriodSelector> createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<_PeriodSelector> {
  // Variabel untuk menyimpan status tombol yang terpilih. Defaultnya 'Bulan ini'.
  String _selectedPeriod = 'Bulan ini'; 
  
  final List<String> periods = const ['Semua', 'Hari ini', 'Minggu ini', 'Bulan ini'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Periode: Bulan desember',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: periods.map((period) {
              final bool isSelected = period == _selectedPeriod; // Cek status
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell( // Menggunakan InkWell agar bisa diklik
                  onTap: () {
                    // Memicu perubahan status
                    setState(() {
                      _selectedPeriod = period;
                      // 
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accentGold : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.accentGold : AppColors.textSecondary.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      period,
                      style: TextStyle(
                        color: isSelected ? AppColors.primaryBackground : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}