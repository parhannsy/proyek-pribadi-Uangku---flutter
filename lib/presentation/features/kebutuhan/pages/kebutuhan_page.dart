import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uangku/application/needs/needs_cubit.dart';
import 'package:uangku/application/needs/needs_state.dart';
import 'package:uangku/data/models/needs_model.dart';
import 'package:uangku/presentation/features/kebutuhan/widgets/needs_list_item.dart';
import 'package:uangku/presentation/features/kebutuhan/widgets/add_needs_modal.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/presentation/shared/widgets/animated_slider.dart';

import 'needs_history_page.dart';

class KebutuhanPage extends StatefulWidget {
  const KebutuhanPage({super.key});

  @override
  State<KebutuhanPage> createState() => _KebutuhanPageState();
}

class _KebutuhanPageState extends State<KebutuhanPage> {
  @override
  void initState() {
    super.initState();
    context.read<NeedsCubit>().loadNeeds();
  }

  void _showNeedsModal(BuildContext context, {NeedsModel? needs}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => AddNeedsModal(needs: needs),
    );
  }

  /// MENTOR NOTE: Fungsi untuk navigasi ke halaman riwayat.
  /// Pastikan kamu membuat halamannya nanti dan mengganti route-nya.
  void _navigateToHistory() {
  Navigator.push(
    context, 
    MaterialPageRoute(builder: (_) => const NeedsHistoryPage())
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: BlocListener<NeedsCubit, NeedsState>(
        listener: (context, state) {
          if (state is NeedsOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.positiveGreen,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          if (state is NeedsLoadFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<NeedsCubit, NeedsState>(
          builder: (context, state) {
            if (state is NeedsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accentGold),
              );
            }

            final List<NeedsModel> needsData = (state is NeedsLoadSuccess)
                ? state.needs
                : (state is NeedsOperationSuccess)
                    ? state.needs
                    : [];

            return RefreshIndicator(
              onRefresh: () => context.read<NeedsCubit>().loadNeeds(),
              color: AppColors.accentGold,
              backgroundColor: AppColors.surfaceColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. HEADER DENGAN TOMBOL RIWAYAT
                      AnimatedSlider(
                        index: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Alokasi Anggaran',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // MENTOR FIX: Menambahkan tombol riwayat di pojok kanan atas
                            IconButton(
                              onPressed: _navigateToHistory,
                              icon: const Icon(
                                Icons.history_rounded,
                                color: AppColors.accentGold,
                                size: 28,
                              ),
                              tooltip: 'Riwayat Penggunaan',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. GRAFIK / EMPTY STATE GRAFIK
                      if (needsData.isNotEmpty) ...[
                        AnimatedSlider(
                          index: 1,
                          child: AspectRatio(
                            aspectRatio: 1.5,
                            child: PieChart(
                              PieChartData(
                                sections: needsData.map((e) {
                                  final totalBudget = needsData.fold<double>(
                                      0, (sum, item) => sum + item.budgetLimit);
                                  final porsiPersen =
                                      (e.budgetLimit / totalBudget) * 100;

                                  return PieChartSectionData(
                                    color: e.color,
                                    value: e.budgetLimit.toDouble(),
                                    radius: 55,
                                    showTitle: false,
                                    badgeWidget:
                                        _buildChartBadge(e, porsiPersen),
                                    badgePositionPercentageOffset: 1.35,
                                  );
                                }).toList(),
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 4,
                                centerSpaceRadius: 45,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimatedSlider(
                          index: 2,
                          child: _buildLegend(needsData),
                        ),
                      ] else ...[
                        AnimatedSlider(
                          index: 1,
                          child: _buildEmptyStateGrafik(),
                        ),
                      ],

                      const SizedBox(height: 40),

                      // 3. SUB-HEADER
                      const AnimatedSlider(
                        index: 3,
                        child: Text(
                          'Detail Kebutuhan',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. LIST / EMPTY STATE LIST
                      if (needsData.isEmpty)
                        AnimatedSlider(
                          index: 4,
                          child: _buildEmptyStateList(),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: needsData.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 1),
                          itemBuilder: (context, index) {
                            final item = needsData[index];
                            return AnimatedSlider(
                              index: index + 4,
                              child: NeedsListItem(
                                needs: item,
                                onEdit: () =>
                                    _showNeedsModal(context, needs: item),
                                onTap: () {
                                  // MENTOR NOTE: Bisa juga diarahkan ke riwayat spesifik kategori ini
                                },
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentGold,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.black, size: 28),
        onPressed: () => _showNeedsModal(context),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildChartBadge(NeedsModel e, double percentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: e.color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4)
        ],
      ),
      child: Text(
        "${percentage.toStringAsFixed(0)}%",
        style: TextStyle(
            color: e.color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLegend(List<NeedsModel> data) {
    return Wrap(
      spacing: 16,
      runSpacing: 10,
      children: data
          .map((needs) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: needs.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(needs.category,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ))
          .toList(),
    );
  }

  Widget _buildEmptyStateGrafik() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(Icons.pie_chart_outline,
              size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text("Grafik alokasi belum tersedia",
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildEmptyStateList() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.list_alt_rounded, size: 48, color: Colors.white10),
            SizedBox(height: 12),
            Text("Belum ada kategori anggaran dibuat.",
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}