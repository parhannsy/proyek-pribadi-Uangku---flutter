import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangku/application/debt/debt_cubit.dart'; 
import 'package:uangku/application/debt/debt_state.dart'; 
import 'package:uangku/application/flow/arus_cubit.dart'; 
import 'package:uangku/data/models/arus_model.dart';
import 'package:uangku/data/models/debt_model.dart'; 
import 'package:uangku/data/repositories/arus_repository.dart';
import 'package:uangku/presentation/features/piutang/widgets/add_payment_form_modal.dart';
import 'package:uangku/presentation/features/piutang/pages/payment_receipt_page.dart'; 
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/presentation/shared/widgets/animated_slider.dart';
import 'package:uangku/utils/number_formatter.dart';
import 'package:intl/intl.dart'; 
import 'package:collection/collection.dart'; 

class DebtDetailPage extends StatelessWidget {
  final DebtModel debt; 

  const DebtDetailPage({
    super.key,
    required this.debt,
  });

  // ==========================================================
  // LOGIKA NAVIGASI & PENCARIAN DATA
  // ==========================================================
  
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

  /// MENTOR FIX: Fungsi navigasi yang cerdas dengan pengecekan database langsung.
  Future<void> _navigateToReceipt(BuildContext context, DebtModel debt, int tenorNumber) async {
    // 1. Cek di Memory (ArusCubit State)
    final arusesInState = context.read<ArusCubit>().state.aruses;
    Arus? transaction = arusesInState.firstWhereOrNull((a) => _isMatch(a, debt.id, tenorNumber));

    // 2. Jika tidak ada di State (kemungkinan beda bulan), tarik dari Database
    if (transaction == null) {
      try {
        final arusRepo = context.read<ArusRepository>();
        final allRelatedArus = await arusRepo.getArusByDebtId(debt.id);
        transaction = allRelatedArus.firstWhereOrNull((a) => _isMatch(a, debt.id, tenorNumber));
      } catch (e) {
        debugPrint("Error fetching deep data: $e");
      }
    }

    // 3. Eksekusi Navigasi
    if (transaction != null) {
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentReceiptPage(
            transaction: transaction!,
            tenorNumber: tenorNumber,
          ),
        ),
      );
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bukti pembayaran tidak ditemukan di database. Pastikan data tersimpan dengan benar.'),
          backgroundColor: AppColors.negativeRed,
        ),
      );
    }
  }

  /// Helper untuk validasi kecocokan tenor dalam deskripsi Arus
  bool _isMatch(Arus a, String debtId, int tenorNumber) {
    if (a.debtId != debtId) return false;
    final description = a.description ?? '';
    
    // Pola modern [T:1,2,3]
    final match = RegExp(r'\[T:(.*?)\]').firstMatch(description);
    if (match != null) {
      final listTenor = match.group(1)!.split(',').map((e) => e.trim());
      return listTenor.contains(tenorNumber.toString());
    }
    
    // Pola legacy
    return description.contains('Bulan: $tenorNumber');
  }

  DateTime? _getCompletionDate(BuildContext context, String debtId) {
    final aruses = context.read<ArusCubit>().state.aruses;
    final lastTransaction = aruses
        .where((a) => a.debtId == debtId)
        .sortedBy((a) => a.timestamp)
        .lastOrNull;
    
    return lastTransaction?.timestamp;
  }

  // ==========================================================
  // UI BUILDER
  // ==========================================================

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
        final completionDate = currentDebt.isCompleted 
            ? _getCompletionDate(context, currentDebt.id) 
            : null;
        
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
                  child: _buildSummaryCard(currentDebt, totalDebtAmount, dateFormat, completionDate),
                ),
                
                const SizedBox(height: 24),

                if (!currentDebt.isCompleted) ...[
                  AnimatedSlider(
                    index: 1,
                    child: _buildInfoBanner(),
                  ),
                  const SizedBox(height: 24),
                ],
                
                AnimatedSlider(
                  index: 2,
                  child: Text(
                    currentDebt.isCompleted ? 'Riwayat Pembayaran Tenor' : 'Tenor Berjalan',
                    style: const TextStyle(
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
                    return AnimatedSlider(
                      index: index + 3,
                      child: _buildPaymentItem(
                        context: context,
                        currentDebt: currentDebt,
                        tenorNumber: tenorNumber,
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

  Widget _buildSummaryCard(DebtModel debt, int totalAmount, DateFormat dateFormat, DateTime? completionDate) {
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
          _buildDetailRow('Tanggal Pinjam', dateFormat.format(debt.dateBorrowed)),
          _buildDetailRow('Total Pinjaman', NumberFormatter.formatRupiah(totalAmount)),
          _buildDetailRow('Cicilan / Bulan', NumberFormatter.formatRupiah(debt.amountPerTenor)),
          
          if (debt.isCompleted)
            _buildDetailRow(
              'Rampung Pada', 
              completionDate != null ? dateFormat.format(completionDate) : '-',
              valueColor: AppColors.positiveGreen,
            )
          else
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
    required DateFormat dateFormat,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final dueDate = DateTime(
      currentDebt.dateBorrowed.year, 
      currentDebt.dateBorrowed.month + tenorNumber, 
      currentDebt.dueDateDay
    );

    final isPaid = tenorNumber <= (currentDebt.totalTenor - currentDebt.remainingTenor);
    final isOverdue = !isPaid && today.isAfter(dueDate);
    final isNextToPay = !isPaid && tenorNumber == (currentDebt.totalTenor - currentDebt.remainingTenor + 1);

    Color statusColor;
    IconData statusIcon;
    String statusLabel;
    String statusDate;
    Color borderColor = Colors.white.withOpacity(0.02);

    if (isPaid) {
      statusColor = AppColors.positiveGreen;
      statusIcon = Icons.check_circle;
      statusLabel = 'Sudah Dibayar';
      statusDate = ''; 
    } else if (isOverdue) {
      statusColor = AppColors.negativeRed;
      statusIcon = Icons.warning_rounded;
      statusLabel = 'Terlambat';
      statusDate = 'Jatuh tempo: ${dateFormat.format(dueDate)}';
      borderColor = AppColors.negativeRed.withOpacity(0.3);
    } else if (isNextToPay) {
      statusColor = AppColors.accentGold;
      statusIcon = Icons.pending_actions_rounded;
      statusLabel = 'Saatnya Bayar';
      statusDate = 'Batas: ${dateFormat.format(dueDate)}';
      borderColor = AppColors.accentGold.withOpacity(0.5);
    } else {
      statusColor = AppColors.textSecondary;
      statusIcon = Icons.schedule;
      statusLabel = 'Mendatang';
      statusDate = 'Est. ${dateFormat.format(dueDate)}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, size: 20, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tenor Ke-$tenorNumber', 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 2),
                Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                if (statusDate.isNotEmpty)
                  Text(
                    statusDate,
                    style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 11),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8), 
          ElevatedButton(
            onPressed: isPaid 
                ? () => _navigateToReceipt(context, currentDebt, tenorNumber)
                : (isNextToPay && !currentDebt.isCompleted) 
                    ? () => _showPaymentModal(context, tenorNumber, currentDebt) 
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPaid ? statusColor.withOpacity(0.15) : statusColor,
              disabledBackgroundColor: Colors.white.withOpacity(0.05),
              foregroundColor: isPaid ? statusColor : AppColors.primaryBackground,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(80, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isPaid ? 'Bukti' : 'Bayar',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.accentGold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
                children: [
                  TextSpan(text: "Untuk pembayaran lebih dari 1 tenor secara bersamaan, silakan lakukan di halaman "),
                  TextSpan(
                    text: "Arus > Tambah Pengeluaran > Kategori Tagihan.",
                    style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
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