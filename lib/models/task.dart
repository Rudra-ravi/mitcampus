import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String? id;
  final String title;
  final DateTime deadline;
  final bool isCompleted;
  final String? description;
  final List<String> assignedUsers;
  final List<Comment> comments;
  final Map<String, bool> userCompletions;

  Task({
    this.id,
    required this.title,
    required this.deadline,
    this.isCompleted = false,
    this.description,
    required this.assignedUsers,
    required this.comments,
    Map<String, bool>? userCompletions,
  }) : userCompletions = userCompletions ?? {};

  Task copyWith({
    String? id,
    String? title,
    DateTime? deadline,
    bool? isCompleted,
    String? description,
    List<String>? assignedUsers,
    List<Comment>? comments,
    Map<String, bool>? userCompletions,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      description: description ?? this.description,
      assignedUsers: assignedUsers ?? this.assignedUsers,
      comments: comments ?? this.comments,
      userCompletions: userCompletions ?? this.userCompletions,
    );
  }

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, bool> userCompletions = {};
    if (data['userCompletions'] != null) {
      data['userCompletions'].forEach((key, value) {
        userCompletions[key] = value as bool;
      });
    }
    
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      deadline: (data['deadline'] as Timestamp).toDate(),
      isCompleted: false,
      description: data['description'],
      assignedUsers: List<String>.from(data['assignedUsers'] ?? []),
      comments: (data['comments'] as List<dynamic>? ?? [])
          .map((comment) => Comment.fromMap(comment))
          .toList(),
      userCompletions: userCompletions,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'deadline': Timestamp.fromDate(deadline),
      'isCompleted': isCompleted,
      'description': description,
      'assignedUsers': assignedUsers,
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'userCompletions': userCompletions,
    };
  }

  bool get isFullyCompleted => 
    assignedUsers.isNotEmpty && 
    assignedUsers.every((userId) => userCompletions[userId] == true);
}

class Comment {
  final String userId;
  final String userName;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      userId: map['userId'],
      userName: map['userName'] ?? 'Anonymous',
      text: map['text'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
