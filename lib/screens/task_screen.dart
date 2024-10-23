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
        ),
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TasksLoaded) {
              return ListView.builder(
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return TaskListItem(task: task, isHOD: state.currentUser.isHOD);
                },
              );
            } else if (state is TasksLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: Text('Error loading tasks'));
            }
          },
        ),
        floatingActionButton: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TasksLoaded && state.currentUser.isHOD) {
              return FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
                  );
                },
                backgroundColor: const Color(0xFF2563EB),
                child: const Icon(Icons.add, color: Colors.white),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class TaskListItem extends StatelessWidget {
  final Task task;
  final bool isHOD;

  const TaskListItem({super.key, required this.task, required this.isHOD});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Deadline: ${task.deadline.toString().split(' ')[0]}'),
        trailing: Icon(
          task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
          color: task.isCompleted ? Colors.green : Colors.grey,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task, isHOD: isHOD),
            ),
          );
        },
      ),
    );
  }
}
