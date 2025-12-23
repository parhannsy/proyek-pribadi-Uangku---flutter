// lib/presentation/features/dashboard/widgets/recent_transactions_list.dart (REVISI FINAL TABEL STRETCH)

import 'package:flutter/material.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({super.key});
  
  @override
  Widget build(BuildContext context) {
    // DATA DUMMY
    final List<Map<String, String>> transactions = [
      {'Tanggal': '12 des', 'Hari': 'Minggu', 'Keperluan': 'Jajan', 'Nominal': '-Rp 123.456'},
      {'Tanggal': '11 des', 'Hari': 'Sabtu', 'Keperluan': 'Gaji Bulanan', 'Nominal': '+Rp 5.000.000'},
      {'Tanggal': '10 des', 'Hari': 'Jumat', 'Keperluan': 'Beli Kopi', 'Nominal': '-Rp 30.000'},
      {'Tanggal': '09 des', 'Hari': 'Kamis', 'Keperluan': 'Top Up E-Wallet', 'Nominal': '-Rp 50.000'},
      {'Tanggal': '08 des', 'Hari': 'Rabu', 'Keperluan': 'Uang Saku', 'Nominal': '+Rp 200.000'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengeluaran terbaru',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'pengeluaran anda selama 1 minggu terakhir',
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double minTableWidth = constraints.maxWidth;
                
                // HACK: Asumsi lebar minimum yang dibutuhkan oleh Tgl, Hari, Keterangan, dan padding (sekitar 200px)
                // Kita gunakan sisa lebar sebagai spasi.
                final double estimatedContentWidth = 200; 
                final double requiredColumnSpacing = (minTableWidth - estimatedContentWidth) / 4; 
                
                // Gunakan nilai aman yang tetap besar jika perhitungan terlalu kecil.
                final double finalColumnSpacing = requiredColumnSpacing > 30 ? requiredColumnSpacing : 30;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: minTableWidth),
                    child: DataTable(
                      // PERUBAHAN KRUSIAL: Mengatur columnSpacing berdasarkan perhitungan sisa lebar
                      columnSpacing: finalColumnSpacing, 
                      
                      // Mengatur horizontal margin ke 0 agar tabel menempel ke padding container luar
                      horizontalMargin: 0, 
                      
                      dataRowMinHeight: 30,
                      dataRowMaxHeight: 40,
                      headingRowHeight: 40,
                      
                      columns: const [
                        DataColumn(label: Text('Tgl', style: TextStyle(color: AppColors.textSecondary))),
                        DataColumn(label: Text('Hari', style: TextStyle(color: AppColors.textSecondary))),
                        DataColumn(label: Text('Keterangan', style: TextStyle(color: AppColors.textSecondary))), 
                        DataColumn(
                          // HACK: Menambahkan tooltip dan alignment untuk memastikan kolom nominal menggunakan ruang sisa
                          label: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Nominal', 
                              style: TextStyle(color: AppColors.textSecondary), 
                            ),
                          ),
                          numeric: true, // HACK: numeric true memaksa alignment ke kanan
                        ),
                      ],
                      rows: transactions.map((data) {
                        final bool isExpense = data['Nominal']!.startsWith('-');
                        final nominalColor = isExpense ? AppColors.negativeRed : AppColors.positiveGreen;
        
                        return DataRow(
                          cells: [
                            DataCell(Text(data['Tanggal']!, style: TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                            DataCell(Text(data['Hari']!, style: TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                            DataCell(Text(data['Keperluan']!, style: TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                            DataCell(
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  data['Nominal']!,
                                  style: TextStyle(
                                    color: nominalColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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
          
          // Link Detail Pengeluaran
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                // TODO: Navigasi ke Halaman Detail Pengeluaran
              },
              child: Text(
                'Lihat detail Pengeluaran →',
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