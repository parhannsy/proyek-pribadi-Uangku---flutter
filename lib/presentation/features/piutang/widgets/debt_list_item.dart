// lib/presentation/features/piutang/widgets/debt_list_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; 
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
    
    // 1. Cari Tenor Terdekat di Masa Depan/Berjalan (Untuk Monitoring Radius)
    DateTime? currentTenorDate;
    int? currentDiff;
    
    for (int i = 1; i <= debt.totalTenor; i++) {
      DateTime checkDate = DateTime(debt.dateBorrowed.year, debt.dateBorrowed.month + i, debt.dueDateDay);
      if (checkDate.isAfter(today.subtract(const Duration(days: 1)))) {
        currentTenorDate = checkDate;
        currentDiff = checkDate.difference(today).inDays;
        break; 
      }
    }

    // 2. Cek Apakah Ada Tenor yang Menunggak dari Bulan Lalu (Nunggak Lama)
    final List<int> allOverdueIndices = debt.overdueTenorIndices;
    final bool hasPastMonthDebt = allOverdueIndices.any((index) {
      DateTime d = DateTime(debt.dateBorrowed.year, debt.dateBorrowed.month + index, debt.dueDateDay);
      return d.isBefore(DateTime(today.year, today.month, 1));
    });

    // 3. Tentukan Label untuk Tenor Aktif/Mendatang
    String? upcomingLabel;
    Color upcomingBadgeColor = AppColors.accentGold.withOpacity(0.15);
    Color upcomingTextColor = AppColors.accentGold;

    if (!debt.isCompleted && currentTenorDate != null && currentDiff != null) {
      if (currentDiff < 0) {
        // --- LOGIKA BARU: TELAT DI BULAN BERJALAN ---
        if (currentDiff.abs() > 7) {
          upcomingLabel = 'Nunggak'; // Label Nunggak untuk telat > 7 hari di bulan ini
          upcomingBadgeColor = AppColors.negativeRed.withOpacity(0.15);
          upcomingTextColor = AppColors.negativeRed;
        } else {
          upcomingLabel = 'Telat ${currentDiff.abs()} hari';
          upcomingBadgeColor = AppColors.negativeRed.withOpacity(0.15);
          upcomingTextColor = AppColors.negativeRed;
        }
      } else if (currentDiff == 0) {
        upcomingLabel = 'Hari Ini';
        upcomingBadgeColor = AppColors.accentGold;
        upcomingTextColor = Colors.black;
      } else if (currentDiff > 0 && currentDiff <= 7) {
        upcomingLabel = '$currentDiff hari lagi';
        upcomingBadgeColor = AppColors.accentGold.withOpacity(0.15);
        upcomingTextColor = AppColors.accentGold;
      } else if (currentDiff > 7 && !hasPastMonthDebt) {
        // Hanya tampil tanggal jika bersih dari tunggakan lama
        upcomingLabel = DateFormat('d MMM', 'id_ID').format(currentTenorDate);
        upcomingBadgeColor = Colors.white.withOpacity(0.05);
        upcomingTextColor = AppColors.textSecondary;
      }
    }

    // 4. Warna Teks Utama
    final Color mainTextColor = (hasPastMonthDebt && !debt.isCompleted) 
        ? AppColors.negativeRed 
        : AppColors.textPrimary;

    // Box kecil T1, T2... (Untuk semua yang telat > 7 hari)
    final List<int> displayOverdueBoxes = allOverdueIndices.where((index) {
      DateTime d = DateTime(debt.dateBorrowed.year, debt.dateBorrowed.month + index, debt.dueDateDay);
      return today.difference(d).inDays > 7;
    }).toList();

    final int paidTenor = debt.totalTenor - debt.remainingTenor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => BlocProvider.value(value: debtCubit, child: DebtDetailPage(debt: debt)))
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${debt.borrower} | ${debt.purpose}', 
                      style: TextStyle(color: mainTextColor, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(NumberFormatter.formatRupiah(debt.amountPerTenor), 
                      style: TextStyle(color: mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 4,
                    children: [
                      if (hasPastMonthDebt && !debt.isCompleted)
                        _buildBadge('Nunggak Lama', AppColors.negativeRed, Colors.white),
                      
                      if (upcomingLabel != null && !debt.isCompleted)
                        _buildBadge(upcomingLabel, upcomingBadgeColor, upcomingTextColor),
                      
                      if (debt.isCompleted)
                        _buildBadge('LUNAS', AppColors.positiveGreen.withOpacity(0.15), AppColors.positiveGreen),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$paidTenor/${debt.totalTenor}', 
                        style: TextStyle(color: hasPastMonthDebt ? AppColors.negativeRed : AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
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
                        child: Text('T$t', style: const TextStyle(color: AppColors.negativeRed, fontSize: 8, fontWeight: FontWeight.bold)),
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

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}