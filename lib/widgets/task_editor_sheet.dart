import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../theme/app_colors.dart';

/// Modal BottomSheet dùng để Thêm mới hoặc Chỉnh sửa Task với hiệu ứng Liquid Glass
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
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endDate = widget.initialDate;
      _endTime = const TimeOfDay(hour: 10, minute: 0);
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
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
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
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      setState(() {
        _errorMessage = 'End date and time must be after the start.';
      });
      return;
    }

    final task = TaskItem(
      id: widget.editingTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      isCompleted: widget.editingTask?.isCompleted ?? false,
      createdAt: widget.editingTask?.createdAt ?? DateTime.now(),
    );

    widget.onSave(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingTask != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEEF3FA).withValues(alpha: 0.88),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
            ),
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top drag handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'A MOMENT OF INTENTION',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEditing ? 'Edit your task' : 'Plan something good',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.foreground,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Field: Task title
                    const Text(
                      'Task title',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'What would you like to do?',
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Give your task a name.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Field: Starts date & time
                    const Text(
                      'Starts',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPickerButton(
                            icon: Icons.calendar_today_outlined,
                            text: '${_startDate.month}/${_startDate.day}/${_startDate.year}',
                            onTap: () => _pickDate(true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPickerButton(
                            icon: Icons.access_time,
                            text: _startTime.format(context),
                            onTap: () => _pickTime(true),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Field: Ends date & time
                    const Text(
                      'Ends',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPickerButton(
                            icon: Icons.calendar_today_outlined,
                            text: '${_endDate.month}/${_endDate.day}/${_endDate.year}',
                            onTap: () => _pickDate(false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPickerButton(
                            icon: Icons.access_time,
                            text: _endTime.format(context),
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

                    // Nút Submit
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _handleSubmit,
                        icon: Icon(
                          isEditing ? Icons.check : Icons.add,
                          color: const Color(0xFF476894),
                        ),
                        label: Text(
                          isEditing ? 'Save changes' : 'Add task',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF476894),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDCE8FA).withValues(alpha: 0.95),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.9)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'A small plan for a more intentional day.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
