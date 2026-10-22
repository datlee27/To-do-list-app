import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_item.dart';

/// Service quản lý Lưu trữ dữ liệu Todo trên Cloud Firestore
/// Mỗi User có 1 subcollection riêng biệt: users/{userId}/tasks
class FirestoreService {
  // Singleton pattern
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Tham chiếu tới collection tasks của một người dùng cụ thể
  CollectionReference<Map<String, dynamic>>? _tasksCollection(String userId) {
    return _db?.collection('users').doc(userId).collection('tasks');
  }

  /// Lắng nghe dữ liệu Todo thời gian thực (Real-time Stream)
  /// Tự động cập nhật giao diện bất cứ khi nào có thay đổi trên Firestore
  Stream<List<TaskItem>> getTasksStream(String userId) {
    final col = _tasksCollection(userId);
    if (col == null) return const Stream.empty();
    return col
        .orderBy('startDateTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskItem.fromMap(doc.data(), docId: doc.id);
      }).toList();
    });
  }

  /// Thêm mới hoặc Cập nhật một Task
  Future<void> saveTask(String userId, TaskItem task) async {
    try {
      final col = _tasksCollection(userId);
      if (col == null) return;
      final docRef = col.doc(task.id);
      await docRef.set(task.toMap(), SetOptions(merge: true));
    } catch (e) {
      // Gracefully handle network/offline issues
    }
  }

  /// Đổi trạng thái hoàn thành của Task
  Future<void> toggleTaskComplete(
    String userId,
    String taskId,
    bool isCompleted,
  ) async {
    try {
      final col = _tasksCollection(userId);
      if (col == null) return;
      await col.doc(taskId).set({
        'isCompleted': isCompleted,
      }, SetOptions(merge: true));
    } catch (e) {
      // Gracefully handle network/offline issues
    }
  }

  /// Xóa Task khỏi Firestore
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      final col = _tasksCollection(userId);
      if (col == null) return;
      await col.doc(taskId).delete();
    } catch (e) {
      // Gracefully handle network/offline issues
    }
  }
}
