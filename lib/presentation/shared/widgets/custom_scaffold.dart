// lib/presentation/shared/widgets/custom_scaffold.dart

import 'package:flutter/material.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';

class CustomScaffold extends StatelessWidget {
  // Menghapus final String title;
  final Widget body;
  final int currentIndex;
  final ValueChanged<int>? onItemSelected;
  final List<Widget> pages; 

  const CustomScaffold({
    Key? key,
    required this.body,
    required this.currentIndex,
    required this.onItemSelected,
    required this.pages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ... (navItems tetap sama) ...
    final List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: 'Beranda',
        activeIcon: Icon(Icons.home),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long_outlined),
        label: 'Piutang',
        activeIcon: Icon(Icons.receipt_long),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.wallet_travel_outlined),
        label: 'Kebutuhan',
        activeIcon: Icon(Icons.wallet_travel),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.auto_graph_outlined),
        label: 'Arus',
        activeIcon: Icon(Icons.auto_graph),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        // JUDUL STATIS DI SINI
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fulus', // Judul Utama
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18, // Ukuran disesuaikan untuk App Bar
              ),
            ),
            Text(
              'Pencatatan keuangan pribadi', // Sub-judul
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11, // Lebih kecil agar tidak terlalu dominan
              ),
            ),
          ],
        ),
        // END JUDUL STATIS
        backgroundColor: AppColors.surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ), 
      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surfaceColor,
        selectedItemColor: AppColors.accentGold,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: currentIndex,
        onTap: onItemSelected,
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
    );
  }
}