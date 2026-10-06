import 'dart:ui';
import 'package:flutter/material.dart';

/// ============================================================================
/// WIDGET: LiquidGlass (Khối kính lỏng quang học)
/// ============================================================================
/// - Sử dụng BackdropFilter & ImageFilter.blur để làm mờ khúc xạ thời gian thực
///   các thành phần giao diện trôi bên dưới khi người dùng cuộn danh sách.
/// - Kết hợp viền sáng phản quang (Specular Highlight Border) và dải chuyển màu mờ
///   để tạo cảm giác tấm kính cong chuẩn phong cách iOS / uilayouts.
/// ============================================================================
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color? tintColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Border? customBorder;

  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = 26.0,
    this.blur = 18.0,
    this.tintColor,
    this.padding,
    this.margin,
    this.onTap,
    this.width,
    this.height,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Đổ bóng khuếch tán mềm (Soft Ambient Shadow)
          BoxShadow(
            color: const Color(0xFF3C5078).withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
          // Đổ bóng sắc cạnh nhẹ (Sharp Accent Shadow)
          BoxShadow(
            color: const Color(0xFF8BA9D6).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              // Dải màu kính chuyển sắc tạo chiều sâu chất lỏng
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (tintColor ?? Colors.white).withValues(alpha: 0.70),
                  (tintColor ?? Colors.white).withValues(alpha: 0.35),
                  (tintColor ?? Colors.white).withValues(alpha: 0.15),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
              // Viền khúc xạ ánh sáng (Specular Highlight Border)
              border: customBorder ??
                  Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 1.4,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return content;
  }
}
