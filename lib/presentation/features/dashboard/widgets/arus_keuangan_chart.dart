// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uangku/application/flow/arus_cubit.dart';
import 'package:uangku/application/flow/arus_state.dart';
import 'package:uangku/data/models/enums/arus_type.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/utils/number_formatter.dart';

class ArusKeuanganChart extends StatefulWidget {
  const ArusKeuanganChart({super.key});

  @override
  State<ArusKeuanganChart> createState() => _ArusKeuanganChartState();
}

class _ArusKeuanganChartState extends State<ArusKeuanganChart> {
  String _selectedPeriod = 'Bulan ini';
  final List<String> periods = const ['Semua', 'Hari ini', 'Minggu ini', 'Bulan ini'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArusCubit, ArusState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildPeriodSelector(context),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 280, // Ditambah tingginya agar tooltip punya ruang
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 30, 20, 10), // Padding dalam diperlebar
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                // MENTOR NOTE: Clip.none sangat penting agar tooltip tidak terpotong kontainer
                child: ClipRect(
                  clipBehavior: Clip.none, 
                  child: state.isLoading 
                      ? const Center(child: CircularProgressIndicator(color: AppColors.accentGold))
                      : _buildChartContent(state),
                ),
              ),
            ),
            _buildFooter(),
          ],
        );
      },
    );
  }

  Widget _buildChartContent(ArusState state) {
    if (_selectedPeriod == 'Hari ini') return _buildDailySummary(state);
    if (state.aruses.isEmpty) return const Center(child: Text("Belum ada data", style: TextStyle(color: Colors.white24)));

    final Map<int, Map<ArusType, double>> dayData = {};
    final now = DateTime.now();
    
    int daysInRange = 30;
    DateTime startDate = DateTime(now.year, now.month, 1);
    
    if (_selectedPeriod == 'Minggu ini') {
      daysInRange = 7;
      startDate = now.subtract(Duration(days: now.weekday - 1));
    }

    for (int i = 0; i < daysInRange; i++) {
      dayData[i] = {ArusType.income: 0.0, ArusType.expense: 0.0};
    }

    double maxAmount = 100000;
    for (var arus in state.aruses) {
      final difference = arus.timestamp.difference(startDate).inDays;
      if (difference >= 0 && difference < daysInRange) {
        dayData[difference]![arus.type] = (dayData[difference]![arus.type] ?? 0) + arus.amount.toDouble();
        maxAmount = max(maxAmount, dayData[difference]![arus.type]!);
      }
    }

    List<FlSpot> incomeSpots = [];
    List<FlSpot> expenseSpots = [];

    for (int i = 0; i < daysInRange; i++) {
      incomeSpots.add(FlSpot(i.toDouble(), dayData[i]![ArusType.income]!));
      expenseSpots.add(FlSpot(i.toDouble(), dayData[i]![ArusType.expense]!));
    }

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => AppColors.surfaceColor.withOpacity(0.95),
            tooltipBorderRadius: BorderRadius.circular(8),
            fitInsideHorizontally: true, // AGAR TOOLTIP TIDAK KELUAR LAYAR KIRI/KANAN
            fitInsideVertically: true,   // AGAR TOOLTIP TIDAK KELUAR LAYAR ATAS
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((s) {
                final date = startDate.add(Duration(days: s.x.toInt()));
                final formattedDate = DateFormat('dd MMM').format(date);
                final isIncome = s.barIndex == 0;
                return LineTooltipItem(
                  '$formattedDate\n',
                  const TextStyle(color: Colors.white54, fontSize: 10),
                  children: [
                    TextSpan(
                      text: '${isIncome ? 'In' : 'Out'}: ${NumberFormatter.formatRupiah(s.y.toInt())}',
                      style: TextStyle(
                        color: isIncome ? AppColors.positiveGreen : AppColors.negativeRed, 
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (daysInRange - 1).toDouble(),
        minY: 0,
        // Diberi margin maxY lebih besar (40%) agar lonjakan curva tidak menabrak atap box
        maxY: maxAmount * 1.4, 
        lineBarsData: [
          _lineStyle(incomeSpots, AppColors.positiveGreen),
          _lineStyle(expenseSpots, AppColors.negativeRed),
        ],
      ),
    );
  }

  LineChartBarData _lineStyle(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      // MENTOR NOTE: Mengurangi smoothness agar curva tidak melenceng terlalu jauh dari titik asli
      curveSmoothness: 0.15, 
      preventCurveOverShooting: true, // Mencegah curva melebihi batas nilai Y
      barWidth: 3,
      color: color,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  // --- Widget Header, Selector, & Footer tetap sama ---
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Arus keuangan', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Grafik perbandingan terhadap pemasukan', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: periods.length,
        itemBuilder: (context, index) {
          final period = periods[index];
          final isSelected = period == _selectedPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(period, style: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontSize: 12)),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedPeriod = period);
                context.read<ArusCubit>().loadFilteredArus(period);
              },
              selectedColor: AppColors.accentGold,
              backgroundColor: Colors.white10,
              showCheckmark: false,
              shape: const StadiumBorder(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailySummary(ArusState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _summaryRow("Pemasukan hari ini", state.totalIncome, AppColors.positiveGreen),
        const Divider(color: Colors.white10, height: 40),
        _summaryRow("Pengeluaran hari ini", state.totalExpense, AppColors.negativeRed),
      ],
    );
  }

  Widget _summaryRow(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(NumberFormatter.formatRupiah(amount.toInt()), style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {},
          child: const Text('Lihat detail Arus →', style: TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}