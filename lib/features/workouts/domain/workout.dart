import 'package:sovereign/features/settings/domain/weight_unit.dart';

class WorkoutSet {
  final int setNumber;
  final int reps;
  final double? weight;
  final WeightUnit unit;

  const WorkoutSet({
    required this.setNumber,
    required this.reps,
    this.weight,
    required this.unit,
  });

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      setNumber: (map['set_number'] as num).toInt(),
      reps: (map['reps'] as num).toInt(),
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      unit: WeightUnit.fromString(map['unit'] as String?),
    );
  }

  Map<String, dynamic> toMap({String? exerciseId, String? userId}) {
    final map = <String, dynamic>{
      'set_number': setNumber,
      'reps': reps,
      'weight': weight,
      'unit': unit.name,
    };
    if (exerciseId != null) map['workout_exercise_id'] = exerciseId;
    if (userId != null) map['user_id'] = userId;
    return map;
  }
}

class WorkoutExercise {
  final String name;
  final List<WorkoutSet> sets;

  const WorkoutExercise({
    required this.name,
    required this.sets,
  });

  WorkoutExercise copyWith({
    String? name,
    List<WorkoutSet>? sets,
  }) {
    return WorkoutExercise(
      name: name ?? this.name,
      sets: sets ?? this.sets,
    );
  }
}

class Workout {
  final String id;
  final String? name;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String notes;
  final List<WorkoutExercise> exercises;

  const Workout({
    required this.id,
    this.name,
    required this.startedAt,
    this.endedAt,
    this.notes = '',
    required this.exercises,
  });

  Workout copyWith({
    String? id,
    String? name,
    DateTime? startedAt,
    DateTime? endedAt,
    String? notes,
    List<WorkoutExercise>? exercises,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      notes: notes ?? this.notes,
      exercises: exercises ?? this.exercises,
    );
  }

  Map<String, dynamic> toMap({String? userId}) {
    final map = <String, dynamic>{
      'name': name,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'notes': notes,
    };
    if (id.isNotEmpty) map['id'] = id;
    if (userId != null) map['user_id'] = userId;
    return map;
  }
}
