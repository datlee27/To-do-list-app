/// Enum đại diện cho các trạng thái bộ lọc của danh sách
enum TaskFilter {
  all,
  active,
  done,
}

/// Model class đại diện cho một đối tượng công việc (Task)
class TaskItem {
  final String id;
  String title;
  DateTime startDateTime;
  DateTime endDateTime;
  bool isCompleted;
  final DateTime createdAt;

  TaskItem({
    required this.id,
    required this.title,
    required this.startDateTime,
    required this.endDateTime,
    this.isCompleted = false,
    required this.createdAt,
  });

  /// Chuỗi ngày dạng YYYY-MM-DD
  String get dateKey =>
      '${startDateTime.year}-${startDateTime.month.toString().padLeft(2, '0')}-${startDateTime.day.toString().padLeft(2, '0')}';

  /// Định dạng giờ bắt đầu HH:mm
  String get formattedStartTime =>
      '${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}';

  /// Định dạng giờ kết thúc HH:mm
  String get formattedEndTime =>
      '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';

  /// Tính toán thời lượng công việc (ví dụ: "2h", "1h 30m", "45m")
  String get durationString {
    final diff = endDateTime.difference(startDateTime);
    final totalMinutes = diff.inMinutes;
    if (totalMinutes <= 0) return '0m';

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Tạo bản sao có chỉnh sửa
  TaskItem copyWith({
    String? title,
    DateTime? startDateTime,
    DateTime? endDateTime,
    bool? isCompleted,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}
