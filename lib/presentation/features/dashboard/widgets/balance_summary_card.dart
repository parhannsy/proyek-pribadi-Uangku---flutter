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
    final arusState = context.watch<ArusCubit>().state;
    final debtState = context.watch<DebtCubit>().state;
    final needsState = context.watch<NeedsCubit>().state;

    final now = DateTime.now();

    // 1. UANG TERSEDIA (Saldo Riil saat ini)
    final double uangTersedia = arusState.totalIncome - arusState.totalExpense;

    // 2. UANG DIBUTUHKAN (Sisa Anggaran Needs + Cicilan Hutang Bulan Ini)
    
    // --- Logika Needs Dinamis ---
    double sisaKebutuhanBulanIni = 0;
    if (needsState is NeedsLoadSuccess) {
      // MENTOR LOGIC: Gunakan remainingAmount (Budget - Used) 
      // Jika used sudah melebihi budget, kita anggap 0 (tidak butuh uang lagi karena sudah habis/over)
      sisaKebutuhanBulanIni = needsState.needs.fold(0, (sum, item) {
        return sum + (item.remainingAmount > 0 ? item.remainingAmount : 0);
      });
    }

    // --- Logika Debt Dinamis (Hanya Bulan Ini) ---
    double cicilanHutangBulanIni = 0;
    if (debtState is DebtLoadSuccess) {
      cicilanHutangBulanIni = debtState.debts.where((debt) {
        // MENTOR LOGIC: 
        // 1. Hutang belum lunas
        // 2. Jatuh temponya adalah bulan ini (cek berdasarkan dueDateDay dan current month)
        bool isNotCompleted = !debt.isCompleted;
        bool isDueThisMonth = debt.nextDueDate.month == now.month && 
                             debt.nextDueDate.year == now.year;
        
        return isNotCompleted && isDueThisMonth;
      }).fold(0, (sum, debt) => sum + debt.amountPerTenor);
    }

    final double uangDibutuhkan = sisaKebutuhanBulanIni + cicilanHutangBulanIni;

    // 3. STATUS KEUANGAN
    final double statusKeuangan = uangTersedia - uangDibutuhkan;
    final bool isSurplus = statusKeuangan >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
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