import 'package:sovereign/core/errors/guard.dart';
import 'package:sovereign/features/workouts/domain/workout.dart';
import 'package:sovereign/features/workouts/domain/workout_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseWorkoutRepository implements WorkoutRepository {
  final SupabaseClient _client;

  SupabaseWorkoutRepository(this._client);

  @override
  Stream<List<Workout>> watchWorkouts() {
    return _client
        .from('workouts')
        .stream(primaryKey: ['id'])
        .order('started_at', ascending: false)
        .asyncMap((workoutRows) async {
          final List<Workout> result = [];

          for (final wRow in workoutRows) {
            final workoutId = wRow['id'] as String;

            // Fetch exercises for workout
            final exerciseRows = await _client
                .from('workout_exercises')
                .select()
                .eq('workout_id', workoutId)
                .order('position', ascending: true);

            final List<WorkoutExercise> exercises = [];
            for (final exRow in exerciseRows) {
              final exId = exRow['id'] as String;
              final setRows = await _client
                  .from('workout_sets')
                  .select()
                  .eq('workout_exercise_id', exId)
                  .order('set_number', ascending: true);

              final sets = setRows.map((s) => WorkoutSet.fromMap(s)).toList();
              exercises.add(WorkoutExercise(
                name: exRow['name'] as String,
                sets: sets,
              ));
            }

            result.add(Workout(
              id: workoutId,
              name: wRow['name'] as String?,
              startedAt: DateTime.parse(wRow['started_at'] as String),
              endedAt: wRow['ended_at'] != null
                  ? DateTime.parse(wRow['ended_at'] as String)
                  : null,
              notes: (wRow['notes'] as String?) ?? '',
              exercises: exercises,
            ));
          }

          return result;
        });
  }

  @override
  Future<void> saveWorkout(Workout workout) {
    return guard(() async {
      final userId = _client.auth.currentUser?.id;

      // 1. Insert workout row
      final workoutInsert = await _client
          .from('workouts')
          .insert(workout.toMap(userId: userId))
          .select()
          .single();

      final workoutId = workoutInsert['id'] as String;

      try {
        // 2. Insert exercises and child sets
        for (var i = 0; i < workout.exercises.length; i++) {
          final exercise = workout.exercises[i];
          final exInsert = await _client
              .from('workout_exercises')
              .insert({
                'workout_id': workoutId,
                'name': exercise.name.trim(),
                'position': i,
                'user_id': userId,
              })
              .select()
              .single();

          final exId = exInsert['id'] as String;

          for (final set in exercise.sets) {
            await _client.from('workout_sets').insert(
              set.toMap(exerciseId: exId, userId: userId),
            );
          }
        }
      } catch (_) {
        // Rollback / clean up orphaned workout row
        await _client.from('workouts').delete().eq('id', workoutId);
        rethrow;
      }
    });
  }

  @override
  Future<void> delete(String id) {
    return guard(() async {
      await _client.from('workouts').delete().eq('id', id);
    });
  }
}
