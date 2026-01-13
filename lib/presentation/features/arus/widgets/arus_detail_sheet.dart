import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uangku/data/models/arus_model.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';

class ArusDetailSheet extends StatelessWidget {
  final Arus arus;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ArusDetailSheet({
    super.key,
    required this.arus,
    this.onEdit,
    this.onDelete,
  });

  // MENTOR ADD: Helper untuk menampilkan gambar layar penuh
  void _showFullScreenImage(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(
              File(path),
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = arus.type == 'expense' || arus.type.toString().contains('expense');
    
    final bool isSystemTransaction = arus.category.toLowerCase() == 'tagihan' || 
                                     arus.debtId != null;

    DateTime displayDate;
    if (arus.timestamp is int) {
      displayDate = DateTime.fromMillisecondsSinceEpoch(arus.timestamp as int);
    } else    displayDate = arus.timestamp;
  
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isExpense ? "Pengeluaran" : "Pemasukan",
                    style: TextStyle(
                      color: isExpense ? AppColors.negativeRed : AppColors.positiveGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp',
                      decimalDigits: 0,
                    ).format(arus.amount),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isExpense ? AppColors.negativeRed : AppColors.positiveGreen).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  color: isExpense ? AppColors.negativeRed : AppColors.positiveGreen,
                ),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white10),
          ),

          _buildDetailRow(Icons.category_outlined, "Kategori", arus.category),
          _buildDetailRow(
            Icons.calendar_today_outlined, 
            "Waktu Transaksi", 
            DateFormat('EEEE, d MMMM yyyy - HH:mm', 'id_ID').format(displayDate)
          ),
          
          if (arus.description != null && arus.description!.isNotEmpty)
            _buildDetailRow(Icons.notes_rounded, "Catatan", arus.description!),

          if (arus.imagePath != null && arus.imagePath!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              "Lampiran Gambar",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            // MENTOR FIX: GestureDetector untuk trigger Full Screen Image
            GestureDetector(
              onTap: () => _showFullScreenImage(context, arus.imagePath!),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(arus.imagePath!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05), 
                          borderRadius: BorderRadius.circular(16)
                        ),
                        child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white24)),
                      ),
                    ),
                  ),
                  // Indikator bahwa gambar bisa di klik
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          if (isSystemTransaction) 
            _buildSystemNotice()
          else
            _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.negativeRed),
            label: const Text("Hapus", style: TextStyle(color: AppColors.negativeRed)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.negativeRed, width: 1),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
            label: const Text("Ubah", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Transaksi ini terhubung dengan modul Hutang/Piutang. Perubahan hanya dapat dilakukan melalui modul terkait.",
              style: TextStyle(color: Colors.blueAccent, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}