import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mitcampus/blocs/task_bloc.dart';
import 'package:mitcampus/models/task.dart';
import 'package:mitcampus/screens/create_task_screen.dart';
import 'package:mitcampus/screens/task_detail_screen.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskBloc()..add(LoadTasksEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tasks', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF2563EB),
          iconTheme: const IconThemeData(color: Colors.white), 
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
            ),
          ),
          child: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TasksLoading) {
                return const Center(child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ));
              } else if (state is TasksLoaded) {
                return state.tasks.isEmpty
                    ? const Center(
                        child: Text('No tasks available',
                          style: TextStyle(color: Colors.white, fontSize: 16)))
                    : RefreshIndicator(
                      onRefresh: () async {
                        context.read<TaskBloc>().add(LoadTasksEvent());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.tasks.length,
                        itemBuilder: (context, index) {
                          final task = state.tasks[index];
                          return TaskListItem(
                            task: task,
                            isHOD: state.currentUser.isHOD,
                            currentUserId: state.currentUser.id,
                          );
                        },
                      ),
                    );
              } else if (state is TaskError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<TaskBloc>().add(LoadTasksEvent()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: Text('Error loading tasks. Please try again later.',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                );
              }
            },
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TasksLoaded && state.currentUser.isHOD) {
                return FloatingActionButton(
                  onPressed: () => _navigateToCreateTask(context),
                  backgroundColor: const Color(0xFF2563EB),
                  child: const Icon(Icons.add, color: Colors.white),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _navigateToCreateTask(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
    );
  }
}

class TaskListItem extends StatelessWidget {
  final Task task;
  final bool isHOD;
  final String currentUserId;

  const TaskListItem({
    super.key,
    required this.task,
    required this.isHOD,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isUserCompleted = task.userCompletions[currentUserId] ?? false;
    final showAsCompleted = isHOD ? task.isFullyCompleted : isUserCompleted;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
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
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getBackgroundColors(isUserCompleted, task.isFullyCompleted),
            ),
          ),
          child: ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: showAsCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deadline: ${_formatDate(task.deadline)}'),
                Text(
                  isHOD 
                    ? 'Status: ${task.isFullyCompleted ? "Completed" : "Pending"}'
                    : 'Your Status: ${isUserCompleted ? "Completed" : "Pending"}',
                  style: TextStyle(
                    color: showAsCompleted ? Colors.green : Colors.orange,
                  ),
                ),
                if (isHOD) Text(
                  'Completed by ${task.userCompletions.values.where((completed) => completed).length}/${task.assignedUsers.length} users',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isHOD && task.assignedUsers.contains(currentUserId))
                  IconButton(
                    icon: Icon(
                      isUserCompleted ? Icons.check_circle : Icons.circle_outlined,
                      color: isUserCompleted ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {
                      final updatedCompletions = Map<String, bool>.from(task.userCompletions);
                      updatedCompletions[currentUserId] = !isUserCompleted;
                      
                      final updatedTask = task.copyWith(
                        userCompletions: updatedCompletions,
                        isCompleted: task.assignedUsers.every(
                          (userId) => updatedCompletions[userId] == true
                        ),
                      );
                      
                      context.read<TaskBloc>().add(UpdateTaskEvent(updatedTask));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isUserCompleted 
                            ? 'Task marked as pending' 
                            : 'Task marked as completed'),
                          backgroundColor: isUserCompleted ? Colors.orange : Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: () => _navigateToTaskDetail(context),
                ),
              ],
            ),
            onTap: () => _navigateToTaskDetail(context),
          ),
        ),
      ),
    );
  }

  List<Color> _getBackgroundColors(bool isUserCompleted, bool isFullyCompleted) {
    if (isHOD) {
      if (isFullyCompleted) {
        return [
          Colors.green.withOpacity(0.3),
          Colors.green.withOpacity(0.2)
        ];
      }
      return [Colors.white, Colors.white];
    } else {
      if (isFullyCompleted) {
        return [
          Colors.green.withOpacity(0.3),
          Colors.green.withOpacity(0.2)
        ];
      } else if (isUserCompleted) {
        return [
          Colors.green.withOpacity(0.15),
          Colors.green.withOpacity(0.05)
        ];
      }
      return [Colors.white, Colors.white];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _navigateToTaskDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task, isHOD: isHOD),
      ),
    );
  }
}
