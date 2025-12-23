// lib/presentation/features/arus/widgets/transaction_list_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uangku/data/models/arus_model.dart' as arus_model;
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/utils/number_formatter.dart'; 

class TransactionListItem extends StatelessWidget {
  final arus_model.Arus transaction;
  final bool isIncome;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final nominalColor = isIncome ? AppColors.positiveGreen : AppColors.negativeRed;
    
    // Pastikan timestamp tidak null atau berikan default sekarang jika ragu
    final String formattedDate = DateFormat('dd/MM').format(transaction.timestamp);

    // MENTOR NOTE: Gunakan variabel pembantu untuk menangani Null Safety dengan elegan

    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kolom Tanggal
          Expanded(
            flex: 2,
            child: Text(
              formattedDate, 
              style: const TextStyle(
                color: AppColors.textSecondary, 
                fontSize: 13,
                fontWeight: FontWeight.w500
              ),
            ),
          ),
          
          // Kolom Deskripsi
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? "ya itu lah", // Menggunakan variabel yang sudah di-handle null-nya
                  style: const TextStyle(
                    color: AppColors.textPrimary, 
                    fontSize: 14, 
                    fontWeight: FontWeight.w600
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                // Tampilkan kategori sebagai sub-text jika deskripsi tersedia
                if (transaction.description != null && transaction.description!.isNotEmpty)
                  Text(
                    transaction.category,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),

          // Kolom Nominal
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (transaction.needId != null)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.inventory_2_outlined, size: 12, color: AppColors.textSecondary),
                  ),
                if (transaction.debtId != null)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.handshake_outlined, size: 12, color: AppColors.textSecondary),
                  ),
                Text(
                  '${isIncome ? "+" : "-"}${NumberFormatter.formatRupiah(transaction.amount.toInt())}',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: nominalColor, 
                    fontSize: 14, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}