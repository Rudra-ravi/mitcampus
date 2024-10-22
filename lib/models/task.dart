class Task {
  final String id;
  final String title;
  final DateTime deadline;
  final bool isCompleted;
  final String? description;

  Task({
    required this.id,
    required this.title,
    required this.deadline,
    this.isCompleted = false,
    this.description,
  });

  Task copyWith({
    String? id,
    String? title,
    DateTime? deadline,
    bool? isCompleted,
    String? description,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      description: description ?? this.description,
    );
  }
}
