import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/week_calendar_strip.dart';
import '../widgets/task_filter_bar.dart';
import '../widgets/task_timeline_tile.dart';
import '../widgets/bottom_dock_bar.dart';
import '../widgets/task_editor_sheet.dart';

/// ============================================================================
/// SCREEN CHÍNH: Todo Planner (PRM393 Assignment 1)
/// ============================================================================
/// 
/// DÀNH CHO LẬP TRÌNH VIÊN TỪ REACT / REACT NATIVE:
/// 1. Screen này đóng vai trò là "Smart Container Component" (Nguồn dữ liệu duy nhất).
/// 2. Toàn bộ State (tasks, ngày chọn, bộ lọc, sort) được lưu giữ tập trung tại đây.
/// 3. Dữ liệu được truyền xuống các Widget con qua Constructor (tương đương Props).
/// 4. Các Widget con gửi sự kiện lên Screen qua Callbacks (tương đương onPress) 
///    và Screen gọi `setState()` để kích hoạt vẽ lại (Re-render) giao diện.
/// ============================================================================
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // --- 1. KHỞI TẠO STATE (Tương đương các useState() trong React) ---
  late DateTime _selectedDate;             // const [selectedDate, setSelectedDate] = useState(...)
  int _weekOffset = 0;                     // const [weekOffset, setWeekOffset] = useState(0)
  TaskFilter _currentFilter = TaskFilter.all; // const [filter, setFilter] = useState(TaskFilter.all)
  bool _reverseSort = false;               // const [reverse, setReverse] = useState(false)
  late List<TaskItem> _tasks;              // const [tasks, setTasks] = useState([...])

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);

    // Khởi tạo 4 tasks mẫu theo thiết kế App.tsx
    _tasks = [
      TaskItem(
        id: '1',
        title: 'Learn Flutter',
        startDateTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 9, 0),
        endDateTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 11, 0),
        isCompleted: false,
        createdAt: DateTime.now(),
      ),
      TaskItem(
        id: '2',
        title: 'Complete UI assignment',
        startDateTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 11, 30),
        endDateTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 12, 30),
        isCompleted: true,
        createdAt: DateTime.now(),
      ),
      TaskItem(
        id: '3',
        title: 'Read a little, learn a lot',
        startDateTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 14, 0),
        endDateTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 15, 0),
        isCompleted: false,
        createdAt: DateTime.now(),
      ),
      TaskItem(
        id: '4',
        title: 'An evening walk',
        startDateTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 17, 30),
        endDateTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 18, 0),
        isCompleted: false,
        createdAt: DateTime.now(),
      ),
    ];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // --- 2. DỮ LIỆU TÍNH TOÁN (GETTERS - Tương đương useMemo() trong React) ---

  /// Lọc danh sách công việc của ngày đang được chọn (_selectedDate)
  List<TaskItem> get _dayTasks {
    return _tasks.where((t) => _isSameDay(t.startDateTime, _selectedDate)).toList();
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

  // --- 3. CÁC HÀM XỬ LÝ SỰ KIỆN (Tương đương Event Handlers / setState trong React) ---

  /// Đổi trạng thái hoàn thành (Requirement 4 trong đề bài)
  void _toggleComplete(String taskId) {
    setState(() {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      task.isCompleted = !task.isCompleted;
    });
  }

  /// Xóa task khỏi danh sách (Requirement 5 trong đề bài)
  void _deleteTask(String taskId) {
    setState(() {
      _tasks.removeWhere((t) => t.id == taskId);
    });
  }

  /// Thêm mới hoặc Cập nhật task (Requirement 2 & Bonus Edit trong đề bài)
  void _saveTask(TaskItem task) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index >= 0) {
        _tasks[index] = task; // Chỉnh sửa task có sẵn
      } else {
        _tasks.add(task); // Thêm task mới vào danh sách
      }
      // Tự động chuyển lịch sang ngày của task vừa tạo/sửa
      _selectedDate = DateTime(
        task.startDateTime.year,
        task.startDateTime.month,
        task.startDateTime.day,
      );
    });
  }

  /// Mở Modal Form thêm/sửa task
  void _openTaskEditor([TaskItem? task]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TaskEditorSheet(
          editingTask: task,
          initialDate: _selectedDate,
          onSave: _saveTask,
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
                        // 1. App Header
                        AppHeader(
                          selectedDate: _selectedDate,
                          onBackToToday: _backToToday,
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
