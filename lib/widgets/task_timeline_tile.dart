import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../theme/app_colors.dart';
import 'liquid_glass.dart';

/// Component: Đại diện cho một thẻ Task trên trục Timeline với hiệu ứng Liquid Glass
class TaskTimelineTile extends StatelessWidget {
  final TaskItem task;
  final bool isLast;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskTimelineTile({
    super.key,
    required this.task,
    this.isLast = false,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Trục đường kẻ dọc timeline chạy dọc theo chiều cao tự nhiên của thẻ
        if (!isLast)
          Positioned(
            left: 25.25, // Căn giữa cột 52px: (52 - 1.5) / 2
            top: 48.0, // Bắt đầu ngay dưới nốt tròn timeline
            bottom: 0.0, // Kéo dài dọc theo chiều cao tự nhiên của thẻ
            child: Container(
              width: 1.5,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),

        // 2. Nội dung hiển thị co dãn tự nhiên 100%, không bị ép chặt chiều cao
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cột 1: Trục thời gian (Timeline Axis)
            SizedBox(
              width: 52,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 18),
                  // Giờ bắt đầu
                  Text(
                    task.formattedStartTime,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Nốt tròn timeline
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? AppColors.timelineNodeDone
                          : AppColors.timelineNodeActive,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Cột 2: Thẻ Task kính quang học (Liquid Glass Card)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: LiquidGlass(
                  borderRadius: 22.0,
                  blur: 16.0,
                  tintColor: task.isCompleted
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Hàng 1: Nút hoàn thành + Tên task + Nút Sửa/Xóa
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nút Toggle Complete
                        InkWell(
                          onTap: onToggleComplete,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: task.isCompleted
                                  ? AppColors.checkGreenBg
                                  : Colors.white.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: task.isCompleted
                                    ? AppColors.checkGreen
                                    : const Color(0xFFA4B4C9),
                                width: 1.5,
                              ),
                            ),
                            child: task.isCompleted
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppColors.checkGreen,
                                  )
                                : null,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Tiêu đề Task
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: task.isCompleted
                                  ? AppColors.textSecondary
                                  : AppColors.foreground,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: AppColors.textMuted,
                            ),
                          ),
                        ),

                        // Action Buttons: Sửa & Xóa
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 17),
                              color: AppColors.textSecondary,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Edit task',
                              onPressed: onEdit,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              color: Colors.redAccent.withValues(alpha: 0.75),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Delete task',
                              onPressed: onDelete,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Hàng 2: Thời gian bắt đầu - kết thúc + Badge thời lượng
                    Padding(
                      padding: const EdgeInsets.only(left: 38.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    '${task.formattedStartTime} — ${task.formattedEndTime}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Badge: Thời lượng hoặc Đã hoàn thành
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: task.isCompleted
                                  ? AppColors.checkGreenBg.withValues(alpha: 0.8)
                                  : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            child: Text(
                              task.isCompleted
                                  ? '✓ Completed'
                                  : task.durationString,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: task.isCompleted
                                    ? AppColors.checkGreen
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
  }
}
