// lib/presentation/features/dashboard/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangku/application/debt/debt_cubit.dart';
import 'package:uangku/application/flow/arus_cubit.dart';
import 'package:uangku/presentation/features/dashboard/widgets/balance_summary_card.dart';
import 'package:uangku/presentation/features/dashboard/widgets/arus_keuangan_chart.dart';
import 'package:uangku/presentation/features/dashboard/widgets/recent_transaction_list.dart';
import 'package:uangku/presentation/features/dashboard/widgets/piutang_list.dart';
import 'package:uangku/presentation/shared/widgets/animated_slider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // MENTOR NOTE: Dashboard adalah agregator. 
    // Pastikan semua data dipicu untuk dimuat ulang saat dashboard diinisialisasi.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAllData();
    });
  }

  void _refreshAllData() {
    context.read<ArusCubit>().initialize();
    context.read<DebtCubit>().loadActiveDebts();
  }

  @override
  Widget build(BuildContext context) {
    // MENTOR REVISION: Hanya list widget konten, SizedBox dipisah agar animasi efisien.
    final List<Widget> dashboardContent = [
      const BalanceSummaryCard(),
      const ArusKeuanganChart(),
      const RecentTransactionsList(),
      const PiutangList(),
    ];

    return RefreshIndicator(
      onRefresh: () async => _refreshAllData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Memungkinkan pull-to-refresh walau konten sedikit
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gunakan spread operator dengan filter index
            ...List.generate(dashboardContent.length, (index) {
              return Column(
                children: [
                  AnimatedSlider(
                    index: index,
                    child: dashboardContent[index],
                  ),
                  // MENTOR LOGIC: Tambahkan jarak secara otomatis kecuali di item terakhir
                  if (index != dashboardContent.length - 1) 
                    const SizedBox(height: 24),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}