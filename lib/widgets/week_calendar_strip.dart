import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../theme/app_colors.dart';
import 'liquid_glass.dart';

/// ============================================================================
/// WIDGET: WeekCalendarStrip (Thanh trượt lịch tuần 7 ngày & Week Preview Accordion)
/// ============================================================================
/// - Cung cấp thanh chọn 7 ngày trong tuần, tự động tính số lượng task cho từng ngày.
/// - Cho phép bấm chuyển tuần trước / tuần sau qua nút mũi tên điều hướng.
/// - TÍNH NĂNG WEEK PREVIEW: Mở rộng / Thu gọn xem trước toàn bộ công việc trong 7 ngày
///   của tuần, highlight ngày đang chọn và hỗ trợ bấm đổi ngày ngay trong preview.
/// ============================================================================
class WeekCalendarStrip extends StatefulWidget {
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

  @override
  State<WeekCalendarStrip> createState() => _WeekCalendarStripState();
}

class _WeekCalendarStripState extends State<WeekCalendarStrip>
    with SingleTickerProviderStateMixin {
  // Trạng thái mở rộng / thu gọn: Mặc định là ĐÓNG (false) khi mới vào app
  bool _showWeekPreview = false;

  late final AnimationController _animController;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _rotateAnimation;

  static const List<String> _shortWeekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    final curved = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );

    _expandAnimation = curved;
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
    // Xoay 180 độ (0.5 turns) khi mở ra
    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(curved);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Chuyển đổi đóng/mở mượt mà, chống lag và chống giật khi click liên tục / spam
  void _toggleWeekPreview() {
    if (_animController.isAnimating) {
      if (_animController.status == AnimationStatus.forward) {
        _animController.reverse();
        setState(() => _showWeekPreview = false);
      } else {
        _animController.forward();
        setState(() => _showWeekPreview = true);
      }
      return;
    }

    if (_showWeekPreview) {
      _animController.reverse();
      setState(() => _showWeekPreview = false);
    } else {
      _animController.forward();
      setState(() => _showWeekPreview = true);
    }
  }

  List<DateTime> get _currentWeekDates {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final startOfWeek = monday.add(Duration(days: widget.weekOffset * 7));

    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _currentWeekDates;
    final middleDate = weekDates[3];
    final monthYearTitle = '${_months[middleDate.month - 1]} ${middleDate.year}';

    final weekTasks = widget.allTasks.where((task) {
      return weekDates.any((d) => task.isOccurringOn(d));
    }).toList();
    final weekTaskCount = weekTasks.length;

    return LiquidGlass(
      borderRadius: 28.0,
      blur: 22.0,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 1. Header: Tháng/Năm & Nút chuyển tuần
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
                    onPressed: () => widget.onWeekOffsetChanged(widget.weekOffset - 1),
                    tooltip: 'Previous week',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => widget.onWeekOffsetChanged(widget.weekOffset + 1),
                    tooltip: 'Next week',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 2. Hàng 7 ngày trong tuần dạng thẻ đứng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final date = weekDates[index];
              final isSelected = _isSameDay(date, widget.selectedDate);
              final taskCount = widget.allTasks.where((t) => t.isOccurringOn(date)).length;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: InkWell(
                    onTap: () => widget.onDateSelected(date),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 86,
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
                            _shortWeekdays[index].toUpperCase(),
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
                            taskCount > 0 ? '$taskCount task${taskCount > 1 ? 's' : ''}' : '—',
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

          const SizedBox(height: 14),

          // 3. Nút bấm Toggle "Week preview · X tasks" (Accordion Header)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleWeekPreview,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          text: 'Week preview',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF425B7C),
                          ),
                          children: [
                            TextSpan(
                              text: ' · $weekTaskCount tasks',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showWeekPreview ? 'Collapse' : 'View',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF58759A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Mũi tên xoay 180 độ chuyển trạng thái mượt mà
                        RotationTransition(
                          turns: _rotateAnimation,
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: Color(0xFF58759A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Danh sách mở rộng 7 ngày của tuần (Weekly task preview accordion content)
          // Animation SizeTransition + FadeTransition: cực nhẹ, mượt mà 60fps, chống lag khi spam click
          ClipRect(
            child: SizeTransition(
              sizeFactor: _expandAnimation,
              alignment: Alignment.topCenter,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildWeekPreviewList(weekDates),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dựng danh sách 7 ngày chi tiết của tuần (theo đúng nguyên mẫu React App.tsx & ảnh đính kèm)
  Widget _buildWeekPreviewList(List<DateTime> weekDates) {
    return Column(
      children: weekDates.map((date) {
        final isSelected = _isSameDay(date, widget.selectedDate);
        final dayTasks = widget.allTasks
            .where((task) => task.isOccurringOn(date))
            .toList();
        dayTasks.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

        final weekdayName = _shortWeekdays[date.weekday - 1];

        return Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => widget.onDateSelected(date),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.65)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected
                      ? Border.all(
                          color: Colors.white.withValues(alpha: 0.90),
                          width: 1.0,
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF3C5078).withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cột trái: Thứ & Ngày
                    SizedBox(
                      width: 44,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weekdayName,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF607E9F),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${date.day}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF28364A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Cột phải: Danh sách task của ngày hoặc "No tasks planned"
                    Expanded(
                      child: dayTasks.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: dayTasks.map((task) {
                                final timeStr =
                                    '${task.startDateTime.hour.toString().padLeft(2, '0')}:${task.startDateTime.minute.toString().padLeft(2, '0')}';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        timeStr,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: task.isCompleted
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF476894),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: task.isCompleted
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF334155),
                                            decoration: task.isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                            decorationColor: const Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            )
                          : const Padding(
                              padding: EdgeInsets.only(top: 2.0),
                              child: Text(
                                'No tasks planned',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
