import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mitcampus/models/task.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Task>> getTasks() async {
    final snapshot = await _firestore.collection('tasks').get();
    return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<void> updateTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toFirestore());
  }

  Future<Task> createTask(Task task) async {
    final docRef = await _firestore.collection('tasks').add(task.toFirestore());
    final newTask = task.copyWith(id: docRef.id);
    await docRef.update({'id': docRef.id});
    return newTask;
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  Future<void> addComment(String taskId, Comment comment) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'comments': FieldValue.arrayUnion([comment.toMap()])
    });
  }

  Future<List<Task>> getTasksForUser(String userId) async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('assignedUsers', arrayContains: userId)
        .get();
    return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }
}
