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
    
    // ----------------------------------------------------------
    // MENTOR FIX: Gunakan Getter dari Model (Single Source of Truth)
    // ----------------------------------------------------------
    
    // Ambil tanggal jatuh tempo tenor aktif langsung dari model yang sudah diperbaiki
    final DateTime currentTenorDate = debt.nextDueDate;
    final int currentDiff = currentTenorDate.difference(today).inDays;
    
    // Ambil daftar tunggakan langsung dari model
    final List<int> allOverdueIndices = debt.overdueTenorIndices;

    // Logika hasPastMonthDebt: Cek apakah ada tunggakan yang jatuh temponya 
    // sebelum awal bulan ini.
    final bool hasPastMonthDebt = allOverdueIndices.any((index) {
      // Kita panggil fungsi privat melalui getter atau kalkulasi ulang sederhana 
      // yang merujuk pada logika yang sama dengan model.
      int year = debt.dateBorrowed.year;
      int month = debt.dateBorrowed.month + index;
      while (month > 12) { month -= 12; year += 1; }
      int lastDay = DateTime(year, month + 1, 0).day;
      DateTime d = DateTime(year, month, debt.dueDateDay > lastDay ? lastDay : debt.dueDateDay);
      
      return d.isBefore(DateTime(today.year, today.month, 1));
    });

    // ----------------------------------------------------------
    // UI CONFIGURATION (Badges & Labels)
    // ----------------------------------------------------------
    String? upcomingLabel;
    Color upcomingBadgeColor = AppColors.accentGold.withOpacity(0.15);
    Color upcomingTextColor = AppColors.accentGold;

    if (!debt.isCompleted) {
      if (currentDiff < 0) {
        // Terlambat di bulan berjalan
        upcomingLabel = currentDiff.abs() > 7 ? 'Nunggak' : 'Telat ${currentDiff.abs()} hari';
        upcomingBadgeColor = AppColors.negativeRed.withOpacity(0.15);
        upcomingTextColor = AppColors.negativeRed;
      } else if (currentDiff == 0) {
        upcomingLabel = 'Hari Ini';
        upcomingBadgeColor = AppColors.accentGold;
        upcomingTextColor = Colors.black;
      } else if (currentDiff > 0 && currentDiff <= 7) {
        upcomingLabel = '$currentDiff hari lagi';
      } else {
        // FIX: Menampilkan tgl bulan depan (Februari) jika tenor berikutnya masih jauh
        upcomingLabel = DateFormat('d MMM', 'id_ID').format(currentTenorDate);
        upcomingBadgeColor = Colors.white.withOpacity(0.05);
        upcomingTextColor = AppColors.textSecondary;
      }
    }

    final Color mainTextColor = (hasPastMonthDebt && !debt.isCompleted) 
        ? AppColors.negativeRed 
        : AppColors.textPrimary;

    final int paidTenor = debt.totalTenor - debt.remainingTenor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: debtCubit, 
              child: DebtDetailPage(debt: debt)
            )
          )
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${debt.borrower} | ${debt.purpose}', 
                      style: TextStyle(color: mainTextColor, fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormatter.formatRupiah(debt.amountPerTenor), 
                      style: TextStyle(color: mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (debt.isCompleted)
                    _buildBadge('LUNAS', AppColors.positiveGreen.withOpacity(0.15), AppColors.positiveGreen)
                  else ...[
                    if (hasPastMonthDebt)
                      _buildBadge('Nunggak Lama', AppColors.negativeRed, Colors.white),
                    if (upcomingLabel != null && !hasPastMonthDebt)
                      _buildBadge(upcomingLabel, upcomingBadgeColor, upcomingTextColor),
                  ],
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$paidTenor/${debt.totalTenor}', 
                        style: TextStyle(
                          color: hasPastMonthDebt ? AppColors.negativeRed : AppColors.textSecondary, 
                          fontSize: 14, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
                    ],
                  ),

                  if (allOverdueIndices.isNotEmpty && !debt.isCompleted) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 4,
                      children: allOverdueIndices.map((t) => _buildTenorBox(t)).toList(),
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
      child: Text(
        label, 
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)
      ),
    );
  }

  Widget _buildTenorBox(int tenorIndex) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.negativeRed.withOpacity(0.1),
        border: Border.all(color: AppColors.negativeRed, width: 0.5),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        'T$tenorIndex', 
        style: const TextStyle(color: AppColors.negativeRed, fontSize: 8, fontWeight: FontWeight.bold)
      ),
    );
  }
}