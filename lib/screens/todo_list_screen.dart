import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/task_item.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/week_calendar_strip.dart';
import '../widgets/task_filter_bar.dart';
import '../widgets/task_timeline_tile.dart';
import '../widgets/bottom_dock_bar.dart';
import '../widgets/task_editor_sheet.dart';
import 'login_screen.dart';


/// ============================================================================
/// SCREEN CHÍNH: Todo Planner (PRM393 Assignment 1 & 2)
/// ============================================================================
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // --- 1. KHỞI TẠO STATE ---
  late DateTime _selectedDate;
  int _weekOffset = 0;
  TaskFilter _currentFilter = TaskFilter.all;
  bool _reverseSort = false;
  late List<TaskItem> _tasks;

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<TaskItem>>? _taskSubscription;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _selectedDate = today;
    // Bắt đầu danh sách trống (không dùng mock tasks)
    _tasks = [];

    // Kết nối dữ liệu Cloud Firestore theo User ID của người dùng đã đăng nhập Google
    final user = _authService.currentUser;
    if (user != null) {
      _taskSubscription = _firestoreService.getTasksStream(user.uid).listen(
        (tasks) {
          if (mounted) {
            setState(() {
              _tasks = tasks;
            });
          }
        },
        onError: (e) {
          debugPrint('Firestore stream error: $e');
        },
      );
    }
  }


  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }


  // --- 2. DỮ LIỆU TÍNH TOÁN (GETTERS - Tương đương useMemo() trong React) ---

  /// Lọc danh sách công việc diễn ra trong ngày đang được chọn (_selectedDate):
  /// - Task 1 ngày: CHỈ xuất hiện đúng vào ngày đã set, không di chuyển sang ngày khác.
  /// - Task nhiều ngày: xuất hiện trên tất cả các ngày từ startDay đến endDay.
  List<TaskItem> get _dayTasks {
    return _tasks
        .where((t) => t.isOccurringOn(_selectedDate))
        .toList();
  }

  /// Lọc tiếp theo bộ lọc (All, Active, Done) và sắp xếp theo thời gian
  List<TaskItem> get _visibleTasks {
    final dayList = _dayTasks;
    List<TaskItem> filtered;
    switch (_currentFilter) {
      case TaskFilter.active:
        filtered = dayList.where((t) => !t.isCompleted).toList();
      case TaskFilter.done:
        filtered = dayList.where((t) => t.isCompleted).toList();
      case TaskFilter.all:
        filtered = List.from(dayList);
    }

    filtered.sort((a, b) {
      final cmp = a.startDateTime.compareTo(b.startDateTime);
      return _reverseSort ? -cmp : cmp;
    });

    return filtered;
  }

  // --- 3. CÁC HÀM XỬ LÝ SỰ KIỆN (Tương đương Event Handlers) ---

  /// Đổi trạng thái hoàn thành (Sync Firestore)
  void _toggleComplete(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index < 0) return;

    final newStatus = !_tasks[index].isCompleted;
    setState(() {
      _tasks[index].isCompleted = newStatus;
    });

    final user = _authService.currentUser;
    if (user != null) {
      _firestoreService.toggleTaskComplete(user.uid, taskId, newStatus);
    }
  }

  /// Xóa task khỏi danh sách (Sync Firestore)
  void _deleteTask(String taskId) {
    setState(() {
      _tasks.removeWhere((t) => t.id == taskId);
    });

    final user = _authService.currentUser;
    if (user != null) {
      _firestoreService.deleteTask(user.uid, taskId);
    }
  }

  /// Thêm mới hoặc Cập nhật task (Sync Firestore)
  void _saveTask(TaskItem task) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index >= 0) {
        _tasks[index] = task; // Chỉnh sửa task có sẵn
      } else {
        _tasks.add(task); // Thêm task mới vào danh sách
      }
      _selectedDate = DateTime(
        task.startDateTime.year,
        task.startDateTime.month,
        task.startDateTime.day,
      );
    });

    final user = _authService.currentUser;
    if (user != null) {
      _firestoreService.saveTask(user.uid, task);
    }
  }

  /// Đăng xuất khỏi hệ thống
  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }



  /// Mở Modal Form thêm/sửa task kèm hiệu ứng Backdrop Blur toàn màn hình phía sau chuẩn Hình 1
  void _openTaskEditor([TaskItem? task]) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close task form',
      barrierColor: const Color(0xFF3B4E6A).withValues(alpha: 0.18),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: TaskEditorSheet(
              editingTask: task,
              initialDate: _selectedDate,
              onSave: _saveTask,
            ),
          ),
        );
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14.0 * curved.value,
            sigmaY: 14.0 * curved.value,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.35),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: curved,
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Quay về ngày hôm nay
  void _backToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
      _weekOffset = 0;
    });
  }

  // --- 4. HÀM DỰNG GIAO DIỆN (Tương đương return (<View>...) trong React Native) ---
  @override
  Widget build(BuildContext context) {
    final dayTasks = _dayTasks;
    final totalCount = dayTasks.length;
    final doneCount = dayTasks.where((t) => t.isCompleted).length;
    final leftCount = totalCount - doneCount;
    final visibleTasks = _visibleTasks;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Nền Ambient Blurs (Đốm sáng chuyển màu lỏng đa sắc)
          Positioned(
            left: -100,
            top: -120,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.ambientBlue.withValues(alpha: 0.9),
                    AppColors.ambientBlue.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -80,
            top: 140,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.ambientPurple.withValues(alpha: 0.75),
                    AppColors.ambientPurple.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 60,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.ambientTeal.withValues(alpha: 0.75),
                    AppColors.ambientTeal.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Nội dung chính căn giữa
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Stack(
                  children: [
                    // Danh sách cuộn chứa tất cả các phần tử
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                      children: [
                        // 1. App Header (Header & User Profile / Logout)
                        AppHeader(
                          selectedDate: _selectedDate,
                          onBackToToday: _backToToday,
                          onLogout: _handleLogout,
                        ),

                        const SizedBox(height: 20),

                        // 2. Week Calendar Strip
                        WeekCalendarStrip(
                          selectedDate: _selectedDate,
                          weekOffset: _weekOffset,
                          allTasks: _tasks,
                          onDateSelected: (date) {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                          onWeekOffsetChanged: (offset) {
                            setState(() {
                              _weekOffset = offset;
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        // 3. Filter Bar (Today title, All/Active/Done pills, Sort)
                        TaskFilterBar(
                          selectedDate: _selectedDate,
                          currentFilter: _currentFilter,
                          isReversed: _reverseSort,
                          onFilterChanged: (filter) {
                            setState(() {
                              _currentFilter = filter;
                            });
                          },
                          onToggleSort: () {
                            setState(() {
                              _reverseSort = !_reverseSort;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // 4. Task Timeline List
                        if (visibleTasks.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.task_alt,
                                    size: 36,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'No tasks planned for this day.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Tap "+ Add task" below to begin.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...List.generate(visibleTasks.length, (index) {
                            final task = visibleTasks[index];
                            final isLast = index == visibleTasks.length - 1;
                            return TaskTimelineTile(
                              task: task,
                              isLast: isLast,
                              onToggleComplete: () => _toggleComplete(task.id),
                              onEdit: () => _openTaskEditor(task),
                              onDelete: () => _deleteTask(task.id),
                            );
                          }),

                        if (visibleTasks.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Center(
                            child: Text(
                              "That's your day. Make it yours.",
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // 5. Thanh Dock nổi ở đáy (Fixed Bottom Dock)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 12,
                      child: BottomDockBar(
                        totalCount: totalCount,
                        doneCount: doneCount,
                        leftCount: leftCount,
                        onAddTask: () => _openTaskEditor(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
