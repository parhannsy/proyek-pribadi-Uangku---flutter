// lib/presentation/features/piutang/pages/payment_receipt_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uangku/data/models/arus_model.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/presentation/shared/widgets/animated_slider.dart';
import 'package:uangku/utils/number_formatter.dart';

class PaymentReceiptPage extends StatelessWidget {
  final Arus transaction;
  final int tenorNumber;

  const PaymentReceiptPage({
    super.key,
    required this.transaction,
    required this.tenorNumber,
  });

  // LOGIKA BARU: Fungsi untuk menampilkan gambar Fullscreen
  void _showFullScreenImage(BuildContext context) {
    if (transaction.imagePath == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92), // Latar belakang sangat gelap agar fokus
      builder: (context) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: GestureDetector(
          onTap: () => Navigator.pop(context), // Tap dimana saja untuk keluar
          child: Center(
            child: Hero(
              tag: 'payment_image_${transaction.id}', // Animasi transisi smooth
              child: InteractiveViewer( // Fitur Pinch-to-zoom otomatis
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  File(transaction.imagePath!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        title: const Text('Detail Bukti Bayar', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Status Berhasil (Index 0)
            const AnimatedSlider(
              index: 0,
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.positiveGreen, size: 64),
                    SizedBox(height: 12),
                    Text("Pembayaran Terverifikasi", 
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 2. Bukti Gambar (Index 1) - Sekarang bisa diklik
            AnimatedSlider(
              index: 1,
              child: _buildImageAttachment(context),
            ),
            const SizedBox(height: 24),

            // 3. Detail Informasi (Index 2)
            AnimatedSlider(
              index: 2,
              child: _buildInfoCard(dateFormat),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageAttachment(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Lampiran Bukti (Ketuk untuk memperbesar)", 
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showFullScreenImage(context),
          child: Hero(
            tag: 'payment_image_${transaction.id}',
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: transaction.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        File(transaction.imagePath!), 
                        fit: BoxFit.cover,
                        // Menambahkan loading indicator sederhana
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.redAccent),
                        ),
                      ),
                    )
                  : const Center(child: Text("Tidak ada gambar", style: TextStyle(color: Colors.white54))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(DateFormat dateFormat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _infoRow("Tenor Pembayaran", "Tenor Ke-$tenorNumber"),
          _infoRow("Tanggal Bayar", dateFormat.format(transaction.timestamp)),
          _infoRow("Kategori Arus", transaction.category),
          const Divider(color: Colors.white10, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Nominal Bayar", style: TextStyle(color: AppColors.textSecondary)),
              Text(NumberFormatter.formatRupiah(transaction.amount.toInt()),
                style: const TextStyle(color: AppColors.accentGold, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}