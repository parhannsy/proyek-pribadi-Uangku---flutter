// lib/presentation/features/arus/widgets/add_arus_form_modal.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:uangku/application/flow/arus_cubit.dart';
import 'package:uangku/application/flow/arus_state.dart'; 
import 'package:uangku/application/debt/debt_cubit.dart';
import 'package:uangku/application/debt/debt_state.dart';
import 'package:uangku/application/needs/needs_cubit.dart';
import 'package:uangku/application/needs/needs_state.dart';

import 'package:uangku/data/models/arus_model.dart';
import 'package:uangku/data/models/debt_model.dart';
import 'package:uangku/data/models/needs_model.dart';
import 'package:uangku/data/models/enums/arus_type.dart' as flow_enum;

import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/presentation/shared/widgets/animated_slider.dart'; 
import 'package:uangku/utils/number_formatter.dart';

class AddArusFormModal extends StatefulWidget {
  const AddArusFormModal({super.key});

  @override
  State<AddArusFormModal> createState() => _AddArusFormModalState();
}

class _AddArusFormModalState extends State<AddArusFormModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); 
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController(); 
  final TextEditingController _timestampController = TextEditingController();
  final TextEditingController _otherDescController = TextEditingController(); // Controller Baru

  late flow_enum.ArusType _selectedType; 
  DateTime? _selectedDate; 
  bool _isFormValid = false; 

  String? _selectedDebtId; 
  String? _selectedNeedId; 
  List<int> _selectedTenorIndexes = []; 
  File? _proofImage;

  final List<String> _expenseCategories = ['Tagihan', 'Anggaran Kebutuhan', 'Lain-lain'];
  final List<String> _incomeCategories = ['Gaji', 'Bisnis', 'Bonus', 'Investasi', 'Lain-lain'];

  @override
  void initState() {
    super.initState();
    _selectedType = flow_enum.ArusType.expense;
    _selectedDate = DateTime.now();
    _timestampController.text = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate!);
    _setupListeners();
    context.read<NeedsCubit>().loadNeeds();
  }

  void _setupListeners() {
    _amountController.addListener(_checkFormValidity);
    _categoryController.addListener(_checkFormValidity);
    _otherDescController.addListener(_checkFormValidity); // Listener Baru
    _amountController.addListener(_formatCurrency);
  }

  void _formatCurrency() {
    if (!mounted) return;
    final String text = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.isNotEmpty) {
      final int value = int.parse(text);
      final String formatted = NumberFormat.decimalPattern('id').format(value);
      if (_amountController.text != formatted) {
        _amountController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  void _checkFormValidity() {
    final String cleanAmount = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
    final bool isBilling = _selectedType == flow_enum.ArusType.expense && _categoryController.text == 'Tagihan';
    final bool isNeed = _selectedType == flow_enum.ArusType.expense && _categoryController.text == 'Anggaran Kebutuhan';
    final bool isOther = _categoryController.text == 'Lain-lain';
    
    bool extraValidation = true;
    if (isBilling) extraValidation = _selectedDebtId != null && _selectedTenorIndexes.isNotEmpty;
    if (isNeed) extraValidation = _selectedNeedId != null;
    if (isOther) extraValidation = _otherDescController.text.trim().length >= 3;

    setState(() {
      _isFormValid = _selectedDate != null &&
          _categoryController.text.isNotEmpty &&
          (int.tryParse(cleanAmount) ?? 0) >= 100 &&
          extraValidation;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _timestampController.dispose();
    _otherDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTagihan = _selectedType == flow_enum.ArusType.expense && _categoryController.text == 'Tagihan';
    final bool isKebutuhan = _selectedType == flow_enum.ArusType.expense && _categoryController.text == 'Anggaran Kebutuhan';
    final bool isOther = _categoryController.text == 'Lain-lain';

    return MultiBlocListener(
      listeners: [
        BlocListener<DebtCubit, DebtState>(
          listener: (context, state) {
            if (state is DebtOperationSuccess) {
              context.read<ArusCubit>().initialize(); 
              Navigator.pop(context);
            }
          },
        ),
        BlocListener<ArusCubit, ArusState>(
          listener: (context, state) {
            if (!state.isLoading && state.failureMessage == null && !isTagihan) {
              Navigator.pop(context);
            }
          },
        ),
      ],
      child: BlocBuilder<NeedsCubit, NeedsState>(
        builder: (context, needsState) {
          return BlocBuilder<DebtCubit, DebtState>(
            builder: (context, debtState) {
              List<DebtModel> activeDebts = (debtState is DebtLoadSuccess) ? debtState.debts : [];
              List<NeedsModel> activeNeeds = [];
              if (needsState is NeedsLoadSuccess) activeNeeds = needsState.needs;
              if (needsState is NeedsOperationSuccess) activeNeeds = needsState.needs;

              final List<Widget> animatedItems = [
                const Text('Transaksi Baru', style: TextStyle(color: AppColors.accentGold, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _buildTypeRadioSelect(),
                const SizedBox(height: 16),
                _buildCategoryDropdown(),
                const SizedBox(height: 16),
                
                // FIELD DYNAMIS: Keterangan untuk "Lain-lain"
                if (isOther) ...[
                  _buildTextField(
                    label: 'Keterangan Lain-lain',
                    hint: 'Contoh: Sedekah, Parkir, dll',
                    controller: _otherDescController,
                    keyboardType: TextInputType.text,
                  ),
                ],

                if (isTagihan) _buildDebtAndTenorSection(activeDebts),
                if (isKebutuhan) _buildNeedsSelectionDropdown(activeNeeds),
                
                _buildTextField(
                  label: 'Nominal Transaksi',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  controller: _amountController,
                  isReadonly: isTagihan, 
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                if ((isTagihan || isKebutuhan || isOther)) 
                  _buildProofOfPaymentInput(),
                _buildTextField(
                  label: 'Waktu Transaksi',
                  hint: 'Pilih Tanggal',
                  icon: Icons.calendar_month,
                  onTap: () => _selectDate(context),
                  controller: _timestampController,
                  isReadonly: true,
                ),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ];

              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: animatedItems.asMap().entries.map((entry) {
                        return AnimatedSlider(index: entry.key, child: entry.value);
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNeedsSelectionDropdown(List<NeedsModel> needs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Kategori Anggaran', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true, 
            fillColor: AppColors.surfaceColor, 
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
          value: _selectedNeedId,
          dropdownColor: AppColors.surfaceColor,
          style: const TextStyle(color: AppColors.textPrimary),
          items: needs.map((n) => DropdownMenuItem(
            value: n.id, 
            child: Text('${n.category} (Sisa: ${NumberFormatter.formatRupiah(n.remainingAmount)})', style: const TextStyle(fontSize: 14))
          )).toList(),
          onChanged: (id) {
            setState(() {
              _selectedNeedId = id;
            });
            _checkFormValidity();
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    final bool isTagihan = _selectedType == flow_enum.ArusType.expense && _categoryController.text == 'Tagihan';
    final bool isKebutuhan = _selectedType == flow_enum.ArusType.expense && _categoryController.text == 'Anggaran Kebutuhan';
    final bool isOther = _categoryController.text == 'Lain-lain';
    
    String? savedImagePath;
    if (_proofImage != null) savedImagePath = await _saveImageLocally(_proofImage!);

    final amountText = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
    final amount = double.tryParse(amountText) ?? 0.0;

    if (isTagihan && _selectedDebtId != null) {
      await context.read<DebtCubit>().payTenor(
        debtId: _selectedDebtId!,
        paymentDate: _selectedDate!,
        imagePath: savedImagePath,
        selectedTenors: _selectedTenorIndexes,
      );
    } else {
      // LOGIC DESKRIPSI: Prioritaskan input manual jika ada
      String desc = isOther && _otherDescController.text.isNotEmpty 
          ? _otherDescController.text 
          : 'Transaksi ${_categoryController.text}';
      
      if (isKebutuhan && _selectedNeedId != null) {
        final needsState = context.read<NeedsCubit>().state;
        List<NeedsModel> needs = [];
        if (needsState is NeedsLoadSuccess) needs = needsState.needs;
        if (needsState is NeedsOperationSuccess) needs = needsState.needs;
        
        final selected = needs.firstWhere((n) => n.id == _selectedNeedId);
        desc = 'Pengeluaran anggaran: ${selected.category}';
      }

      final newArus = Arus(
        type: _selectedType,
        category: _categoryController.text,
        amount: amount,
        description: desc,
        timestamp: _selectedDate!, 
        isRecurring: false,
        imagePath: savedImagePath,
        needId: _selectedNeedId,
      );

      await context.read<ArusCubit>().createNewArus(newArus);
      
      if (isKebutuhan) {
        context.read<NeedsCubit>().loadNeeds();
      }
    }
  }

  Widget _buildTypeRadioSelect() {
    return Row(
      children: flow_enum.ArusType.values.map((t) => Expanded(
        child: RadioListTile<flow_enum.ArusType>(
          contentPadding: EdgeInsets.zero,
          title: Text(t == flow_enum.ArusType.income ? 'Masuk' : 'Keluar', style: const TextStyle(color: Colors.white, fontSize: 14)),
          value: t, groupValue: _selectedType, activeColor: AppColors.accentGold,
          onChanged: (val) => setState(() { 
            _selectedType = val!; 
            _categoryController.clear(); 
            _otherDescController.clear();
            _selectedDebtId = null; 
            _selectedNeedId = null;
            _selectedTenorIndexes = [];
            _amountController.clear();
          }),
        ),
      )).toList(),
    );
  }

  Widget _buildCategoryDropdown() {
    final cats = _selectedType == flow_enum.ArusType.income ? _incomeCategories : _expenseCategories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Kategori', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(filled: true, fillColor: AppColors.surfaceColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
          dropdownColor: AppColors.surfaceColor,
          style: const TextStyle(color: AppColors.textPrimary),
          value: cats.contains(_categoryController.text) ? _categoryController.text : null,
          items: cats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() { 
            _categoryController.text = v!; 
            _otherDescController.clear();
            _selectedDebtId = null;
            _selectedNeedId = null;
            _selectedTenorIndexes = [];
            _amountController.clear();
          }),
        ),
      ],
    );
  }

  Widget _buildDebtAndTenorSection(List<DebtModel> debts) {
    final activeDebts = debts.where((d) => d.remainingTenor > 0).toList();
    if (activeDebts.isEmpty) return const Padding(padding: EdgeInsets.only(bottom: 16), child: Text('Tidak ada hutang aktif', style: TextStyle(color: Colors.redAccent, fontSize: 12)));
    final DebtModel? selectedDebt = activeDebts.firstWhereOrNull((d) => d.id == _selectedDebtId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daftar Hutang Aktif', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(filled: true, fillColor: AppColors.surfaceColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
          value: _selectedDebtId,
          dropdownColor: AppColors.surfaceColor,
          items: activeDebts.map((d) => DropdownMenuItem(value: d.id, child: Text('${d.borrower} - Sisa ${d.remainingTenor}x'))).toList(),
          onChanged: (id) {
            setState(() { _selectedDebtId = id; _selectedTenorIndexes = []; _amountController.clear(); });
            _checkFormValidity();
          },
        ),
        const SizedBox(height: 16),
        if (selectedDebt != null) ...[ _buildTenorSelection(selectedDebt), const SizedBox(height: 16) ],
      ],
    );
  }

  Widget _buildTenorSelection(DebtModel debt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Cicilan (Urut)', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: List.generate(debt.totalTenor, (index) {
            final int tenorNum = index + 1;
            final bool isAlreadyPaid = tenorNum <= (debt.totalTenor - debt.remainingTenor);
            final bool isSelected = _selectedTenorIndexes.contains(tenorNum);
            bool canBeSelected = !isAlreadyPaid && (tenorNum == 1 || (tenorNum > 1 && (tenorNum - 1 <= (debt.totalTenor - debt.remainingTenor) || _selectedTenorIndexes.contains(tenorNum - 1))));
            bool canBeDeselected = !_selectedTenorIndexes.contains(tenorNum + 1);
            return FilterChip(
              label: Text('Bulan $tenorNum'),
              selected: isSelected,
              onSelected: isAlreadyPaid ? null : (bool selected) {
                if (selected && canBeSelected) { setState(() => _selectedTenorIndexes.add(tenorNum)); } 
                else if (!selected && canBeDeselected) { setState(() => _selectedTenorIndexes.remove(tenorNum)); }
                _selectedTenorIndexes.sort();
                final total = debt.amountPerTenor * _selectedTenorIndexes.length;
                _amountController.text = NumberFormat.decimalPattern('id').format(total.toInt());
                _checkFormValidity();
              },
              selectedColor: AppColors.accentGold.withOpacity(0.3),
              checkmarkColor: AppColors.accentGold,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProofOfPaymentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bukti Pembayaran', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Stack(
          children: [
            InkWell(
              onTap: _proofImage == null ? _pickImage : null,
              child: Container(
                height: 140, width: double.infinity,
                decoration: BoxDecoration(color: AppColors.surfaceColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: _proofImage != null ? AppColors.positiveGreen : Colors.white10)),
                child: _proofImage == null 
                  ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, color: Colors.grey), Text('Pilih Bukti Transaksi', style: TextStyle(color: Colors.grey, fontSize: 12))])
                  : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_proofImage!, fit: BoxFit.cover)),
              ),
            ),
            if (_proofImage != null)
              Positioned(top: 8, right: 8, child: GestureDetector(onTap: () => setState(() => _proofImage = null), child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 20)))),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField({required String label, required String hint, TextEditingController? controller, VoidCallback? onTap, bool isReadonly = false, IconData? icon, List<TextInputFormatter>? inputFormatters, TextInputType? keyboardType}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller, readOnly: isReadonly || onTap != null, onTap: onTap,
        style: const TextStyle(color: AppColors.textPrimary),
        inputFormatters: inputFormatters, keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint, filled: true, fillColor: AppColors.surfaceColor, prefixIcon: icon != null ? Icon(icon, color: AppColors.textSecondary) : null, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
      ),
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<ArusCubit, ArusState>(
      builder: (context, arusState) {
        return BlocBuilder<DebtCubit, DebtState>(
          builder: (context, debtState) {
            final isLoading = arusState.isLoading || debtState is DebtOperationInProgress;
            return SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
              onPressed: (isLoading || !_isFormValid) ? null : () => _submitForm(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGold, disabledBackgroundColor: Colors.white10, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Text('Simpan Transaksi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ));
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(context: context, initialDate: _selectedDate ?? now, firstDate: DateTime(2000), lastDate: DateTime(now.year, now.month, now.day + 1));
    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_selectedDate ?? now));
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
          _timestampController.text = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate!);
        });
        _checkFormValidity();
      }
    }
  }

  Future<String?> _saveImageLocally(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String folderPath = p.join(directory.path, 'payments');
      final Directory folder = Directory(folderPath);
      if (!await folder.exists()) await folder.create(recursive: true);
      final String fileName = 'PAY_${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
      final String fullPath = p.join(folderPath, fileName);
      final File localImage = await image.copy(fullPath);
      return localImage.path;
    } catch (e) { return null; }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) setState(() => _proofImage = File(image.path));
    } catch (e) { }
  }
}