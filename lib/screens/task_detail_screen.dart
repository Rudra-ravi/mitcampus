import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mitcampus/blocs/task_bloc.dart';
import 'package:mitcampus/models/task.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  final bool isHOD;

  const TaskDetailScreen({super.key, required this.task, required this.isHOD});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
        actions: isHOD
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Navigate to edit task screen
                  },
                ),
              ]
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('Deadline: ${task.deadline.toString()}'),
          const SizedBox(height: 8),
          Text('Description: ${task.description ?? "No description"}'),
          const SizedBox(height: 16),
          Text('Assigned Users: ${task.assignedUsers.join(", ")}'),
          const SizedBox(height: 16),
          const Text('Comments:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...task.comments.map((comment) => CommentWidget(comment: comment)),
          const SizedBox(height: 16),
          AddCommentWidget(taskId: task.id ?? ''),
        ],
      ),
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
