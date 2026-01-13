// lib/presentation/features/piutang/widgets/add_payment_form_modal.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uangku/application/debt/debt_cubit.dart';
import 'package:uangku/application/debt/debt_state.dart';
import 'package:uangku/data/models/debt_model.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/utils/number_formatter.dart';

class AddPaymentFormModal extends StatefulWidget {
  final DebtModel debt;
  final List<int> selectedTenors;

  const AddPaymentFormModal({
    super.key,
    required this.debt,
    required this.selectedTenors,
  });

  @override
  State<AddPaymentFormModal> createState() => _AddPaymentFormModalState();
}

class _AddPaymentFormModalState extends State<AddPaymentFormModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  DateTime? _selectedDate;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi dengan waktu sekarang (termasuk jam, menit, detik)
    _selectedDate = DateTime.now();
    _dateController.text = DateFormat('d MMMM yyyy').format(_selectedDate!);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<String?> _saveImageLocally(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String folderPath = p.join(directory.path, 'payments');
      final Directory folder = Directory(folderPath);

      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final String fileName = 'PAY_${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
      final String fullPath = p.join(folderPath, fileName);
      
      final File localImage = await image.copy(fullPath);
      return localImage.path;
    } catch (e) {
      debugPrint("Error saveImage: $e");
      return null;
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan lampirkan bukti pembayaran.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String? permanentPath = await _saveImageLocally(_imageFile!);
      if (permanentPath == null) throw Exception("Gagal menyimpan gambar");

      if (!mounted) return;

      // MENTOR TIP: Kirim selectedTenors dan pastikan Cubit memprosesnya
      await context.read<DebtCubit>().payTenor(
        debtId: widget.debt.id,
        paymentDate: _selectedDate!,
        imagePath: permanentPath,
        selectedTenors: widget.selectedTenors, 
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalAmount = (widget.debt.amountPerTenor * widget.selectedTenors.length).toInt();
    final String tenorDisplay = widget.selectedTenors.join(", ");

    return BlocListener<DebtCubit, DebtState>(
      listener: (context, state) {
        if (state is DebtOperationSuccess) {
          Navigator.pop(context);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24, right: 24, top: 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildInfoBox(totalAmount, tenorDisplay),
              const SizedBox(height: 24),
              _buildLabel("Tanggal Pembayaran"),
              _buildDatePicker(),
              const SizedBox(height: 20),
              _buildLabel("Bukti Gambar"),
              _buildImagePreviewBox(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(int total, String tenor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildInfoRow("Total Pembayaran", NumberFormatter.formatRupiah(total), isGold: true),
          const Divider(color: AppColors.textSecondary, thickness: 0.2, height: 24),
          _buildInfoRow("Tenor Ke", tenor),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: () async {
        final DateTime now = DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? now,
          firstDate: widget.debt.dateBorrowed,
          lastDate: now,
        );
        if (date != null) {
          setState(() {
            // MENTOR TIP: Gabungkan tanggal pilihan dengan waktu saat ini
            // Agar tidak menjadi 00:00:00 yang sering bermasalah di query database
            _selectedDate = DateTime(
              date.year,
              date.month,
              date.day,
              now.hour,
              now.minute,
              now.second,
            );
            _dateController.text = DateFormat('d MMMM yyyy').format(date);
          });
        }
      },
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(Icons.calendar_today_rounded),
    );
  }

  // --- Widget helper lainnya tetap sama seperti sebelumnya ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Konfirmasi Bayar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isGold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(value, style: TextStyle(color: isGold ? AppColors.accentGold : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8, left: 4), child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)));

  Widget _buildImagePreviewBox() {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity, height: 160,
        decoration: BoxDecoration(color: AppColors.surfaceColor, borderRadius: BorderRadius.circular(16)),
        child: _imageFile == null 
          ? const Icon(Icons.camera_alt_outlined, color: AppColors.accentGold, size: 40)
          : ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(_imageFile!, fit: BoxFit.cover)),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity, height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: _isLoading ? const CircularProgressIndicator() : const Text("KONFIRMASI SEKARANG", style: TextStyle(color: AppColors.primaryBackground, fontWeight: FontWeight.bold)),
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon) => InputDecoration(
    filled: true, fillColor: AppColors.surfaceColor,
    prefixIcon: Icon(icon, color: AppColors.accentGold, size: 20),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
  );
}