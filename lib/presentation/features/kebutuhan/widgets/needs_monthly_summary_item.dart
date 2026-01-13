import 'package:flutter/material.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/utils/number_formatter.dart';

class NeedsMonthlySummaryItem extends StatelessWidget {
  final String period;
  final double totalSpent;
  final double totalBudget;

  const NeedsMonthlySummaryItem({
    super.key,
    required this.period,
    required this.totalSpent,
    required this.totalBudget,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = totalBudget > 0 ? (totalSpent / totalBudget) : 0;
    bool isOver = percentage > 1.0;
    // MENTOR LOGIC: Boros jika >= 90% tapi belum melewati 100%
    bool isWasteful = percentage >= 0.9 && percentage <= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Kolom kiri: Nama Bulan + Dynamic Badge
              Expanded(
                child: Row(
                  children: [
                    Text(
                      period,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // MENTOR FIX: Prioritas Badge
                    if (isOver)
                      _buildBadge("OVER", AppColors.negativeRed)
                    else if (isWasteful)
                      _buildBadge("BOROS", Colors.orangeAccent),
                  ],
                ),
              ),
              // Kolom kanan: Persentase
              Text(
                "${(percentage * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  color: isOver 
                      ? AppColors.negativeRed 
                      : (isWasteful ? Colors.orangeAccent : AppColors.accentGold),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withOpacity(0.05),
            color: isOver 
                ? AppColors.negativeRed 
                : (isWasteful ? Colors.orangeAccent : AppColors.accentGold),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Terpakai: ${NumberFormatter.formatRupiah(totalSpent.toInt())}",
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                "Limit: ${NumberFormatter.formatRupiah(totalBudget.toInt())}",
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// MENTOR REFACTOR: Fungsi badge yang lebih fleksibel (Reusable)
  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}