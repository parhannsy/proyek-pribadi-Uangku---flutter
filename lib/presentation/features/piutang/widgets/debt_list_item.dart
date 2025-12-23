// lib/presentation/features/piutang/widgets/debt_list_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // <<< WAJIB: Import Bloc
import 'package:uangku/application/debt/debt_cubit.dart'; // <<< WAJIB: Import Cubit
import 'package:uangku/data/models/debt_model.dart'; 
import 'package:uangku/presentation/features/piutang/pages/debt_detail_page.dart'; // Pastikan path benar
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/utils/number_formatter.dart'; 

class DebtListItem extends StatelessWidget {
  final DebtModel debt;

  const DebtListItem({
    super.key,
    required this.debt,
  });

  // Helper untuk menghitung sisa hari hingga jatuh tempo
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
    // 1. Ambil instance Cubit yang sudah ada di scope atas
    // Lakukan ini di luar onTap
    final debtCubit = context.read<DebtCubit>(); // Ambil Cubit dari Provider Scope Induk
    
    // 2. Data dari Model
    final DateTime nextDueDate = debt.nextDueDate;
    final String dueDateText = _getDueDateStatus(nextDueDate);
    
    final int remainingTenor = debt.remainingTenor;
    final int paidTenor = debt.totalTenor - remainingTenor;
    
    // ... [Logika Status Jatuh Tempo lainnya tetap sama] ...
    final bool isDueToday = nextDueDate.day == DateTime.now().day && 
                            nextDueDate.month == DateTime.now().month && 
                            nextDueDate.year == DateTime.now().year;
    
    final bool isOverdue = nextDueDate.isBefore(DateTime.now().copyWith(hour: 0, minute: 0, second: 0));
    final bool isNearDue = dueDateText.contains('5 hari'); // Contoh kriteria

    Color effectiveBadgeColor;
    if (isOverdue) {
      effectiveBadgeColor = AppColors.negativeRed; 
    } else if (isDueToday) {
      effectiveBadgeColor = AppColors.accentGold; 
    } else if (isNearDue) {
      effectiveBadgeColor = AppColors.accentGold; 
    } else {
      effectiveBadgeColor = AppColors.positiveGreen; 
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () {
          // Navigasi ke DebtDetailPage dan SALURKAN Cubit yang sudah ada
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (routeContext) {
                // Bungkus DebtDetailPage dengan BlocProvider.value untuk 
                // menyalurkan Cubit yang sudah ada (debtCubit) ke rute baru.
                return BlocProvider.value(
                  value: debtCubit, // Menyediakan instance Cubit yang sama
                  child: DebtDetailPage(
                    debt: debt, 
                  ),
                );
              },
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
              // Kolom Kiri: Detail Hutang
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

              // Kolom Kanan: Status Jatuh Tempo dan Tenor
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge Jatuh Tempo
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: effectiveBadgeColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isOverdue 
                          ? dueDateText 
                          : isDueToday
                              ? 'Jatuh tempo hari ini'
                              : 'Jatuh tempo dalam $dueDateText',
                      style: const TextStyle(
                        color: AppColors.primaryBackground,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),

                  // Tenor/Angsuran
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