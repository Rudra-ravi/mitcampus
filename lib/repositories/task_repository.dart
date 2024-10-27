import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mitcampus/models/task.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tasks';

  Future<List<Task>> getTasks() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('deadline')
          .get();
      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toFirestore());
  }

  Future<Task> createTask(Task task) async {
    try {
      final docRef = await _firestore.collection(_collection).add(task.toFirestore());
      
      // Fetch the created document to return the complete task with ID
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception('Failed to create task: Document does not exist after creation');
      }
      
      return Task.fromFirestore(docSnapshot);
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
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
