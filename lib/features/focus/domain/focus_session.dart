/// Domain entity representing a completed or aborted focus session.
class FocusSession {
  final String id;
  final String? taskId;
  final DateTime startedAt;
  final int durationSeconds;
  final bool completed;

  const FocusSession({
    required this.id,
    this.taskId,
    required this.startedAt,
    required this.durationSeconds,
    required this.completed,
  });

  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'] as String,
      taskId: map['task_id'] as String?,
      startedAt: DateTime.parse(map['started_at'] as String),
      durationSeconds: (map['duration_seconds'] as num).toInt(),
      completed: (map['completed'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap({String? userId}) {
    final map = <String, dynamic>{
      'task_id': taskId,
      'started_at': startedAt.toIso8601String(),
      'duration_seconds': durationSeconds,
      'completed': completed,
    };
    if (id.isNotEmpty) map['id'] = id;
    if (userId != null) map['user_id'] = userId;
    return map;
  }
}
