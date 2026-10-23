import 'package:sovereign/features/habits/domain/habit.dart';

abstract class HabitRepository {
  Stream<List<Habit>> watchHabits();
  Stream<List<HabitCheckin>> watchCheckins();
  Future<void> create(Habit draft);
  Future<void> archive(String id);
  Future<void> setCheckin(String habitId, DateTime date, bool done);
}
