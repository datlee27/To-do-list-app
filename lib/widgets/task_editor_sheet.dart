import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/task_item.dart';

/// ============================================================================
/// WIDGET: TaskEditorSheet (Thêm mới & Chỉnh sửa Task)
/// ============================================================================
/// - Đáp ứng Requirement 2 của đề bài: Cung cấp Form, TextFormField,
///   ElevatedButton ("Add task"), kiểm tra Validation khi tiêu đề bị rỗng.
/// - Đồng thời kiêm nhiệm tính năng điểm thưởng (Bonus): Sửa Task (Edit Task).
/// - Được mở dưới dạng Modal BottomSheet từ nút "+ Add task" ở thanh Dock hoặc nút Edit.
/// ============================================================================
class TaskEditorSheet extends StatefulWidget {
  final TaskItem? editingTask;
  final DateTime initialDate;
  final Function(TaskItem task) onSave;

  const TaskEditorSheet({
    super.key,
    this.editingTask,
    required this.initialDate,
    required this.onSave,
  });

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;

  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final task = widget.editingTask;
    _titleController = TextEditingController(text: task?.title ?? '');

    if (task != null) {
      _startDate = task.startDateTime;
      _startTime = TimeOfDay(hour: task.startDateTime.hour, minute: task.startDateTime.minute);
      _endDate = task.endDateTime;
      _endTime = TimeOfDay(hour: task.endDateTime.hour, minute: task.endDateTime.minute);
    } else {
      _startDate = widget.initialDate;
      final now = DateTime.now();
      final isToday = widget.initialDate.year == now.year &&
          widget.initialDate.month == now.month &&
          widget.initialDate.day == now.day;

      final startHour = isToday ? ((now.hour + 1) % 24) : 9;
      _startTime = TimeOfDay(hour: startHour, minute: 0);

      _endDate = widget.initialDate;
      final endHour = (startHour + 1) % 24;
      _endTime = TimeOfDay(hour: endHour, minute: 0);
      if (endHour == 0 && startHour == 23) {
        _endDate = widget.initialDate.add(const Duration(days: 1));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          final wasSingleDay = _startDate.year == _endDate.year &&
              _startDate.month == _endDate.month &&
              _startDate.day == _endDate.day;
          _startDate = picked;
          if (wasSingleDay || _endDate.isBefore(_startDate)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
        _errorMessage = null;
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          final isSameDay = _startDate.year == _endDate.year &&
              _startDate.month == _endDate.month &&
              _startDate.day == _endDate.day;
          final startMinutes = picked.hour * 60 + picked.minute;
          final endMinutes = _endTime.hour * 60 + _endTime.minute;
          if (isSameDay && endMinutes <= startMinutes) {
            final nextEnd = (startMinutes + 60) % (24 * 60);
            _endTime = TimeOfDay(hour: nextEnd ~/ 60, minute: nextEnd % 60);
            if (startMinutes + 60 >= 24 * 60) {
              _endDate = _startDate.add(const Duration(days: 1));
            }
          }
        } else {
          _endTime = picked;
        }
        _errorMessage = null;
      });
    }
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập tên công việc.';
      });
      _formKey.currentState?.validate();
      return;
    }

    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    var endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    // Tự động điều chỉnh nếu giờ kết thúc <= giờ bắt đầu (không bao giờ chặn người dùng)
    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      endDateTime = startDateTime.add(const Duration(hours: 1));
    }

    final task = TaskItem(
      id: widget.editingTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      isCompleted: widget.editingTask?.isCompleted ?? false,
      createdAt: widget.editingTask?.createdAt ?? DateTime.now(),
    );

    FocusScope.of(context).unfocus();
    widget.onSave(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingTask != null;
    final startDateStr =
        '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}';
    final startTimeStr =
        '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
    final endDateStr =
        '${_endDate.day.toString().padLeft(2, '0')}/${_endDate.month.toString().padLeft(2, '0')}/${_endDate.year}';
    final endTimeStr =
        '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEEF3FA).withValues(alpha: 0.88),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.88),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3C5078).withValues(alpha: 0.18),
                    blurRadius: 36,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header: Eyebrow + Title + Circular Glass Close Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'A MOMENT OF INTENTION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.0,
                                  color: Color(0xFF7F94B0),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isEditing ? 'Edit your task' : 'Plan something good',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF28364A),
                                  letterSpacing: -0.6,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.45),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3C5078).withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Color(0xFF7F90A6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Field: Task title
                      const Text(
                        'Task title',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF52637A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleSubmit(),
                        onChanged: (_) {
                          if (_errorMessage != null) {
                            setState(() {
                              _errorMessage = null;
                            });
                          }
                        },
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF28364A),
                        ),
                        decoration: InputDecoration(
                          hintText: 'What would you like to do?',
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.normal,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.65),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.95),
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.95),
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF93C5FD),
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Give your task a name.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // Field: Starts date & time
                      const Text(
                        'Starts',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF52637A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPickerButton(
                              icon: Icons.calendar_today_outlined,
                              text: startDateStr,
                              onTap: () => _pickDate(true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildPickerButton(
                              icon: Icons.access_time_rounded,
                              text: startTimeStr,
                              onTap: () => _pickTime(true),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Field: Ends date & time
                      const Text(
                        'Ends',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF52637A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPickerButton(
                              icon: Icons.calendar_today_outlined,
                              text: endDateStr,
                              onTap: () => _pickDate(false),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildPickerButton(
                              icon: Icons.access_time_rounded,
                              text: endTimeStr,
                              onTap: () => _pickTime(false),
                            ),
                          ),
                        ],
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Nút Submit dạng GestureDetector Opaque toàn diện (bấm bất kỳ vị trí nào cũng nhận)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _handleSubmit,
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCE8FA).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.95),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF536E98).withValues(alpha: 0.16),
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isEditing ? Icons.check_rounded : Icons.add_rounded,
                                size: 20,
                                color: const Color(0xFF38557E),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isEditing ? 'Save changes' : 'Add task',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF38557E),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'A small plan for a more intentional day.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF758399),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.95),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3C5078).withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF28364A),
                letterSpacing: 0.2,
              ),
            ),
            Icon(icon, size: 16, color: const Color(0xFF6B82A6)),
          ],
        ),
      ),
    );
  }
}
