import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mitcampus/models/task.dart';
import 'package:mitcampus/repositories/task_repository.dart';

// Events
abstract class TaskEvent {}

class LoadTasksEvent extends TaskEvent {}

class UpdateTaskEvent extends TaskEvent {
  final Task task;
  UpdateTaskEvent(this.task);
}

// States
abstract class TaskState {}

class TasksLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  TasksLoaded(this.tasks);
}

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository = TaskRepository();

  TaskBloc() : super(TasksLoading()) {
    on<LoadTasksEvent>((event, emit) async {
      emit(TasksLoading());
      try {
        final tasks = await _taskRepository.getTasks();
        emit(TasksLoaded(tasks));
      } catch (e) {
        // Handle error
      }
    });

    on<UpdateTaskEvent>((event, emit) async {
      if (state is TasksLoaded) {
        final currentTasks = (state as TasksLoaded).tasks;
        final updatedTasks = currentTasks.map((task) {
          return task.id == event.task.id ? event.task : task;
        }).toList();
        emit(TasksLoaded(updatedTasks));
        await _taskRepository.updateTask(event.task);
      }
    });
  }
}
