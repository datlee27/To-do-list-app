import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../theme/app_colors.dart';

/// Component: Thanh tiêu đề ngày + 3 Tab bộ lọc (All, Active, Done) + Nút đảo chiều sắp xếp
class TaskFilterBar extends StatelessWidget {
  final DateTime selectedDate;
  final TaskFilter currentFilter;
  final bool isReversed;
  final ValueChanged<TaskFilter> onFilterChanged;
  final VoidCallback onToggleSort;

  const TaskFilterBar({
    super.key,
    required this.selectedDate,
    required this.currentFilter,
    required this.isReversed,
    required this.onFilterChanged,
    required this.onToggleSort,
  });

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ];

  bool get _isToday {
    final now = DateTime.now();
    return now.year == selectedDate.year &&
        now.month == selectedDate.month &&
        now.day == selectedDate.day;
  }

  @override
  Widget build(BuildContext context) {
    final dayTitle = _isToday ? 'Today' : _weekdays[selectedDate.weekday - 1];
    final dateSubtitle = '${_months[selectedDate.month - 1]} ${selectedDate.day}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 10,
        children: [
          // Tiêu đề ngày
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                dayTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dateSubtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Bộ lọc thuốc (All, Active, Done) + Nút Sort
          Row(
            children: [
              // 3 Tab Pills
              Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                ),
                child: Row(
                  children: [
                    _buildPillTab('All', TaskFilter.all),
                    _buildPillTab('Active', TaskFilter.active),
                    _buildPillTab('Done', TaskFilter.done),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Nút đảo chiều sắp xếp (Sort)
              InkWell(
                onTap: onToggleSort,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                  child: Icon(
                    Icons.swap_vert,
                    size: 18,
                    color: isReversed ? Colors.blueAccent : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillTab(String label, TaskFilter filter) {
    final isSelected = currentFilter == filter;
    return InkWell(
      onTap: () => onFilterChanged(filter),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.activeCardText : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
