// lib/presentation/features/piutang/widgets/add_debt_form_modal.dart (REVISI FINAL - FIXED BLOC FLOW & DYNAMIC BUTTON)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uangku/application/debt/debt_cubit.dart';
import 'package:uangku/application/debt/debt_state.dart'; 
import 'package:uangku/data/models/debt_model.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/presentation/shared/widgets/animated_slider.dart';

// =========================================================================
// WIDGET BARU: MaxNumericInputFormatter (TIDAK BERUBAH)
// =========================================================================
class MaxNumericInputFormatter extends TextInputFormatter {
  final int maxValue;
  final int minValue;

  MaxNumericInputFormatter({required this.maxValue, this.minValue = 1});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // [Logic formatter tetap sama]
    String newText = newValue.text;
    newText = newText.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    int? value = int.tryParse(newText);
    
    if (value != null && value > maxValue) {
      String maxString = maxValue.toString();
      return TextEditingValue(
        text: maxString,
        selection: TextSelection.collapsed(offset: maxString.length),
      );
    }
    
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

// =========================================================================
// ADD DEBT FORM MODAL (STATEFUL) - FUNGSI PENUH
// =========================================================================

class AddDebtFormModal extends StatefulWidget {
  const AddDebtFormModal({super.key});

  @override
  State<AddDebtFormModal> createState() => _AddDebtFormModalState();
}

class _AddDebtFormModalState extends State<AddDebtFormModal> {
  // Global Key untuk Form Validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); 
  
  // Controllers untuk semua field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _tglMeminjamController = TextEditingController();
  final TextEditingController _tglJatuhTempoController = TextEditingController();
  final TextEditingController _tenorController = TextEditingController();
  final TextEditingController _biayaPerTenorController = TextEditingController();
  
  // State
  DateTime? _tglMeminjam; 
  // >>> KOREKSI BARU: State untuk mengontrol status validasi tombol
  bool _isFormValid = false; 

  // >>> FUNGSI BARU: Pengecekan validasi form
  void _checkFormValidity() {
    // Penggunaan 'validate()' di sini akan menampilkan pesan error
    // Kita menggunakan 'validate()' yang mengembalikan boolean.
    final isValid = _formKey.currentState?.validate() ?? false; 
    // Juga cek tanggal meminjam secara eksplisit, karena validatornya berbeda
    final isDateValid = _tglMeminjam != null;

    if (_isFormValid != isValid && isDateValid) {
      setState(() {
        _isFormValid = isValid && isDateValid;
      });
    } else if (_isFormValid != isValid || !isDateValid) {
      // Logic untuk memastikan _isFormValid menjadi false jika salah satu kondisi tidak terpenuhi
      setState(() {
        _isFormValid = isValid && isDateValid;
      });
    }
  }

