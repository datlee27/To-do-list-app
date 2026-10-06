import 'package:flutter/material.dart';
import '../models/task_item.dart';

/// Component: Đại diện cho một thẻ Task (ListTile) trong ListView
class TaskItemTile extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskItemTile({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 4.0,
      ),
      elevation: task.isCompleted ? 0.5 : 1.5,
      child: ListTile(
        // Complete Button (Toggle completion)
        leading: IconButton(
          icon: Icon(
            task.isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: task.isCompleted ? Colors.green : Colors.grey,
          ),
          tooltip: task.isCompleted
              ? 'Mark as incomplete'
              : 'Mark as complete',
          onPressed: onToggleComplete,
        ),
        // Task Title with completion styling (strikethrough & color change)
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 16,
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: task.isCompleted
                ? Colors.grey
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        // Subtitle: Creation time
        subtitle: Text(
          'Created: ${task.createdAt.hour.toString().padLeft(2, '0')}:${task.createdAt.minute.toString().padLeft(2, '0')}:${task.createdAt.second.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        // Action buttons: Edit and Delete
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit Button
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit task',
              onPressed: onEdit,
            ),
            // Delete Button (Remove immediately)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              tooltip: 'Delete task',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
