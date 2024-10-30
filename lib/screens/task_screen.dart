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

  const TaskListItem({
    super.key,
    required this.task,
    required this.isHOD,
  });

  @override
  Widget build(BuildContext context) {
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
              colors: task.isCompleted 
                  ? [Colors.green.withOpacity(0.15), Colors.green.withOpacity(0.05)]
                  : [Colors.white, Colors.white],
            ),
          ),
          child: ListTile(
            title: Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deadline: ${_formatDate(task.deadline)}'),
                Text(
                  'Status: ${task.isCompleted ? "Completed" : "Pending"}',
                  style: TextStyle(
                    color: task.isCompleted ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isHOD)
                  IconButton(
                    icon: Icon(
                      task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                      color: task.isCompleted ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {
                      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
                      context.read<TaskBloc>().add(UpdateTaskEvent(updatedTask));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(task.isCompleted 
                              ? 'Task marked as pending' 
                              : 'Task marked as completed'),
                          backgroundColor: task.isCompleted ? Colors.orange : Colors.green,
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
