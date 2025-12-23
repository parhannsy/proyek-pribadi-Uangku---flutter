// lib/presentation/shared/widgets/animated_slider.dart (REVISI FINAL UNTUK MENGATASI CURVES.DART ASSERTION)

import 'package:flutter/material.dart';

class AnimatedSlider extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double delayFactor; 
  final int index; 

  const AnimatedSlider({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delayFactor = 0.05, 
    this.index = 0,
  });

  @override
  State<AnimatedSlider> createState() => _AnimatedSliderState();
}

class _AnimatedSliderState extends State<AnimatedSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation; 
  late Animation<double> _fadeAnimation; 

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Hitung penundaan awal
    final double delay = widget.index * widget.delayFactor;
    
    // Durasi relatif dari setiap animasi (misal 60% dari total 1.0)
    const double animationLength = 0.6; 

    final begin = delay; 
    
    // ===================================
    // PERBAIKAN KRITIS: Membatasi nilai 'end' agar tidak melebihi 1.0
    // ===================================
    final double end = (delay + animationLength).clamp(0.0, 1.0);

    // Jika begin sudah > 1.0 (misalnya karena index sangat besar),
    // kita set animasi menjadi instan (sudah selesai).
    if (begin > 1.0) {
      _controller.value = 1.0; 
    } else {
      // 1. Animasi Slide
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0.0, 0.2), 
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            begin, 
            end, 
            curve: Curves.easeOutCubic, 
          ),
        ),
      );

      // 2. Animasi Fade
      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            begin, 
            end, 
            curve: Curves.easeOut,
          ),
        ),
      );

      // Pastikan if (mounted) untuk mencegah error saat Hot Reload/Restart
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) { 
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Jika animasi sudah selesai, tampilkan child tanpa FadeTransition/SlideTransition
    // untuk menghindari overhead (opsional, tapi disarankan)
    if (_controller.value == 1.0) {
      return widget.child;
    }
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}