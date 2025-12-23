// lib/presentation/features/arus/pages/arus_keuangan_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uangku/application/flow/arus_cubit.dart';
import 'package:uangku/application/flow/arus_state.dart';
import 'package:uangku/application/debt/debt_cubit.dart';
import 'package:uangku/application/debt/debt_state.dart';

import 'package:uangku/data/models/enums/arus_type.dart' as flow_enum;
import 'package:uangku/data/models/arus_model.dart';
import 'package:uangku/presentation/features/arus/widgets/transaction_list_item.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/utils/number_formatter.dart';
import 'package:uangku/presentation/shared/widgets/animated_slider.dart';
import 'package:uangku/presentation/features/arus/widgets/add_arus_form_modal.dart';

typedef TransactionType = flow_enum.ArusType;

class ArusKeuanganPage extends StatefulWidget {
  const ArusKeuanganPage({super.key});

  @override
  State<ArusKeuanganPage> createState() => _ArusKeuanganPageState();
}

class _ArusKeuanganPageState extends State<ArusKeuanganPage> {
  late PageController _pageController;
  DateTime _selectedDate = DateTime.now();
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 6);
    
    Future.microtask(() {
      if (mounted) {
        _fetchData();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _fetchData() {
    context.read<ArusCubit>().initialize(
      month: _selectedDate.month,
      year: _selectedDate.year,
    );
  }

  void _onPageChanged(int pageIndex) {
    final diff = pageIndex - 6;
    setState(() {
      _selectedDate = DateTime(_today.year, _today.month + diff);
    });
    _fetchData();
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  bool get _isNextDisabled =>
      _selectedDate.year == _today.year && _selectedDate.month == _today.month;

  bool get _isPrevDisabled =>
      _selectedDate.isBefore(DateTime(_today.year, _today.month - 5));

  void _showAddTransactionModal(BuildContext context) {
    final arusCubit = context.read<ArusCubit>();
    final debtCubit = context.read<DebtCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.primaryBackground,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return MultiBlocProvider(
              providers: [
                BlocProvider.value(value: arusCubit),
                BlocProvider.value(value: debtCubit),
              ],
              child: PrimaryScrollController(
                controller: scrollController,
                child: const AddArusFormModal(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ArusCubit, ArusState>(
          listener: (context, state) {
            if (state.failureMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.failureMessage!),
                    backgroundColor: AppColors.negativeRed),
              );
            }
          },
        ),
        BlocListener<DebtCubit, DebtState>(
          listener: (context, state) {
            if (state is DebtOperationSuccess) {
              _fetchData();
            }
          },
        ),
      ],
      child: BlocBuilder<ArusCubit, ArusState>(
        builder: (context, state) {
          final totalIncome = state.totalIncome.toInt();
          final totalExpense = state.totalExpense.toInt();
          final balance = totalIncome - totalExpense;
          final statusKeuangan = balance >= 0 ? 'Surplus' : 'Defisit';
          final currentActiveTab = state.currentActiveTab;

          return Scaffold(
            backgroundColor: AppColors.primaryBackground,
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddTransactionModal(context),
              backgroundColor: currentActiveTab == TransactionType.income
                  ? AppColors.positiveGreen
                  : AppColors.negativeRed,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // --- HEADER STATIC SECTION ---
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AnimatedSlider(
                          index: 0,
                          child: Text(
                            'Arus keuangan',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Navigation Periode
                        AnimatedSlider(
                          index: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.chevron_left,
                                    color: _isPrevDisabled
                                        ? AppColors.textSecondary.withOpacity(0.3)
                                        : AppColors.textPrimary),
                                onPressed: _isPrevDisabled
                                    ? null
                                    : () => _pageController.previousPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut),
                              ),
                              Text(
                                _formatDate(_selectedDate),
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: Icon(Icons.chevron_right,
                                    color: _isNextDisabled
                                        ? AppColors.textSecondary.withOpacity(0.3)
                                        : AppColors.textPrimary),
                                onPressed: _isNextDisabled
                                    ? null
                                    : () => _pageController.nextPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Summary Card & Balance Status
                        AnimatedSlider(
                          index: 2,
                          child: _buildSummaryCard(totalIncome, totalExpense),
                        ),
                        AnimatedSlider(
                          index: 3,
                          child: _buildBalanceStatus(statusKeuangan, balance),
                        ),
                        const SizedBox(height: 20),
                        
                        // Tab Toggle
                        AnimatedSlider(
                          index: 4,
                          child: _buildTabToggle(context, currentActiveTab),
                        ),
                      ],
                    ),
                  ),

                  // --- SCROLLABLE CONTENT WITH PAGEVIEW ---
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: 7, 
                      itemBuilder: (context, index) {
                        final List<Arus> currentList = state.aruses
                            .where((a) => a.type == state.currentActiveTab)
                            .toList();

                        return RefreshIndicator(
                          onRefresh: () async => _fetchData(),
                          color: AppColors.accentGold,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                // MENTOR NOTE: Header tabel di dalam PageView juga diberi animasi
                                const AnimatedSlider(
                                  index: 5,
                                  child: _buildTableHeader(),
                                ),
                                _buildTransactionContent(
                                    currentList, state, currentActiveTab),
                                SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildSummaryCard(int totalIncome, int totalExpense) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildSummaryColumn('Pemasukan', totalIncome, AppColors.positiveGreen),
          Container(height: 40, width: 1, color: AppColors.textSecondary.withOpacity(0.3)),
          _buildSummaryColumn('Pengeluaran', totalExpense, AppColors.negativeRed),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Text(
            NumberFormatter.formatRupiah(value),
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceStatus(String status, int balance) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Saldo Bersih', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
          Text(
            '$status: ${NumberFormatter.formatRupiah(balance.abs())}',
            style: TextStyle(
              color: balance >= 0 ? AppColors.positiveGreen : AppColors.negativeRed,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabToggle(BuildContext context, TransactionType currentActiveTab) {
    return Row(
      children: [
        Expanded(
          child: _buildTabButton(
            context,
            label: 'Pemasukan',
            type: TransactionType.income,
            isActive: currentActiveTab == TransactionType.income,
          ),
        ),
        Expanded(
          child: _buildTabButton(
            context,
            label: 'Pengeluaran',
            type: TransactionType.expense,
            isActive: currentActiveTab == TransactionType.expense,
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(BuildContext context,
      {required String label, required TransactionType type, required bool isActive}) {
    final Color activeColor =
        type == TransactionType.income ? AppColors.positiveGreen : AppColors.negativeRed;
    return InkWell(
      onTap: () => context.read<ArusCubit>().toggleTab(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: isActive ? activeColor : Colors.transparent, width: 3),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionContent(
      List<Arus> currentList, ArusState state, TransactionType currentActiveTab) {
    if (state.isLoading) {
      return const Center(
          child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    }

    if (currentList.isEmpty) {
      return AnimatedSlider(
        index: 6,
        child: const Padding(
          padding: EdgeInsets.all(40.0),
          child: Center(
              child: Text('Tidak ada transaksi.',
                  style: TextStyle(color: AppColors.textSecondary))),
        ),
      );
    }

    return Column(
      children: List.generate(currentList.length, (index) {
        return AnimatedSlider(
          index: index + 6, // Melanjutkan urutan animasi dari header
          child: TransactionListItem(
            transaction: currentList[index],
            isIncome: currentActiveTab == TransactionType.income,
          ),
        );
      }),
    );
  }
}

class _buildTableHeader extends StatelessWidget {
  const _buildTableHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text('Tanggal',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold))),
          Expanded(
              flex: 4,
              child: Text('Keperluan',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold))),
          Expanded(
              flex: 3,
              child: Text('Nominal',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}