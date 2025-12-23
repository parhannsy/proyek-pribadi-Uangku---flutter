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
    _selectedDate = DateTime.now();
    _dateController.text = DateFormat('d MMMM yyyy').format(_selectedDate!);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  /// Menyimpan file gambar dari cache temporary ke storage permanen aplikasi
// Perbarui fungsi ini di add_payment_form_modal.dart

// lib/presentation/features/piutang/widgets/add_payment_form_modal.dart

Future<String?> _saveImageLocally(File image) async {
  try {
    // 1. Dapatkan direktori internal aplikasi
    final directory = await getApplicationDocumentsDirectory();
    
    // 2. Tentukan sub-folder 'payments' agar rapi (Sesuai saran folderisasi)
    final String folderPath = p.join(directory.path, 'payments');
    final Directory folder = Directory(folderPath);

    // 3. LOGIKA OTOMATIS: Buat folder jika belum ada
    if (!await folder.exists()) {
      await folder.create(recursive: true);
      debugPrint("DEBUG: Folder payments baru saja dibuat.");
    }

    // 4. Buat nama file unik (Format: PAY_timestamp.ext)
    final String fileName = 'PAY_${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
    final String fullPath = p.join(folderPath, fileName);
    
    // 5. Salin file dari temporary cache ke folder permanen
    final File localImage = await image.copy(fullPath);
    
    debugPrint("DEBUG: Gambar berhasil disimpan di: $fullPath");
    return localImage.path;
  } catch (e) {
    // Log ini akan muncul jika ada masalah izin atau storage penuh
    debugPrint("Koreksi Mentor - Error detail di saveImage: $e");
    return null;
  }
}

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Kompresi untuk efisiensi database/storage
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
      // DEBUG: Cek data sebelum dikirim
      debugPrint("DEBUG: Debt ID: ${widget.debt.id}");
      debugPrint("DEBUG: Selected Tenors: ${widget.selectedTenors}");

      // 1. Simpan Gambar
      final String? permanentPath = await _saveImageLocally(_imageFile!);
      if (permanentPath == null) throw Exception("Fungsi _saveImageLocally mengembalikan null");

      // 2. Eksekusi Cubit
      if (!mounted) return;
      
      // TEGURAN MENTOR: Pastikan fungsi payTenor di Cubit benar-benar 
      // mendukung List<int> jika Anda mengirim selectedTenors secara utuh.
      await context.read<DebtCubit>().payTenor(
        debtId: widget.debt.id,
        paymentDate: _selectedDate!,
        imagePath: permanentPath,
        selectedTenors: widget.selectedTenors, 
      );

      debugPrint("DEBUG: Cubit.payTenor berhasil dieksekusi");

    } catch (e, stacktrace) {
      debugPrint("ERROR LOG: $e");
      debugPrint("STACKTRACE: $stacktrace"); // Ini akan memberitahu baris mana yang rusak di Cubit
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencatat: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // LOGIKA PERBAIKAN: Pastikan hasil perkalian dikonversi ke int agar match dengan NumberFormatter
    final int totalAmount = (widget.debt.amountPerTenor * widget.selectedTenors.length).toInt();
    
    // Menampilkan daftar tenor yang dipilih (Misal: "1, 2")
    final String tenorDisplay = widget.selectedTenors.isEmpty 
        ? "-" 
        : widget.selectedTenors.join(", ");

    return BlocListener<DebtCubit, DebtState>(
      listener: (context, state) {
        if (state is DebtOperationSuccess) {
          Navigator.pop(context); // Tutup modal saat sukses
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              
              // SEKSI INFORMASI (Fixed: Menampilkan Nominal & Tenor)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      "Total Pembayaran", 
                      NumberFormatter.formatRupiah(totalAmount), 
                      isGold: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.textSecondary, thickness: 0.2),
                    ),
                    _buildInfoRow(
                      "Tenor Ke", 
                      tenorDisplay,
                    ),
                  ],
                ),
              ),
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

  // --- SUB-WIDGETS UNTUK KEBERSIHAN KODE ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Konfirmasi Bayar", 
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isGold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(
          value, 
          style: TextStyle(
            color: isGold ? AppColors.accentGold : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          )
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text, 
        style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 13)
      ),
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: widget.debt.dateBorrowed,
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
            _dateController.text = DateFormat('d MMMM yyyy').format(date);
          });
        }
      },
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(Icons.calendar_today_rounded),
    );
  }

  Widget _buildImagePreviewBox() {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _imageFile == null ? AppColors.accentGold.withOpacity(0.3) : AppColors.accentGold,
            style: _imageFile == null ? BorderStyle.none : BorderStyle.solid,
          ),
        ),
        child: _imageFile == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, color: AppColors.accentGold, size: 42),
                  SizedBox(height: 8),
                  Text("Upload Bukti Transfer", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_imageFile!, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          foregroundColor: AppColors.primaryBackground,
          disabledBackgroundColor: AppColors.textSecondary.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24, width: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBackground),
              )
            : const Text("KONFIRMASI SEKARANG", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surfaceColor,
      prefixIcon: Icon(icon, color: AppColors.accentGold, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}