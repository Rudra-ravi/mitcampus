import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../blocs/task_bloc.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap, required Null Function(bool? newValue) onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (bool? newValue) {
                        if (newValue != null && task.id != null) {
                          context.read<TaskBloc>().add(
                            UpdateTaskStatus(
                              taskId: task.id!,
                              isCompleted: newValue,
                            ),
                          );
                        }
                      },
                    ),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                    ),
                    _buildPriorityIndicator(),
                  ],
                ),
                if (task.description != null && task.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 40),
                    child: Text(
                      task.description!,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 40),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(task.deadline),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${task.assignedUsers.length} assigned',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (task.comments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 40),
                    child: Row(
                      children: [
                        Icon(Icons.comment_outlined, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${task.comments.length} comments',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    final daysUntilDeadline = task.deadline.difference(DateTime.now()).inDays;
    Color priorityColor;
    
    if (daysUntilDeadline < 1) {
      priorityColor = Colors.red;
    } else if (daysUntilDeadline < 3) {
      priorityColor = Colors.orange;
    } else if (daysUntilDeadline < 7) {
      priorityColor = Colors.yellow;
    } else {
      priorityColor = Colors.green;
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: priorityColor,
        shape: BoxShape.circle,
      ),
    );
  }
} 