import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mitcampus/blocs/task_bloc.dart';
import 'package:mitcampus/models/task.dart';
import 'package:mitcampus/screens/create_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  final bool isHOD;

  const TaskDetailScreen({super.key, required this.task, required this.isHOD});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2563EB),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: isHOD ? [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditTask(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDeleteTask(context),
          ),
        ] : null,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildInfoCard(
              title: 'Deadline',
              content: _formatDate(task.deadline),
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Description',
              content: task.description ?? "No description",
              icon: Icons.description,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Status',
              content: task.isCompleted ? 'Completed' : 'Pending',
              icon: task.isCompleted ? Icons.check_circle : Icons.pending,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Assigned Users',
              content: task.assignedUsers.join(", "),
              icon: Icons.people,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const Divider(),
                    ...task.comments.map((comment) => CommentWidget(comment: comment)),
                    AddCommentWidget(taskId: task.id ?? ''),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... Add these new methods ...

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2563EB)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _navigateToEditTask(BuildContext context) {
    // We'll implement this in the next update
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTaskScreen(taskToEdit: task),
      ),
    );
  }

  void _confirmDeleteTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                context.read<TaskBloc>().add(DeleteTaskEvent(task.id!));
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to task list
              },
            ),
          ],
        );
      },
    );
  }
}

class CommentWidget extends StatelessWidget {
  final Comment comment;

  const CommentWidget({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(comment.text),
      subtitle: Text('By: ${comment.userId} at ${comment.timestamp.toString()}'),
    );
  }
}

class AddCommentWidget extends StatefulWidget {
  final String taskId;

  const AddCommentWidget({super.key, required this.taskId});

  @override
  AddCommentWidgetState createState() => AddCommentWidgetState();
}

class AddCommentWidgetState extends State<AddCommentWidget> {
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Add a comment...',
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            if (_commentController.text.isNotEmpty) {
              final comment = Comment(
                userId: 'current_user_id', // Replace with actual user ID
                text: _commentController.text,
                timestamp: DateTime.now(),
              );
              context.read<TaskBloc>().add(AddCommentEvent(widget.taskId, comment));
              _commentController.clear();
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
