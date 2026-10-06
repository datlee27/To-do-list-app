import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../theme/app_colors.dart';
import 'liquid_glass.dart';

/// Component: Dải lịch tuần tương tác (7 ngày) theo phong cách Liquid Glass
class WeekCalendarStrip extends StatelessWidget {
  final DateTime selectedDate;
  final int weekOffset;
  final List<TaskItem> allTasks;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<int> onWeekOffsetChanged;

  const WeekCalendarStrip({
    super.key,
    required this.selectedDate,
    required this.weekOffset,
    required this.allTasks,
    required this.onDateSelected,
    required this.onWeekOffsetChanged,
  });

  static const List<String> _shortWeekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  List<DateTime> get _currentWeekDates {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final startOfWeek = monday.add(Duration(days: weekOffset * 7));

    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _currentWeekDates;
    final middleDate = weekDates[3];
    final monthYearTitle = '${_months[middleDate.month - 1]} ${middleDate.year}';

    final weekTaskCount = allTasks.where((task) {
      return weekDates.any((d) => _isSameDay(d, task.startDateTime));
    }).length;

    return LiquidGlass(
      borderRadius: 28.0,
      blur: 22.0,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header: Tháng/Năm & Nút chuyển tuần
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthYearTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => onWeekOffsetChanged(weekOffset - 1),
                    tooltip: 'Previous week',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => onWeekOffsetChanged(weekOffset + 1),
                    tooltip: 'Next week',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Hàng 7 ngày trong tuần
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final date = weekDates[index];
              final isSelected = _isSameDay(date, selectedDate);
              final dayKey = _dateKey(date);
              final taskCount = allTasks.where((t) => t.dateKey == dayKey).length;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: InkWell(
                    onTap: () => onDateSelected(date),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 82,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.92)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 1.5)
                            : Border.all(color: Colors.transparent),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.22),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _shortWeekdays[index],
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : AppColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.foreground
                                  : AppColors.foreground.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            taskCount > 0 ? '$taskCount tasks' : '—',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : (taskCount > 0
                                      ? AppColors.primaryBlue.withValues(alpha: 0.8)
                                      : AppColors.textMuted.withValues(alpha: 0.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Thanh tóm tắt tuần kính mờ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        'Week preview',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.activeCardText,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '• $weekTaskCount tasks',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_shortWeekdays[selectedDate.weekday - 1]} ${selectedDate.day}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
