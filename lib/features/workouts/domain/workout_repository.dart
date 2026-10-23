import 'package:sovereign/features/workouts/domain/workout.dart';

abstract class WorkoutRepository {
  Stream<List<Workout>> watchWorkouts();
  Future<void> saveWorkout(Workout workout);
  Future<void> delete(String id);
}
