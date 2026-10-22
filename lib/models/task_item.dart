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

  /// Kiểm tra task có kéo dài qua nhiều ngày khác nhau không (từ 2 ngày trở lên)
  bool get isMultiDay {
    return startDateTime.year != endDateTime.year ||
        startDateTime.month != endDateTime.month ||
        startDateTime.day != endDateTime.day;
  }

  /// Kiểm tra xem task có diễn ra trong ngày `date` hay không.
  /// - Task 1 ngày: chỉ đúng khi `date` trùng đúng ngày của startDateTime.
  /// - Task nhiều ngày: đúng khi `date` nằm trong khoảng từ startDay đến endDay.
  bool isOccurringOn(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    final startDay = DateTime(startDateTime.year, startDateTime.month, startDateTime.day);
    final endDay = DateTime(endDateTime.year, endDateTime.month, endDateTime.day);

    return (target.isAtSameMomentAs(startDay) || target.isAfter(startDay)) &&
           (target.isAtSameMomentAs(endDay) || target.isBefore(endDay));
  }

  /// Số ngày thực tế mà task trải dài (1 ngày, 2 ngày, 3 ngày...)
  int get totalDays {
    final startDay = DateTime(startDateTime.year, startDateTime.month, startDateTime.day);
    final endDay = DateTime(endDateTime.year, endDateTime.month, endDateTime.day);
    return endDay.difference(startDay).inDays + 1;
  }

  /// Chuỗi ngày bắt đầu dạng DD/MM
  String get formattedStartDayMonth =>
      '${startDateTime.day.toString().padLeft(2, '0')}/${startDateTime.month.toString().padLeft(2, '0')}';

  /// Chuỗi ngày kết thúc dạng DD/MM
  String get formattedEndDayMonth =>
      '${endDateTime.day.toString().padLeft(2, '0')}/${endDateTime.month.toString().padLeft(2, '0')}';

  /// Chuỗi hiển thị khoảng ngày (ví dụ: "06/10 — 08/10")
  String get formattedDateRange {
    if (!isMultiDay) return formattedStartDayMonth;
    return '$formattedStartDayMonth — $formattedEndDayMonth';
  }

  /// Chuyển đổi Model sang Map để lưu trên Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Khởi tạo Model từ dữ liệu Document trên Firestore
  factory TaskItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    return TaskItem(
      id: docId ?? (map['id'] as String? ?? ''),
      title: map['title'] as String? ?? '',
      startDateTime: map['startDateTime'] != null
          ? DateTime.parse(map['startDateTime'] as String)
          : DateTime.now(),
      endDateTime: map['endDateTime'] != null
          ? DateTime.parse(map['endDateTime'] as String)
          : DateTime.now(),
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
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

