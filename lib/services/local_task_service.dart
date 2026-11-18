import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/task_item.dart';

/// Service quản lý dữ liệu Offline cục bộ kết hợp đồng bộ iOS Native & Widget
class LocalTaskService {
  static final LocalTaskService _instance = LocalTaskService._internal();
  factory LocalTaskService() => _instance;
  LocalTaskService._internal();

  static const MethodChannel _channel =
      MethodChannel('com.example.assignment1TodolistApp/widget');

  final StreamController<List<TaskItem>> _tasksController =
      StreamController<List<TaskItem>>.broadcast();

  List<TaskItem> _cachedTasks = [];
  bool _isInitialized = false;
  Future<List<TaskItem>>? _initFuture;
  Future<void> _syncChain = Future.value();

  /// Stream dữ liệu công việc thời gian thực cho UI lắng nghe
  Stream<List<TaskItem>> get tasksStream => _tasksController.stream;

  /// Danh sách công việc hiện tại trong bộ nhớ đệm
  List<TaskItem> get currentTasks => List.unmodifiable(_clonedTasks());

  List<TaskItem> _clonedTasks() =>
      _cachedTasks.map((t) => t.copyWith()).toList(growable: false);

  void _emitSnapshot() {
    if (!_tasksController.isClosed) {
      _tasksController.add(_clonedTasks());
    }
  }

  /// Khởi tạo và nạp dữ liệu từ bộ nhớ thiết bị iOS (gộp các lần gọi đồng thời & thử lại khi cold start)
  Future<List<TaskItem>> init() {
    if (_isInitialized) return Future.value(_clonedTasks());
    return _initFuture ??= _performInit();
  }

  Future<List<TaskItem>> _performInit() async {
    for (int attempt = 0; attempt < 6; attempt++) {
      try {
        final String? jsonStr = await _channel.invokeMethod<String>('getTasks');
        if (jsonStr != null) {
          if (jsonStr.isNotEmpty) {
            final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
            _cachedTasks = decoded
                .map((e) => TaskItem.fromMap(Map<String, dynamic>.from(e as Map)))
                .toList();
          } else {
            _cachedTasks = [];
          }
          _isInitialized = true;
          _emitSnapshot();
          return _clonedTasks();
        }
      } catch (e) {
        debugPrint('LocalTaskService init attempt $attempt error: $e');
      }
      if (attempt < 5) {
        await Future.delayed(Duration(milliseconds: 100 * (attempt + 1)));
      }
    }

    _isInitialized = true;
    _emitSnapshot();
    return _clonedTasks();
  }

  /// Nạp lại dữ liệu từ Native iOS (khi app resume sau khi tick ngoài Màn hình khóa hoặc Shortcut)
  Future<void> reloadFromNative() async {
    if (!_isInitialized) {
      await init();
    }
    await _syncChain;
    try {
      final String? jsonStr = await _channel.invokeMethod<String>('getTasks');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
        _cachedTasks = decoded
            .map((e) => TaskItem.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        _emitSnapshot();
      }
    } catch (e) {
      debugPrint('Error reloading tasks from native: $e');
    }
  }

  /// Thêm mới hoặc Cập nhật một Task
  Future<void> saveTask(TaskItem task) async {
    if (!_isInitialized) await init();
    final copy = task.copyWith();
    final index = _cachedTasks.indexWhere((t) => t.id == copy.id);
    if (index >= 0) {
      _cachedTasks[index] = copy;
    } else {
      _cachedTasks.add(copy);
    }
    _emitSnapshot();
    await _enqueueSync();
  }

  /// Đổi trạng thái hoàn thành của Task
  Future<void> toggleTaskComplete(String taskId, bool isCompleted) async {
    if (!_isInitialized) await init();
    final index = _cachedTasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      _cachedTasks[index] = _cachedTasks[index].copyWith(isCompleted: isCompleted);
      _emitSnapshot();
      await _enqueueSync();
    }
  }

  /// Xóa Task khỏi danh sách
  Future<void> deleteTask(String taskId) async {
    if (!_isInitialized) await init();
    _cachedTasks.removeWhere((t) => t.id == taskId);
    _emitSnapshot();
    await _enqueueSync();
  }

  /// Hàng đợi ghi tuần tự xuống iOS Native & kích hoạt WidgetKit reload
  Future<void> _enqueueSync() {
    final snapshot = _cachedTasks.map((t) => t.toMap()).toList();
    _syncChain = _syncChain.then((_) async {
      try {
        final String jsonStr = jsonEncode(snapshot);
        await _channel.invokeMethod('saveTasks', {'tasksJson': jsonStr});
      } catch (e) {
        debugPrint('Native sync error: $e');
      }
    });
    return _syncChain;
  }

  /// Đợi toàn bộ thao tác ghi xuống ổ cứng hoàn tất trước khi app vào nền / thoát
  Future<void> flushSync() => _syncChain;

  /// Yêu cầu WidgetKit làm mới giao diện widget
  Future<void> reloadWidgets() async {
    try {
      await _channel.invokeMethod('reloadWidgets');
    } catch (e) {
      debugPrint('Widget reload warning: $e');
    }
  }

  void dispose() {
    _tasksController.close();
  }
}
