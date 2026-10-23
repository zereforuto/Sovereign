import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovereign/core/supabase/supabase_providers.dart';
import 'package:sovereign/features/workouts/data/supabase_workout_repository.dart';
import 'package:sovereign/features/workouts/domain/workout.dart';
import 'package:sovereign/features/workouts/domain/workout_logic.dart';
import 'package:sovereign/features/workouts/domain/workout_repository.dart';

export 'package:sovereign/features/workouts/domain/workout.dart';
export 'package:sovereign/features/workouts/domain/workout_logic.dart';
export 'package:sovereign/features/workouts/domain/workout_repository.dart';

/// Provides the active [WorkoutRepository].
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseWorkoutRepository(client);
});

/// Streams all recorded workouts.
final workoutsStreamProvider = StreamProvider<List<Workout>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.watchWorkouts();
});

/// Computes weekly consistency statistics from workouts history.
final weeklyConsistencyProvider = Provider<WeeklyConsistency>((ref) {
  final workoutsAsync = ref.watch(workoutsStreamProvider);
  final workouts = workoutsAsync.value ?? [];
  return computeWeeklyConsistency(workouts, DateTime.now());
});