  // Fungsi untuk menampilkan Date Picker (DIREVISI)
  Future<void> _selectDate(BuildContext context) async {
    // [Logic Date Picker sama]
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tglMeminjam ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accentGold, 
              onPrimary: AppColors.primaryBackground,
              surface: AppColors.surfaceColor,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.primaryBackground,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      if (picked.isAfter(DateTime.now())) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tanggal meminjam tidak boleh di masa depan.')),
          );
        }
        return;
      }
      
      setState(() {
        _tglMeminjam = picked;
        _tglMeminjamController.text = DateFormat('yyyy-MM-dd').format(picked);
      });

      // >>> KOREKSI: Panggil pengecekan validitas setelah update state
      _checkFormValidity(); 
    }
  }

  // Helper untuk membuat TextField yang konsisten (DIREVISI untuk onChanged)
  Widget _buildTextField({
    required String label,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onTap,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    // [Logic TextField sama]
    const TextStyle labelStyle = TextStyle(
      color: AppColors.textPrimary, 
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: onTap != null,
            onTap: onTap,
            validator: validator,
            // >>> KOREKSI: Tambahkan onChanged untuk memicu validasi dinamis
            onChanged: (value) => _checkFormValidity(), 
            // ...
            style: const TextStyle(color: AppColors.textPrimary),
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
              border: InputBorder.none,
              prefixIcon: icon != null ? Icon(icon, color: AppColors.textSecondary) : null,
              prefixText: (label.contains('Biaya')) ? 'Rp ' : null,
              prefixStyle: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // =========================================================================
  // FUNGSI INTI: SUBMIT FORMULIR (TIDAK BERUBAH)
  // =========================================================================
  Future<void> _submitForm(BuildContext formCtx) async { 
    // Di sini kita mengandalkan _isFormValid, tapi tetap ada cek validasi terakhir 
    // jika pengguna melewati validasi dinamis (jarang terjadi).
    if (!_formKey.currentState!.validate() || _tglMeminjam == null) {
      return;
    }

    try {
      // 1. Parsing Data Input
      final int amountPerTenor = int.tryParse(_biayaPerTenorController.text.replaceAll('.', '')) ?? 0;
      final int totalTenor = int.tryParse(_tenorController.text) ?? 0;
      final int dueDay = int.tryParse(_tglJatuhTempoController.text) ?? 0;
      
      // 2. Buat DebtModel
      final newDebt = DebtModel(
        id: '', 
        borrower: _nameController.text.trim(),
        purpose: _purposeController.text.trim(),
        dateBorrowed: _tglMeminjam!,
        dueDateDay: dueDay,
        amountPerTenor: amountPerTenor,
        totalTenor: totalTenor,
        remainingTenor: totalTenor, 
      );
      
      // 3. Panggil Cubit untuk menyimpan (TIDAK PERLU AWAIT)
      formCtx.read<DebtCubit>().addDebt(newDebt);
      
    } catch (e) {
      // Jika ada error sinkronus (jarang)
    }
  }


  @override
  void initState() {
    super.initState();
    // [Logic initState sama]
    final NumberFormat currencyFormatter = NumberFormat.decimalPattern('id');

    // Panggil _checkFormValidity() saat inisialisasi untuk mengaktifkan tombol 
    // jika semua field sudah diisi saat ini
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFormValidity());

    // ... (Logic listener _biayaPerTenorController sama) ...
    _biayaPerTenorController.addListener(() {
      if (!mounted) return;
      
      final String text = _biayaPerTenorController.text.replaceAll('.', '');
      if (text.isNotEmpty) {
        try {
          final int value = int.parse(text);
          final String formatted = currencyFormatter.format(value);
          
          if (_biayaPerTenorController.text != formatted) {
            _biayaPerTenorController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
        } catch (e) {
          // Abaikan jika input tidak valid
        }
      }
    });
    
    _tglMeminjam = DateTime.now();
    _tglMeminjamController.text = DateFormat('yyyy-MM-dd').format(_tglMeminjam!);
  }
  // >>> KOREKSI: Tambahkan dispose listener untuk _checkFormValidity()
  @override
  void dispose() {
    _nameController.dispose();
    _purposeController.dispose();
    _tglMeminjamController.dispose();
    _tglJatuhTempoController.dispose();
    _tenorController.dispose();
    _biayaPerTenorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // KELOMPOK SEMUA FIELD/WIDGET YANG INGIN DIANIMASIKAN
    final List<Widget> formItems = [
      // [Isi formItems sama]
      const Text(
        'Catatan hutang baru',
        style: TextStyle(
          color: AppColors.accentGold,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 24),

      _buildTextField(
        label: 'Tempat peminjaman (Nama)',
        hint: 'Platform/Nama Peminjam....',
        controller: _nameController,
        validator: (value) {
          if (value == null || value.isEmpty || value.trim().length < 3) {
            return 'Nama Peminjam minimal 3 karakter';
          }
          return null;
        },
      ),

      _buildTextField(
        label: 'Kebutuhan meminjam',
        hint: 'Alasan meminjam....',
        controller: _purposeController,
        validator: (value) {
          if (value == null || value.isEmpty || value.trim().length < 5) {
            return 'Kebutuhan harus diisi minimal 5 karakter';
          }
          return null;
        },
      ),

      Row(
        children: [
          Expanded(
            child: _buildTextField(
              label: 'Tanggal meminjam',
              hint: 'YYYY-MM-DD',
              icon: Icons.calendar_today,
              onTap: () => _selectDate(context),
              controller: _tglMeminjamController,
              validator: (value) {
                if (_tglMeminjam == null) {
                  return 'Pilih tanggal';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextField(
              label: 'Hari Jatuh tempo',
              hint: '1 - 31',
              icon: Icons.date_range,
              keyboardType: TextInputType.number,
              controller: _tglJatuhTempoController,
              inputFormatters: [
                MaxNumericInputFormatter(maxValue: 31),
              ],
              validator: (value) {
                if (value == null || int.tryParse(value) == null || int.parse(value) < 1 || int.parse(value) > 31) {
                  return 'Hari (1-31)';
                }
                return null;
              },
            ),
          ),
        ],
      ),

      Row(
        children: [
          Expanded(
            child: _buildTextField(
              label: 'Tenor (Bulan)',
              hint: 'banyak tenor (1-12)',
              keyboardType: TextInputType.number,
              controller: _tenorController,
              inputFormatters: [
                MaxNumericInputFormatter(maxValue: 12),
              ],
              validator: (value) {
                if (value == null || int.tryParse(value) == null || int.parse(value) < 1) {
                  return 'Tenor min. 1';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextField(
              label: 'Biaya per tenor',
              hint: 'besaran tenor...',
              keyboardType: TextInputType.number,
              controller: _biayaPerTenorController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), 
              ],
              validator: (value) {
                final cleanValue = value?.replaceAll('.', '') ?? '0';
                if (int.tryParse(cleanValue) == null || int.parse(cleanValue) < 1000) {
                  return 'Min. Rp 1.000';
                }
                return null;
              },
            ),
          ),
        ],
      ),
      
      const SizedBox(height: 24),
      
      // Tombol Simpan (Menggunakan BlocBuilder untuk loading)
      BlocBuilder<DebtCubit, DebtState>(
        buildWhen: (previous, current) => 
          current is DebtOperationInProgress || 
          current is DebtOperationSuccess || 
          current is DebtOperationFailure,
        builder: (context, state) {
          final bool isLoading = state is DebtOperationInProgress || state is DebtLoading;
          // >>> KOREKSI: Tambahkan kondisi _isFormValid
          final bool isButtonDisabled = isLoading || !_isFormValid; 

          return Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: isButtonDisabled ? null : () => _submitForm(context), 
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                disabledBackgroundColor: AppColors.textSecondary.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: isLoading 
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBackground,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Simpan hutang baru',
                      style: TextStyle(
                        color: AppColors.primaryBackground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          );
        },
      ),
    ];
    
    // Terapkan animasi staggered pada semua item form
    final List<Widget> animatedForm = List.generate(formItems.length, (index) {
      return AnimatedSlider(
        index: index,
        child: formItems[index],
      );
    });

    return BlocListener<DebtCubit, DebtState>( 
      listenWhen: (previous, current) => 
        current is DebtOperationSuccess || current is DebtOperationFailure,
      listener: (context, state) {
        if (state is DebtOperationSuccess) {
          Navigator.pop(context); 
        } else if (state is DebtOperationFailure) {
          // ...
        }
      },
      child: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey, 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...animatedForm,
                // KOREKSI: Tambahkan padding untuk menghindari keyboard di iOS/Android
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}