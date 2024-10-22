import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mitcampus/blocs/task_bloc.dart';
import 'package:mitcampus/models/task.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskBloc()..add(LoadTasksEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tasks'),
        ),
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TasksLoaded) {
              return ListView.builder(
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return TaskListItem(task: task);
                },
              );
            } else if (state is TasksLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: Text('Error loading tasks'));
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Implement add task functionality
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.title),
      subtitle: Text('Deadline: ${task.deadline.toString()}'),
      trailing: Checkbox(
        value: task.isCompleted,
        onChanged: (value) {
          context.read<TaskBloc>().add(UpdateTaskEvent(task.copyWith(isCompleted: value)));
        },
      ),
      onTap: () {
        // TODO: Implement task detail view
      },
    );
  }
}
