import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mitcampus/models/task.dart';
import 'package:mitcampus/models/user.dart';
import 'package:mitcampus/repositories/task_repository.dart';
import 'package:mitcampus/repositories/user_repository.dart';

// Events
abstract class TaskEvent {}

class LoadTasksEvent extends TaskEvent {}

class UpdateTaskEvent extends TaskEvent {
  final Task task;
  UpdateTaskEvent(this.task);
}

class CreateTaskEvent extends TaskEvent {
  final Task task;
  CreateTaskEvent(this.task);
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;
  DeleteTaskEvent(this.taskId);
}

class AddCommentEvent extends TaskEvent {
  final String taskId;
  final Comment comment;
  AddCommentEvent(this.taskId, this.comment);
}

// States
abstract class TaskState {}

class TasksLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  final User currentUser;
  TasksLoaded(this.tasks, this.currentUser);
}

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository = TaskRepository();
  final UserRepository _userRepository = UserRepository();

  TaskBloc() : super(TasksLoading()) {
    on<LoadTasksEvent>((event, emit) async {
      emit(TasksLoading());
      try {
        final tasks = await _taskRepository.getTasks();
        final currentUser = await _userRepository.getCurrentUser();
        emit(TasksLoaded(tasks, currentUser));
      } catch (e) {
        // Handle error
      }
    });

    on<UpdateTaskEvent>((event, emit) async {
      if (state is TasksLoaded) {
        final currentState = state as TasksLoaded;
        await _taskRepository.updateTask(event.task);
        final updatedTasks = await _taskRepository.getTasks();
        emit(TasksLoaded(updatedTasks, currentState.currentUser));
      }
    });

    on<CreateTaskEvent>((event, emit) async {
      if (state is TasksLoaded) {
        final currentState = state as TasksLoaded;
        await _taskRepository.createTask(event.task);
        final updatedTasks = await _taskRepository.getTasks();
        emit(TasksLoaded(updatedTasks, currentState.currentUser));
      }
    });

    on<DeleteTaskEvent>((event, emit) async {
      if (state is TasksLoaded) {
        final currentState = state as TasksLoaded;
        await _taskRepository.deleteTask(event.taskId);
        final updatedTasks = await _taskRepository.getTasks();
        emit(TasksLoaded(updatedTasks, currentState.currentUser));
      }
    });

    on<AddCommentEvent>((event, emit) async {
      if (state is TasksLoaded) {
        final currentState = state as TasksLoaded;
        await _taskRepository.addComment(event.taskId, event.comment);
        final updatedTasks = await _taskRepository.getTasks();
        emit(TasksLoaded(updatedTasks, currentState.currentUser));
      }
    });
  }
}
