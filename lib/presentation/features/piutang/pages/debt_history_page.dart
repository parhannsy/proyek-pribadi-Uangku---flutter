// lib/presentation/features/piutang/pages/debt_history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangku/application/debt/debt_cubit.dart';
import 'package:uangku/application/debt/debt_state.dart';
import 'package:uangku/presentation/features/piutang/widgets/debt_list_item.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/presentation/shared/widgets/animated_slider.dart';

class DebtHistoryPage extends StatelessWidget {
  const DebtHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Riwayat Piutang',
          style: TextStyle(
            color: AppColors.textPrimary, 
            fontSize: 18, 
            fontWeight: FontWeight.bold
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<DebtCubit, DebtState>(
        builder: (context, state) {
          if (state is DebtLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accentGold));
          }

          if (state is DebtLoadSuccess) {
            final completedDebts = state.debts.where((d) => d.isCompleted).toList();

            if (completedDebts.isEmpty) {
              return _buildEmptyHistory();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // INFO HEADER: Menjelaskan fungsi halaman
                AnimatedSlider(
                  index: 0,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentGold.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.accentGold, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Total Lunas: ${completedDebts.length} Catatan',
                              style: const TextStyle(
                                color: AppColors.accentGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Halaman ini menampilkan daftar seluruh hutang yang telah Anda selesaikan pembayarannya secara penuh.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Daftar Transaksi Selesai',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: completedDebts.length,
                    itemBuilder: (context, index) {
                      // MENTOR NOTE: Gunakan index + 1 agar slider tidak bebarengan dengan header
                      return AnimatedSlider(
                        index: index + 1,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: DebtListItem(debt: completedDebts[index]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          if (state is DebtOperationFailure) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }

          return _buildEmptyHistory();
        },
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AnimatedSlider(
            index: 0,
            child: Icon(Icons.history_toggle_off_rounded, size: 80, color: AppColors.accentGold),
          ),
          const SizedBox(height: 16),
          const AnimatedSlider(
            index: 1,
            child: Text(
              'Belum ada riwayat lunas',
              style: TextStyle(color: AppColors.accentGold, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          const AnimatedSlider(
            index: 2,
            child: Text(
              'Semua catatan hutang yang telah selesai\nakan diarsipkan di halaman ini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}