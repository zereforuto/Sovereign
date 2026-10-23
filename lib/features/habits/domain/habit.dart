/// Domain entity representing a Habit.
/// Weekdays: 1=Mon .. 7=Sun. All seven means daily.
class Habit {
  final String id;
  final String name;
  final Set<int> weekdays;
  final DateTime? archivedAt;

  const Habit({
    required this.id,
    required this.name,
    this.weekdays = const {1, 2, 3, 4, 5, 6, 7},
    this.archivedAt,
  });

  bool get isArchived => archivedAt != null;

  Habit copyWith({
    String? id,
    String? name,
    Set<int>? weekdays,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      weekdays: weekdays ?? this.weekdays,
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
    );
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    final rawSchedule = map['schedule'];
    Set<int> schedule = {1, 2, 3, 4, 5, 6, 7};
    if (rawSchedule is List) {
      schedule = rawSchedule.map((e) => (e as num).toInt()).toSet();
    }

    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      weekdays: schedule,
      archivedAt: map['archived_at'] != null
          ? DateTime.parse(map['archived_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap({String? userId}) {
    final map = <String, dynamic>{
      'name': name,
      'schedule': weekdays.toList()..sort(),
      'archived_at': archivedAt?.toIso8601String(),
    };
    if (id.isNotEmpty) map['id'] = id;
    if (userId != null) map['user_id'] = userId;
    return map;
  }
}

/// Domain entity representing a single day check-in for a habit.
class HabitCheckin {
  final String habitId;
  final DateTime date;

  const HabitCheckin({
    required this.habitId,
    required this.date,
  });

  factory HabitCheckin.fromMap(Map<String, dynamic> map) {
    return HabitCheckin(
      habitId: map['habit_id'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }

  Map<String, dynamic> toMap({String? userId}) {
    final map = <String, dynamic>{
      'habit_id': habitId,
      'date': '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    };
    if (userId != null) map['user_id'] = userId;
    return map;
  }
}
