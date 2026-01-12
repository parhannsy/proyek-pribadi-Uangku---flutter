// lib/presentation/features/piutang/widgets/debt_list_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangku/application/debt/debt_cubit.dart'; 
import 'package:uangku/data/models/debt_model.dart'; 
import 'package:uangku/presentation/features/piutang/pages/debt_detail_page.dart'; 
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/utils/number_formatter.dart'; 

class DebtListItem extends StatelessWidget {
  final DebtModel debt;

  const DebtListItem({
    super.key,
    required this.debt,
  });

  @override
  Widget build(BuildContext context) {
    final debtCubit = context.read<DebtCubit>(); 
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = debt.currentMonthDueDate;
    final difference = dueDate.difference(today).inDays;

    final bool isDueToday = difference == 0;
    final bool isOverdue = difference < 0;
    
    // Logika Filter Kotak Merah: Muncul jika keterlambatan > 7 hari
    final List<int> allOverdue = debt.overdueTenorIndices;
    final List<int> displayOverdueBoxes = allOverdue.where((tenorIndex) {
      DateTime tenorDate = DateTime(debt.dateBorrowed.year, debt.dateBorrowed.month + tenorIndex, debt.dueDateDay);
      return today.difference(tenorDate).inDays > 7;
    }).toList();

    Color effectiveBadgeColor;
    Color effectiveTextColor;
    String finalLabel;

    if (debt.isCompleted) {
      effectiveBadgeColor = AppColors.positiveGreen.withOpacity(0.15);
      effectiveTextColor = AppColors.positiveGreen;
      finalLabel = 'LUNAS';
    } 
    // Status Terlambat (Hanya tampil di badge jika <= 7 hari)
    else if (isOverdue && difference.abs() <= 7) {
      effectiveBadgeColor = AppColors.negativeRed; 
      effectiveTextColor = Colors.white;
      finalLabel = 'Terlambat ${difference.abs()} hari';
    } 
    else if (isDueToday) {
      effectiveBadgeColor = AppColors.accentGold; 
      effectiveTextColor = Colors.black;
      finalLabel = 'Hari Ini';
    } else if (difference > 0 && difference <= 7) {
      effectiveBadgeColor = AppColors.accentGold.withOpacity(0.1); 
      effectiveTextColor = AppColors.accentGold;
      finalLabel = '$difference hari lagi';
    } else {
      effectiveBadgeColor = Colors.white.withOpacity(0.05); 
      effectiveTextColor = AppColors.textSecondary;
      finalLabel = 'Tgl ${debt.dueDateDay}'; 
    }

    final int paidTenor = debt.totalTenor - debt.remainingTenor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Kembali ke aslinya
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (routeContext) => BlocProvider.value(
                value: debtCubit,
                child: DebtDetailPage(debt: debt),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Kembali ke aslinya
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(8), // Kembali ke circular(8)
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${debt.borrower} | ${debt.purpose}', 
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormatter.formatRupiah(debt.amountPerTenor), 
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: effectiveBadgeColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          finalLabel,
                          style: TextStyle(
                            color: effectiveTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$paidTenor/${debt.totalTenor}', 
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                  if (displayOverdueBoxes.isNotEmpty && !debt.isCompleted) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 4,
                      children: displayOverdueBoxes.map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.negativeRed.withOpacity(0.1),
                          border: Border.all(color: AppColors.negativeRed, width: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          'T$t',
                          style: const TextStyle(
                            color: AppColors.negativeRed,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}