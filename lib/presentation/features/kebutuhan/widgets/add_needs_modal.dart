// lib/presentation/features/kebutuhan/widgets/add_needs_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:uangku/application/needs/needs_cubit.dart';
import 'package:uangku/application/needs/needs_state.dart';
import 'package:uangku/data/models/needs_model.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/presentation/shared/widgets/animated_slider.dart';
import 'package:intl/intl.dart';

class AddNeedsModal extends StatefulWidget {
  final NeedsModel? needs; // Jika null = Add, jika ada = Edit

  const AddNeedsModal({super.key, this.needs});

  @override
  State<AddNeedsModal> createState() => _AddNeedsModalState();
}

class _AddNeedsModalState extends State<AddNeedsModal> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _categoryController; 
  late final TextEditingController _budgetController;
  
  Color? _selectedColor;
  bool _isValid = false;

  final List<Color> _fullColorPalette = [
    AppColors.accentGold,
    const Color(0xFF64FFDA), 
    const Color(0xFF448AFF), 
    const Color(0xFFFF5252), 
    const Color(0xFFE040FB), 
    const Color(0xFFFFAB40), 
    const Color(0xFFB2FF59),
    const Color(0xFF00E5FF),
    const Color(0xFFFF4081),
    const Color(0xFF7C4DFF),
  ];

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: widget.needs?.category ?? '');
    
    String initialBudget = '';
    if (widget.needs != null) {
      initialBudget = NumberFormat.decimalPattern('id').format(widget.needs!.budgetLimit);
    }
    _budgetController = TextEditingController(text: initialBudget);
    
    if (widget.needs != null) {
      _selectedColor = Color(widget.needs!.colorValue);
    }

    _categoryController.addListener(_validate);
    _budgetController.addListener(_validate);
    _validate(); 
  }

  void _validate() {
    setState(() {
      _isValid = _categoryController.text.isNotEmpty &&
          _budgetController.text.isNotEmpty &&
          _selectedColor != null;
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final cleanBudget = _budgetController.text.replaceAll(RegExp(r'[^\d]'), '');

    if (widget.needs != null) {
      final updatedNeed = widget.needs!.copyWith(
        category: _categoryController.text.trim(),
        budgetLimit: int.parse(cleanBudget),
        colorValue: _selectedColor!.value,
      );
      context.read<NeedsCubit>().updateNeed(updatedNeed);
    } else {
      final newNeed = NeedsModel(
        id: const Uuid().v4(),
        category: _categoryController.text.trim(),
        budgetLimit: int.parse(cleanBudget),
        usedAmount: 0,
        colorValue: _selectedColor!.value,
      );
      context.read<NeedsCubit>().addNeed(newNeed);
    }
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NeedsCubit>().state;
    List<int> usedColorValues = [];
    
    if (state is NeedsLoadSuccess) {
      usedColorValues = state.needs.map((e) => e.colorValue).toList();
    } else if (state is NeedsOperationSuccess) {
      usedColorValues = state.needs.map((e) => e.colorValue).toList();
    }

    final availableColors = _fullColorPalette.where((color) {
      if (widget.needs != null && color.value == widget.needs!.colorValue) return true;
      return !usedColorValues.contains(color.value);
    }).toList();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24, left: 24, right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (Index 0)
              AnimatedSlider(
                index: 0,
                child: _buildHeader(),
              ),
              const SizedBox(height: 24),

              // Input Nama Kategori (Index 1)
              AnimatedSlider(
                index: 1,
                child: _buildTextField(
                  label: 'Nama Kategori Anggaran',
                  hint: 'Contoh: Konsumsi Bulanan',
                  controller: _categoryController,
                ),
              ),

              // Input Total Budget (Index 2)
              AnimatedSlider(
                index: 2,
                child: _buildTextField(
                  label: 'Total Alokasi Anggaran (Rp)',
                  hint: 'Rp 1.000.000',
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CurrencyInputFormatter(),
                  ],
                ),
              ),

              // Label Warna (Index 3)
              const AnimatedSlider(
                index: 3,
                child: Text(
                  'Warna Identitas',
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              // Color Picker (Index 4)
              AnimatedSlider(
                index: 4,
                child: _buildColorPicker(availableColors),
              ),
              const SizedBox(height: 32),

              // Button Submit (Index 5)
              AnimatedSlider(
                index: 5,
                child: _buildSubmitButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    bool isEdit = widget.needs != null;
    return Row(
      children: [
        Icon(
          isEdit ? Icons.edit_note : Icons.account_balance_wallet_outlined, 
          color: AppColors.accentGold,
          size: 28,
        ),
        const SizedBox(width: 12),
        Text(
          isEdit ? 'Ubah Anggaran' : 'Buat Anggaran Baru',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildColorPicker(List<Color> colors) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final color = colors[index];
          bool isSelected = _selectedColor?.value == color.value;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedColor = color;
              _validate();
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 45,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)
                ] : [],
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.black, size: 20) : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isValid ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          disabledBackgroundColor: Colors.white.withOpacity(0.05),
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          widget.needs != null ? 'Simpan Perubahan' : 'Simpan Anggaran',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          cursorColor: AppColors.accentGold,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: AppColors.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14), 
              borderSide: BorderSide.none
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.accentGold, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final int value = int.parse(newValue.text.replaceAll(RegExp(r'[^\d]'), ''));
    final formatter = NumberFormat.decimalPattern('id');
    final String newText = formatter.format(value);
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}