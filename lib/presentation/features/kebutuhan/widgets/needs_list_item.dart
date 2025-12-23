// lib/presentation/features/kebutuhan/widgets/needs_list_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangku/application/needs/needs_cubit.dart';
import 'package:uangku/data/models/needs_model.dart';
import 'package:uangku/presentation/shared/theme/app_colors.dart';
import 'package:uangku/utils/number_formatter.dart';

class NeedsListItem extends StatelessWidget {
  final NeedsModel needs;
  final VoidCallback? onTap;
  final VoidCallback? onEdit; 

  const NeedsListItem({
    super.key,
    required this.needs,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(needs.id),
      // MENTOR NOTE: Swipe Kanan ke Kiri = Hapus, Kiri ke Kanan = Edit
      direction: DismissDirection.horizontal, 
      
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // LOGIKA EDIT: Jalankan callback dan gagalkan penghapusan widget
          if (onEdit != null) onEdit!();
          return false; 
        } else {
          // LOGIKA HAPUS: Konfirmasi Dialog
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.surfaceColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Hapus Anggaran?", style: TextStyle(color: Colors.white)),
              content: Text("Apakah Anda yakin ingin menghapus kategori '${needs.category}'?", 
                style: const TextStyle(color: AppColors.textSecondary)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false), 
                  child: const Text("Batal", style: TextStyle(color: Colors.white54))
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true), 
                  child: const Text("Hapus", style: TextStyle(color: AppColors.negativeRed, fontWeight: FontWeight.bold))
                ),
              ],
            ),
          );
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          context.read<NeedsCubit>().deleteNeed(needs.id);
        }
      },
      // BACKGROUND: Swipe Kiri ke Kanan (EDIT)
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.positiveGreen.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.edit_note, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text("Ubah", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      // SECONDARY BACKGROUND: Swipe Kanan ke Kiri (HAPUS)
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.negativeRed.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.delete_sweep, color: Colors.white, size: 28),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildTopInfo(),
              const SizedBox(height: 16),
              _buildProgressBar(),
              const SizedBox(height: 8),
              _buildBottomInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopInfo() {
    bool isOver = needs.percentageUsed >= 1.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: needs.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: needs.color.withOpacity(0.4), blurRadius: 6)
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                needs.category,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Total Alokasi: ${NumberFormatter.formatRupiah(needs.budgetLimit)}",
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${(needs.percentageUsed * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                color: isOver ? AppColors.negativeRed : needs.color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              isOver ? "overlimit" : "terpakai",
              style: TextStyle(
                color: isOver ? AppColors.negativeRed.withOpacity(0.7) : AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    bool isOver = needs.percentageUsed >= 1.0;
    return Stack(
      children: [
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: needs.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        FractionallySizedBox(
          widthFactor: needs.percentageUsed.clamp(0.0, 1.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 8,
            decoration: BoxDecoration(
              color: isOver ? AppColors.negativeRed : needs.color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: (isOver ? AppColors.negativeRed : needs.color).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo() {
    bool isOver = needs.remainingAmount < 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSmallLabel("Terpakai: ${NumberFormatter.formatRupiah(needs.usedAmount)}"),
        _buildSmallLabel(
          isOver 
            ? "Over: ${NumberFormatter.formatRupiah(needs.remainingAmount.abs())}"
            : "Sisa: ${NumberFormatter.formatRupiah(needs.remainingAmount)}",
          color: isOver ? AppColors.negativeRed : AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildSmallLabel(String text, {Color color = AppColors.textSecondary}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11, 
        color: color,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}