import 'package:flutter/material.dart';

/// Bảng màu và Style Glassmorphism chuẩn theo thiết kế Todo Planner
class AppColors {
  // Nền chính và chữ
  static const Color background = Color(0xFFEAF0F8);
  static const Color foreground = Color(0xFF28364A);
  static const Color textMuted = Color(0xFF7589A8);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color dotBlue = Color(0xFF819BBD);

  // Điểm nhấn và Trạng thái
  static const Color primaryBlue = Color(0xFF4E75AD);
  static const Color activeCardText = Color(0xFF4D6D99);
  static const Color checkGreen = Color(0xFF648C78);
  static const Color checkGreenBg = Color(0xFFDCEBE3);
  static const Color timelineNodeActive = Color(0xFF87A4CD);
  static const Color timelineNodeDone = Color(0xFF8BAC9E);

  // Đốm màu nền Gradient Ambient
  static const Color ambientBlue = Color(0xFFDCE7FC);
  static const Color ambientPurple = Color(0xFFE5DEF4);
  static const Color ambientTeal = Color(0xFFD3E8EB);

  // Glassmorphism Decoration Helper
  static BoxDecoration glassDecoration({
    double radius = 24.0,
    Color? bgColor,
    bool hasBorder = true,
  }) {
    return BoxDecoration(
      color: bgColor ?? Colors.white.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(radius),
      border: hasBorder
          ? Border.all(
              color: Colors.white.withValues(alpha: 0.85),
              width: 1.2,
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF3C5078).withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
