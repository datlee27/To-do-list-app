import 'package:flutter/material.dart';

/// Component: Thanh hiển thị thống kê số lượng task
class TaskStatsBar extends StatelessWidget {
  final int totalCount;
  final int completedCount;
  final int incompleteCount;

  const TaskStatsBar({
    super.key,
    required this.totalCount,
    required this.completedCount,
    required this.incompleteCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: $totalCount',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            'Done: $completedCount',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          ),
          Text(
            'Left: $incompleteCount',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
