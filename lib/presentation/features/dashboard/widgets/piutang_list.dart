// lib/presentation/features/dashboard/widgets/piutang_list.dart

import 'package:flutter/material.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';

class PiutangList extends StatelessWidget {
  const PiutangList({super.key});
  
  @override
  Widget build(BuildContext context) {
    // DATA DUMMY
    final List<Map<String, String>> debts = [
      {'Tempat': 'A', 'Tenor': 'ke 2', 'Jatuh tempo': '20 hari', 'Nominal': 'Rp 123.456'},
      {'Tempat': 'B', 'Tenor': 'ke 3', 'Jatuh tempo': '5 hari', 'Nominal': 'Rp 123.456'},
      {'Tempat': 'C', 'Tenor': 'ke 4', 'Jatuh tempo': 'Hari ini', 'Nominal': 'Rp 123.456'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Piutang',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Angsuran terdekat anda',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(8),
            ),
            // PERUBAHAN UTAMA: Menerapkan LayoutBuilder untuk mengukur lebar parent
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double minTableWidth = constraints.maxWidth;
                
                // Hitung spacing yang dibutuhkan (disesuaikan untuk 4 kolom)
                final double estimatedContentWidth = 160; 
                final double requiredColumnSpacing = (minTableWidth - estimatedContentWidth) / 4; 
                final double finalColumnSpacing = requiredColumnSpacing > 30 ? requiredColumnSpacing : 30;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    // Memaksa lebar minimum tabel selebar Container parent.
                    constraints: BoxConstraints(minWidth: minTableWidth),
                    child: DataTable(
                      // Menggunakan spacing yang sudah dihitung
                      columnSpacing: finalColumnSpacing, 
                      horizontalMargin: 0, 
                      
                      dataRowMinHeight: 30,
                      dataRowMaxHeight: 40,
                      headingRowHeight: 40,
                      
                      columns: const [
                        DataColumn(label: Text('Tempat', style: TextStyle(color: AppColors.textSecondary))),
                        DataColumn(label: Text('Tenor', style: TextStyle(color: AppColors.textSecondary))),
                        DataColumn(label: Text('Jatuh tempo', style: TextStyle(color: AppColors.textSecondary))),
                        DataColumn(
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Nominal', 
                              style: TextStyle(color: AppColors.textSecondary)
                            ),
                          ),
                          numeric: true, // HACK: memaksa alignment ke kanan
                        ),
                      ],
                      rows: debts.map((data) {
                        final bool isToday = data['Jatuh tempo'] == 'Hari ini';
                        final bool isUrgent = isToday || data['Jatuh tempo'] == '5 hari';
                        
                        return DataRow(
                          cells: [
                            DataCell(Text(data['Tempat']!, style: TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                            DataCell(Text(data['Tenor']!, style: TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                            DataCell(Text(data['Jatuh tempo']!, 
                              style: TextStyle(
                                color: isToday ? AppColors.negativeRed : (isUrgent ? AppColors.accentGold : AppColors.textPrimary), 
                                fontSize: 12, 
                                fontWeight: FontWeight.bold
                              )
                            )),
                            DataCell(
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  data['Nominal']!, 
                                  style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)
                                )
                              )
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),

          // Link Detail Piutang
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                // TODO: Navigasi ke Halaman Detail Piutang
              },
              child: Text(
                'Lihat detail piutang →',
                style: TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}