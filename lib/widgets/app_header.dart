import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'liquid_glass.dart';

/// Component: Header trên cùng của ứng dụng theo phong cách Liquid Glass
class AppHeader extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onBackToToday;

  const AppHeader({
    super.key,
    required this.selectedDate,
    required this.onBackToToday,
  });

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ];

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final weekdayName = _weekdays[selectedDate.weekday - 1];
    final monthName = _months[selectedDate.month - 1];
    final dateSubtitle = '$weekdayName, $monthName ${selectedDate.day}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Pill Header dạng Liquid Glass
        LiquidGlass(
          borderRadius: 26.0,
          blur: 20.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo check box + Tiêu đề
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Todo Planner',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.foreground,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Nút "Back to today" dạng Liquid Glass nhỏ
              LiquidGlass(
                borderRadius: 20.0,
                blur: 14.0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onTap: onBackToToday,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Hero Typography Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YOUR DAILY TASKS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: const TextSpan(
                  text: 'Todo List',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                    letterSpacing: -0.8,
                  ),
                  children: [
                    TextSpan(
                      text: '.',
                      style: TextStyle(
                        color: AppColors.dotBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Plan, organize, and complete your tasks.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
