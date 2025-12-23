// lib/presentation/features/piutang/debt_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangku/application/debt/debt_cubit.dart'; 
import 'package:uangku/application/debt/debt_state.dart'; 
import 'package:uangku/application/flow/arus_cubit.dart'; // Tambahkan ini
import 'package:uangku/data/models/debt_model.dart'; 
import 'package:uangku/presentation/features/piutang/widgets/add_payment_form_modal.dart';
import 'package:uangku/presentation/features/piutang/pages/payment_receipt_page.dart'; // Tambahkan ini
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/presentation/shared/widgets/animated_slider.dart';
import 'package:uangku/utils/number_formatter.dart';
import 'package:intl/intl.dart'; 
import 'package:collection/collection.dart'; // Gunakan ini untuk firstWhereOrNull

class DebtDetailPage extends StatelessWidget {
  final DebtModel debt; 

  const DebtDetailPage({
    super.key,
    required this.debt,
  });
  
  void _showPaymentModal(BuildContext context, int tenorNumber, DebtModel currentDebt) {
    final debtCubit = context.read<DebtCubit>(); 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (BuildContext modalContext) { 
        return BlocProvider.value(
          value: debtCubit,
          child: AddPaymentFormModal(
            debt: currentDebt, 
            selectedTenors: [tenorNumber], 
          ),
        );
      },
    );
  }

  // Fungsi navigasi ke bukti bayar
  void _navigateToReceipt(BuildContext context, DebtModel debt, int tenorNumber) {
    final aruses = context.read<ArusCubit>().state.aruses;
    
    // Cari transaksi yang punya debtId ini DAN deskripsinya mengandung angka tenor tersebut
    final transaction = aruses.firstWhereOrNull(
      (a) => a.debtId == debt.id && a.description!.contains('Bulan: $tenorNumber')
    );

    if (transaction != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentReceiptPage(
            transaction: transaction,
            tenorNumber: tenorNumber,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bukti pembayaran tidak ditemukan di riwayat Arus.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID'); 
    
    return BlocBuilder<DebtCubit, DebtState>(
      builder: (context, state) {
        DebtModel currentDebt = debt;
        if (state is DebtLoadSuccess) {
          currentDebt = state.debts.firstWhere(
            (d) => d.id == debt.id,
            orElse: () => debt, 
          );
        }

        final totalDebtAmount = currentDebt.totalTenor * currentDebt.amountPerTenor;
        
        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Detail Hutang ${currentDebt.borrower}',
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSlider(
                  index: 0,
                  child: _buildSummaryCard(currentDebt, totalDebtAmount),
                ),
                
                const SizedBox(height: 24),
                
                const AnimatedSlider(
                  index: 1,
                  child: Text(
                    'Riwayat Cicilan',
                    style: TextStyle(
                      color: AppColors.textPrimary, 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentDebt.totalTenor,
                  itemBuilder: (context, index) {
                    final tenorNumber = index + 1;
                    final isPaid = tenorNumber <= (currentDebt.totalTenor - currentDebt.remainingTenor);
                    
                    return AnimatedSlider(
                      index: index + 2,
                      child: _buildPaymentItem(
                        context: context,
                        currentDebt: currentDebt,
                        tenorNumber: tenorNumber,
                        isPaid: isPaid,
                        dateFormat: dateFormat,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(DebtModel debt, int totalAmount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildDetailRow('Tujuan', debt.purpose),
          _buildDetailRow('Total Pinjaman', NumberFormatter.formatRupiah(totalAmount)),
          _buildDetailRow('Cicilan / Bulan', NumberFormatter.formatRupiah(debt.amountPerTenor)),
          _buildDetailRow('Sisa Tenor', '${debt.remainingTenor} bulan lagi'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Colors.white10, thickness: 1),
          ),
          _buildDetailRow(
            'Status', 
            debt.isCompleted ? 'LUNAS' : 'AKTIF', 
            valueColor: debt.isCompleted ? AppColors.positiveGreen : AppColors.accentGold
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem({
    required BuildContext context,
    required DebtModel currentDebt,
    required int tenorNumber,
    required bool isPaid,
    required DateFormat dateFormat,
  }) {
    final dueDate = DateTime(
      currentDebt.dateBorrowed.year, 
      currentDebt.dateBorrowed.month + tenorNumber, 
      currentDebt.dueDateDay
    );

    final bool isNextToPay = tenorNumber == (currentDebt.totalTenor - currentDebt.remainingTenor + 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: isNextToPay 
            ? Border.all(color: AppColors.accentGold.withOpacity(0.5), width: 1) 
            : Border.all(color: Colors.white.withOpacity(0.02), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPaid ? AppColors.positiveGreen.withOpacity(0.1) : AppColors.primaryBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid ? Icons.check_circle : Icons.schedule,
              size: 20,
              color: isPaid ? AppColors.positiveGreen : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tenor Ke-$tenorNumber', 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 2),
                Text(
                  isPaid ? 'Sudah Dibayar' : 'Jatuh Tempo: ${dateFormat.format(dueDate)}',
                  style: TextStyle(
                    color: isPaid ? AppColors.positiveGreen : AppColors.textSecondary, 
                    fontSize: 12
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isPaid 
                ? () => _navigateToReceipt(context, currentDebt, tenorNumber)
                : (isNextToPay && !currentDebt.isCompleted) 
                    ? () => _showPaymentModal(context, tenorNumber, currentDebt) 
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPaid ? AppColors.positiveGreen.withOpacity(0.15) : AppColors.accentGold,
              disabledBackgroundColor: Colors.white.withOpacity(0.05),
              foregroundColor: isPaid ? AppColors.positiveGreen : AppColors.primaryBackground,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isPaid ? 'Bukti Bayar' : 'Bayar',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Text(
            value, 
            style: TextStyle(
              color: valueColor ?? Colors.white, 
              fontWeight: FontWeight.bold,
              fontSize: 14
            )
          ),
        ],
      ),
    );
  }
}