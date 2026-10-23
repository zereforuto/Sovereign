enum TaskPriority {
  low,
  medium,
  high;

  static TaskPriority fromString(String val) {
    return switch (val) {
      'high' => TaskPriority.high,
      'medium' => TaskPriority.medium,
      _ => TaskPriority.low,
    };
  }

  String toDbValue() => name;
}

/// Domain entity representing a task in Sovereign.
class TodoTask {
  final String id;
  final String title;
  final String notes;
  final TaskPriority priority;
  final DateTime? dueAt;
  final DateTime? completedAt;

  const TodoTask({
    required this.id,
    required this.title,
    this.notes = '',
    this.priority = TaskPriority.medium,
    this.dueAt,
    this.completedAt,
  });

  bool get isDone => completedAt != null;

  TodoTask copyWith({
    String? id,
    String? title,
    String? notes,
    TaskPriority? priority,
    DateTime? dueAt,
    DateTime? completedAt,
    bool clearDueAt = false,
    bool clearCompletedAt = false,
  }) {
    return TodoTask(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  factory TodoTask.fromMap(Map<String, dynamic> map) {
    return TodoTask(
      id: map['id'] as String,
      title: map['title'] as String,
      notes: (map['notes'] as String?) ?? '',
      priority: TaskPriority.fromString((map['priority'] as String?) ?? 'medium'),
      dueAt: map['due_at'] != null ? DateTime.parse(map['due_at'] as String) : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap({String? userId}) {
    final map = <String, dynamic>{
      'title': title,
      'notes': notes,
      'priority': priority.toDbValue(),
      'due_at': dueAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
    if (id.isNotEmpty) map['id'] = id;
    if (userId != null) map['user_id'] = userId;
    return map;
  }
}
