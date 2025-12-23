// lib/presentation/features/piutang/pages/piutang_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangku/application/debt/debt_cubit.dart'; 
import 'package:uangku/application/debt/debt_state.dart'; 
import 'package:uangku/data/models/debt_model.dart'; 
import 'package:uangku/presentation/features/piutang/widgets/debt_list_item.dart';
import 'package:uangku/presentation/features/piutang/widgets/debt_summary_card.dart';
import 'package:uangku/presentation/features/piutang/widgets/add_debt_form_modal.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/presentation/shared/widgets/animated_slider.dart';

class PiutangPage extends StatefulWidget {
  const PiutangPage({super.key}); 

  @override
  State<PiutangPage> createState() => _PiutangPageState();
}

class _PiutangPageState extends State<PiutangPage> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<DebtCubit>().loadActiveDebts();
      }
    });
  }

  void _showAddDebtModal(BuildContext context) {
    final debtCubit = context.read<DebtCubit>(); 
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: AppColors.primaryBackground, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: debtCubit,
        child: const AddDebtFormModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: BlocConsumer<DebtCubit, DebtState>(
        listener: (context, state) {
          if (state is DebtOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.positiveGreen),
            );
            context.read<DebtCubit>().loadActiveDebts();
          } else if (state is DebtOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          List<DebtModel> debts = [];
          if (state is DebtLoadSuccess) {
            debts = state.debts;
          }

          return CustomScrollView( 
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 8.0),
                sliver: SliverToBoxAdapter(child: _buildPageHeader(context)),
              ),
              
              if (state is DebtLoading && debts.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
                )
              else if (debts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false, // Menghindari overflow di dalam fill remaining
                  child: _buildEmptyStateContent(context),
                )
              else
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    ..._buildAnimatedItems(context, debts),
                  ]),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AnimatedSlider(
            index: 0,
            child: Text('Piutang', style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          AnimatedSlider(
            index: 0,
            child: IconButton(
              onPressed: () => context.read<DebtCubit>().loadActiveDebts(), 
              icon: const Icon(Icons.refresh, color: AppColors.accentGold, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnimatedItems(BuildContext context, List<DebtModel> debts) {
    final totalDebt = debts.fold<double>(0, (sum, debt) => sum + (debt.totalTenor * debt.amountPerTenor));
    final remainingAmount = debts.fold<double>(0, (sum, debt) => sum + (debt.remainingTenor * debt.amountPerTenor));
    final paidAmount = totalDebt - remainingAmount;
    
    final List<Widget> items = [
      DebtSummaryCard(
        totalDebt: totalDebt.toInt(), 
        paidAmount: paidAmount.toInt(), 
        remainingDebt: remainingAmount.toInt(), 
      ),
      const SizedBox(height: 24),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text('Daftar hutang anda', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 12),
      ...debts.map((debt) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: DebtListItem(debt: debt),
      )).toList(),
      const SizedBox(height: 12),
      Align(
        alignment: Alignment.center,
        child: InkWell(
          onTap: () => _showAddDebtModal(context),
          child: const Text('Catat hutang lainnya', style: TextStyle(color: AppColors.accentGold, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      ),
      const SizedBox(height: 40),
    ];
    
    return items.asMap().entries.map((e) => AnimatedSlider(index: e.key + 1, child: e.value)).toList();
  }

  // REVISI: Empty State dengan Staggered Animation
  Widget _buildEmptyStateContent(BuildContext context) {
    final List<Widget> emptyItems = [
      const Icon(Icons.account_balance_wallet_outlined, size: 80, color: AppColors.textSecondary),
      const SizedBox(height: 16),
      const Text(
        'Belum ada piutang aktif.', 
        style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)
      ),
      const SizedBox(height: 8),
      const Text(
        'Semua catatan hutang yang belum lunas\nakan muncul di sini.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: () => _showAddDebtModal(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Catat Hutang Baru', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    ];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: emptyItems.asMap().entries.map((e) {
          return AnimatedSlider(
            index: e.key + 1, // Berikan index agar muncul satu per satu
            child: e.value,
          );
        }).toList(),
      ),
    );
  }
}