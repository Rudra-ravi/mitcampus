import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mitcampus/models/task.dart';
import 'package:mitcampus/models/user.dart';
import 'package:mitcampus/repositories/task_repository.dart';
import 'package:mitcampus/repositories/user_repository.dart';
import 'package:mitcampus/services/notification_service.dart';

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

class UpdateTaskStatus extends TaskEvent {
  final String taskId;
  final bool isCompleted;

  UpdateTaskStatus({required this.taskId, required this.isCompleted});
}

// States
abstract class TaskState {}

class TasksLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  final User currentUser;
  TasksLoaded(this.tasks, this.currentUser);
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository = TaskRepository();
  final UserRepository _userRepository = UserRepository();
  final NotificationService _notificationService = NotificationService();
  StreamSubscription? _tasksSubscription;

  TaskBloc() : super(TasksLoading()) {
    on<LoadTasksEvent>((event, emit) async {
      emit(TasksLoading());
      try {
        final tasks = await _taskRepository.getTasks();
        final currentUser = await _userRepository.getCurrentUser();
        emit(TasksLoaded(tasks, currentUser));
      } catch (e) {
        emit(TaskError('Failed to load tasks: $e'));
      }
    });

    on<UpdateTaskEvent>((event, emit) async {
      try {
        await _taskRepository.updateTask(event.task);
      } catch (e) {
        emit(TaskError('Failed to update task: Insufficient permissions'));
        // Reload the tasks to ensure UI is in sync with server
        add(LoadTasksEvent());
      }
    });

    on<CreateTaskEvent>((event, emit) async {
      try {
        emit(TasksLoading()); // Add loading state
        await _taskRepository.createTask(event.task);
        final updatedTasks = await _taskRepository.getTasks();
        final currentUser = await _userRepository.getCurrentUser();
        emit(TasksLoaded(updatedTasks, currentUser));
      } catch (e) {
        emit(TaskError('Failed to create task: $e'));
        await Future.delayed(const Duration(seconds: 2)); // Show error briefly
        // Reload the tasks instead of emitting previous state
        final tasks = await _taskRepository.getTasks();
        final currentUser = await _userRepository.getCurrentUser();
        emit(TasksLoaded(tasks, currentUser));
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

    on<UpdateTaskStatus>((event, emit) async {
      if (state is TasksLoaded) {
        try {
          final currentState = state as TasksLoaded;
          final task = currentState.tasks.firstWhere((t) => t.id == event.taskId);
          
          // Create updated task with all existing properties
          final updatedTask = task.copyWith(
            isCompleted: event.isCompleted,
          );
          
          await _taskRepository.updateTask(updatedTask);
          final updatedTasks = await _taskRepository.getTasks();
          emit(TasksLoaded(updatedTasks, currentState.currentUser));
        } catch (e) {
          emit(TaskError('Failed to update task status: $e'));
          add(LoadTasksEvent()); // Reload tasks to sync with server
        }
      }
    });

    // Update the stream subscription to use snapshots
    _tasksSubscription = _taskRepository.getTasksStream().listen((tasks) {
      if (state is TasksLoaded) {
        final currentTasks = (state as TasksLoaded).tasks;
        final newTasks = tasks.where((task) => 
          !currentTasks.any((currentTask) => currentTask.id == task.id)).toList();
        
        for (var task in newTasks) {
          _showTaskNotification(task);
        }
      }
      add(LoadTasksEvent());
    });
  }

  Future<void> _showTaskNotification(Task task) async {
    await _notificationService.showNotification(
      title: 'New Task Assigned',
      body: 'Task: ${task.title}',
    );
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
