// lib/presentation/features/dashboard/widgets/balance_summary_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangku/application/debt/debt_state.dart';
import 'package:uangku/application/flow/arus_cubit.dart';
import 'package:uangku/application/debt/debt_cubit.dart';
import 'package:uangku/application/needs/needs_cubit.dart';
import 'package:uangku/application/needs/needs_state.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/utils/number_formatter.dart';

class BalanceSummaryCard extends StatelessWidget {
  const BalanceSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan context.watch agar widget rebuild otomatis saat ada perubahan state
    final arusState = context.watch<ArusCubit>().state;
    final debtState = context.watch<DebtCubit>().state;
    final needsState = context.watch<NeedsCubit>().state;

    // 1. UANG TERSEDIA (Saldo Riil saat ini)
    final double uangTersedia = arusState.totalIncome - arusState.totalExpense;

    // 2. UANG DIBUTUHKAN (Sisa Anggaran Needs + Cicilan Hutang Bulan Ini/Terlambat)
    
    // --- Logika Needs Dinamis ---
    double sisaKebutuhanBulanIni = 0;
    if (needsState is NeedsLoadSuccess) {
      sisaKebutuhanBulanIni = needsState.needs.fold(0, (sum, item) {
        // Hanya hitung sisa budget yang belum terpakai
        return sum + (item.remainingAmount > 0 ? item.remainingAmount : 0);
      });
    }

    // --- Logika Debt Dinamis (FIXED) ---
    double cicilanHutangDibutuhkan = 0;
    if (debtState is DebtLoadSuccess) {
      final now = DateTime.now();

      cicilanHutangDibutuhkan = debtState.debts.where((debt) {
        if (debt.isCompleted) return false;

        // MENTOR LOGIC: 
        // Ambil jatuh tempo bulan ini. 
        // Jika sudah lewat (overdue) atau jatuh tempo hari ini/nanti di bulan ini, 
        // maka uangnya masih "dibutuhkan".
        final dueDate = debt.currentMonthDueDate;
        
        // Kita anggap uang dibutuhkan jika:
        // 1. Belum lunas
        // 2. Jatuh temponya ada di bulan berjalan (baik yang sudah lewat maupun belum)
        return dueDate.month == now.month && dueDate.year == now.year;
        
      }).fold(0, (sum, debt) => sum + debt.amountPerTenor);
    }

    final double uangDibutuhkan = sisaKebutuhanBulanIni + cicilanHutangDibutuhkan;

    // 3. STATUS KEUANGAN
    final double statusKeuangan = uangTersedia - uangDibutuhkan;
    final bool isSurplus = statusKeuangan >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Uang tersedia saat ini',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormatter.formatRupiah(uangTersedia.toInt()),
            style: const TextStyle(
              color: AppColors.accentGold,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Status keuangan', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        "${isSurplus ? '+' : ''}${NumberFormatter.formatRupiah(statusKeuangan.toInt())}",
                        style: TextStyle(
                          color: isSurplus ? AppColors.positiveGreen : AppColors.negativeRed,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 30, width: 1, color: Colors.white10),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Uang dibutuhkan', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormatter.formatRupiah(uangDibutuhkan.toInt()),
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
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