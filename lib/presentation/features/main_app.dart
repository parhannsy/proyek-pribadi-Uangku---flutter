// lib/presentation/features/main_app.dart

import 'package:flutter/material.dart';
import 'package:uangku/presentation/features/arus/pages/arus_keuangan_page.dart';
import 'package:uangku/presentation/features/kebutuhan/pages/kebutuhan_page.dart';
import 'package:uangku/presentation/features/piutang/pages/piutang_page.dart';
import 'package:uangku/presentation/features/dashboard/pages/dashboard_page.dart';
import 'package:uangku/presentation/shared/widgets/custom_scaffold.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;

  /// MENTOR NOTE: 
  /// Kita menggunakan 'getter' dan menghapus kata kunci 'const'.
  /// Dengan menggunakan UniqueKey() pada halaman yang sedang aktif (active tab),
  /// kita memaksa Flutter untuk menjalankan ulang initState() pada halaman tersebut,
  /// sehingga widget AnimatedSlider di dalamnya akan memicu animasi kembali.
  List<Widget> get _pages => [
        DashboardPage(
          key: _currentIndex == 0 ? UniqueKey() : const ValueKey('DashboardPage'),
        ),
        PiutangPage(
          key: _currentIndex == 1 ? UniqueKey() : const ValueKey('PiutangPage'),
        ),
        KebutuhanPage(
          key: _currentIndex == 2 ? UniqueKey() : const ValueKey('KebutuhanPage'),
        ),
        ArusKeuanganPage(
          key: _currentIndex == 3 ? UniqueKey() : const ValueKey('ArusKeuanganPage'),
        ),
      ];

  void _onItemTapped(int index) {
    // Jika user menekan tab yang sama, tidak perlu melakukan apa-apa
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kita panggil getter _pages di dalam build agar mendapatkan instance terbaru dengan UniqueKey
    final currentPages = _pages;

    return CustomScaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: currentPages,
      ),
      currentIndex: _currentIndex,
      onItemSelected: _onItemTapped,
      pages: currentPages, 
    );
  }
}