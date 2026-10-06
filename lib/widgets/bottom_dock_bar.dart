import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'liquid_glass.dart';

/// ============================================================================
/// WIDGET: BottomDockBar (Thanh Dock nổi ở đáy màn hình)
/// ============================================================================
/// - Đáp ứng Bonus Challenge của đề bài: Hiển thị bộ đếm thống kê công việc
///   (Total, Done, Left) trong ngày theo thời gian thực.
/// - Đồng thời cung cấp nút bấm tiện ích "+ Add task" kích hoạt mở TaskEditorSheet.
/// ============================================================================
class BottomDockBar extends StatelessWidget {
  final int totalCount;
  final int doneCount;
  final int leftCount;
  final VoidCallback onAddTask;

  const BottomDockBar({
    super.key,
    required this.totalCount,
    required this.doneCount,
    required this.leftCount,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      borderRadius: 28.0,
      blur: 24.0,
      tintColor: const Color(0xFFF2F6FC),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          // 3 ô chỉ số thống kê
          Expanded(
            child: Row(
              children: [
                _buildStatItem('Total', totalCount, AppColors.foreground),
                Container(
                  width: 1,
                  height: 28,
                  color: const Color(0xFFD8E1ED).withValues(alpha: 0.8),
                ),
                _buildStatItem('Done', doneCount, AppColors.checkGreen),
                Container(
                  width: 1,
                  height: 28,
                  color: const Color(0xFFD8E1ED).withValues(alpha: 0.8),
                ),
                _buildStatItem('Left', leftCount, AppColors.primaryBlue),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Nút "+ Add task" dạng viên thuốc Liquid Glass
          InkWell(
            onTap: onAddTask,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF3FC).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF829BB7).withValues(alpha: 0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    size: 18,
                    color: Color(0xFF4F6F9C),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Add task',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F6F9C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color valueColor) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
