import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/task_bloc.dart';
import '../widgets/task_card.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TasksLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is TasksLoaded) {
            if (state.tasks.isEmpty) {
              return const Center(
                child: Text('No tasks available'),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return TaskCard(
                  task: task,
                  onTap: () {
                    // Navigate to task detail screen
                    Navigator.pushNamed(
                      context,
                      '/task-detail',
                      arguments: task,
                    );
                  },
                  onStatusChanged: (bool? newValue) {
                    if (newValue != null) {
                      context.read<TaskBloc>().add(
                        UpdateTaskStatus(
                          taskId: task.id!,
                          isCompleted: newValue,
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
          
          if (state is TaskError) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          }
          
          return const Center(
            child: Text('Something went wrong'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-task');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}