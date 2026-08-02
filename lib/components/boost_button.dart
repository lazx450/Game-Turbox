import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Tombol Boost utama -- besar, gradient hijau-cyan, dengan animasi pulse
/// halus 60fps memakai `flutter_animate` (dijalankan di compositor thread,
/// tidak membebani UI thread).
class BoostButton extends StatelessWidget {
  final bool isBoosting;
  final VoidCallback onPressed;

  const BoostButton({super.key, required this.isBoosting, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBoosting ? null : onPressed,
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.45),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: isBoosting
              ? const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 4),
                )
              : const Icon(Icons.bolt_rounded, size: 72, color: Colors.black),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            duration: 1400.ms,
            begin: const Offset(1, 1),
            end: const Offset(1.04, 1.04),
            curve: Curves.easeInOut,
          ),
    );
  }
}
