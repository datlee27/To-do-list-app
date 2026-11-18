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

  /// Stream dữ liệu công việc thời gian thực cho UI lắng nghe
  Stream<List<TaskItem>> get tasksStream => _tasksController.stream;

  /// Danh sách công việc hiện tại trong bộ nhớ đệm
  List<TaskItem> get currentTasks => List.unmodifiable(_cachedTasks);

  /// Khởi tạo và nạp dữ liệu từ bộ nhớ thiết bị iOS (có cơ chế thử lại để đón UIKit Scene)
  Future<List<TaskItem>> init() async {
    if (_isInitialized) return _cachedTasks;

    for (int attempt = 0; attempt < 5; attempt++) {
      try {
        final String? jsonStr = await _channel.invokeMethod<String>('getTasks');
        if (jsonStr != null) {
          if (jsonStr.isNotEmpty && jsonStr != '[]') {
            final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
            _cachedTasks = decoded
                .map((e) => TaskItem.fromMap(Map<String, dynamic>.from(e as Map)))
                .toList();
          } else {
            _cachedTasks = [];
          }
          _isInitialized = true;
          _tasksController.add(List.from(_cachedTasks));
          return _cachedTasks;
        }
      } catch (e) {
        debugPrint('LocalTaskService init attempt $attempt error: $e');
        if (attempt < 4) {
          await Future.delayed(Duration(milliseconds: 150 * (attempt + 1)));
        }
      }
    }

    _isInitialized = true;
    _tasksController.add(List.from(_cachedTasks));
    return _cachedTasks;
  }

  /// Nạp lại dữ liệu từ Native iOS (khi app resume sau khi Shortcut / Widget đã cập nhật)
  Future<void> reloadFromNative() async {
    try {
      final String? jsonStr = await _channel.invokeMethod<String>('getTasks');
      if (jsonStr != null && jsonStr.isNotEmpty && jsonStr != '[]') {
        final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
        _cachedTasks = decoded
            .map((e) => TaskItem.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        _tasksController.add(List.from(_cachedTasks));
      }
    } catch (e) {
      debugPrint('Error reloading tasks from native: $e');
    }
  }

  /// Thêm mới hoặc Cập nhật một Task
  Future<void> saveTask(TaskItem task) async {
    final index = _cachedTasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _cachedTasks[index] = task;
    } else {
      _cachedTasks.add(task);
    }
    _tasksController.add(List.from(_cachedTasks));
    await _syncToNative();
  }

  /// Đổi trạng thái hoàn thành của Task
  Future<void> toggleTaskComplete(String taskId, bool isCompleted) async {
    final index = _cachedTasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      _cachedTasks[index].isCompleted = isCompleted;
      _tasksController.add(List.from(_cachedTasks));
      await _syncToNative();
    }
  }

  /// Xóa Task khỏi danh sách
  Future<void> deleteTask(String taskId) async {
    _cachedTasks.removeWhere((t) => t.id == taskId);
    _tasksController.add(List.from(_cachedTasks));
    await _syncToNative();
  }

  /// Đồng bộ danh sách công việc sang iOS Native & cập nhật Widget
  Future<void> _syncToNative() async {
    try {
      final List<Map<String, dynamic>> rawList =
          _cachedTasks.map((t) => t.toMap()).toList();
      final String jsonStr = jsonEncode(rawList);
      await _channel.invokeMethod('saveTasks', {'tasksJson': jsonStr});
    } catch (e) {
      debugPrint('Native sync error: $e');
    }
  }

  void dispose() {
    _tasksController.close();
  }
}
