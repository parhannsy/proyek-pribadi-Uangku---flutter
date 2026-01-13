import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangku/data/repositories/needs_repository.dart';
import 'package:uangku/presentation/features/kebutuhan/widgets/needs_monthly_summary_item.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/presentation/shared/widgets/animated_slider.dart';

class NeedsHistoryPage extends StatelessWidget {
  const NeedsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Riwayat Alokasi",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: null,
            icon: Icon(
              Icons.bar_chart_rounded,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: context.read<NeedsRepository>().getMonthlySummary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentGold),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final historyData = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            // MENTOR FIX: +2 karena ada Banner (index 0) dan Header (index 1)
            itemCount: historyData.length + 2,
            itemBuilder: (context, index) {
              // 1. BANNER INFORMASI
              if (index == 0) {
                return const AnimatedSlider(
                  index: 0,
                  child: _NeedsHistoryBanner(),
                );
              }

              // 2. HEADER JUDUL
              if (index == 1) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: AnimatedSlider(
                    index: 1,
                    child: Text(
                      "Riwayat Penggunaan Dana",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }

              // 3. LIST ITEM (Data asli dimulai dari index 2)
              final item = historyData[index - 2];
              return AnimatedSlider(
                index: index,
                child: NeedsMonthlySummaryItem(
                  period: _formatPeriod(item['period']),
                  totalSpent: (item['total_spent'] as num).toDouble(),
                  totalBudget: (item['total_budget_limit'] as num).toDouble(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatPeriod(String period) {
    try {
      final parts = period.split('-');
      final months = [
        "Januari", "Februari", "Maret", "April", "Mei", "Juni",
        "Juli", "Agustus", "September", "Oktober", "November", "Desember"
      ];
      final monthIndex = int.parse(parts[0]) - 1;
      return "${months[monthIndex]} ${parts[1]}";
    } catch (e) {
      return period;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded,
              size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text(
            "Belum ada riwayat penggunaan.",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// MENTOR COMPONENT: Banner Informasi (Reusable-style)
class _NeedsHistoryBanner extends StatelessWidget {
  const _NeedsHistoryBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.accentGold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Informasi Riwayat",
                  style: TextStyle(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Data di bawah menampilkan ringkasan penggunaan anggaran kebutuhan kamu hingga 6 bulan terakhir.",
                  style: TextStyle(
                    color: AppColors.textPrimary.withOpacity(0.7),
                    fontSize: 12,
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