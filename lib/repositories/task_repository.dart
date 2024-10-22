import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mitcampus/models/task.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Task>> getTasks() async {
    final snapshot = await _firestore.collection('tasks').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Task(
        id: doc.id,
        title: data['title'],
        deadline: (data['deadline'] as Timestamp).toDate(),
        isCompleted: data['isCompleted'] ?? false,
        description: data['description'],
      );
    }).toList();
  }

  Future<void> updateTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update({
      'title': task.title,
      'deadline': task.deadline,
      'isCompleted': task.isCompleted,
      'description': task.description,
    });
  }
}
