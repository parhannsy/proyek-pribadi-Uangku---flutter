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

  String _getDueDateStatus(DateTime nextDueDate) {
    final now = DateTime.now();
    final difference = nextDueDate.difference(now);
    final days = difference.inDays;

    if (days == 0) return 'Hari ini';
    if (days < 0) return 'Terlambat ${days.abs()} hari';
    
    return '$days hari';
  }

  @override
  Widget build(BuildContext context) {
    final debtCubit = context.read<DebtCubit>(); 
    
    final DateTime nextDueDate = debt.nextDueDate;
    final String dueDateText = _getDueDateStatus(nextDueDate);
    
    final int remainingTenor = debt.remainingTenor;
    final int paidTenor = debt.totalTenor - remainingTenor;
    
    final bool isDueToday = nextDueDate.day == DateTime.now().day && 
                            nextDueDate.month == DateTime.now().month && 
                            nextDueDate.year == DateTime.now().year;
    
    final bool isOverdue = nextDueDate.isBefore(DateTime.now().copyWith(hour: 0, minute: 0, second: 0));

    // LOGIKA WARNA BADGE - DIKEMBALIKAN & DIPERBAIKI
    Color effectiveBadgeColor;
    Color effectiveTextColor;
    String finalLabel;

    if (debt.isCompleted) {
      effectiveBadgeColor = AppColors.positiveGreen.withOpacity(0.15);
      effectiveTextColor = AppColors.positiveGreen;
      finalLabel = 'LUNAS';
    } else if (isOverdue) {
      effectiveBadgeColor = AppColors.negativeRed; 
      effectiveTextColor = Colors.white;
      finalLabel = isDueToday ? 'Hari Ini' : dueDateText;
    } else if (isDueToday) {
      effectiveBadgeColor = AppColors.accentGold; 
      effectiveTextColor = Colors.black;
      finalLabel = 'Hari Ini';
    } else {
      // Status Normal: Menggunakan warna yang kontras dengan surface
      effectiveBadgeColor = AppColors.accentGold.withOpacity(0.1); 
      effectiveTextColor = AppColors.accentGold;
      finalLabel = 'Jatuh tempo $dueDateText';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Kolom Kiri: Info Utama
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

              // Kolom Kanan: Status & Tenor
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge Jatuh Tempo / Lunas
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

                  // Info Tenor
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
            ],
          ),
        ),
      ),
    );
  }
}