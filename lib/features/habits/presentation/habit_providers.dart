import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovereign/core/supabase/supabase_providers.dart';
import 'package:sovereign/features/habits/data/supabase_habit_repository.dart';
import 'package:sovereign/features/habits/domain/habit.dart';
import 'package:sovereign/features/habits/domain/habit_repository.dart';
import 'package:sovereign/features/habits/domain/streaks.dart';

export 'package:sovereign/features/habits/domain/habit.dart';
export 'package:sovereign/features/habits/domain/habit_repository.dart';
export 'package:sovereign/features/habits/domain/streaks.dart';

/// Provides active [HabitRepository].
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseHabitRepository(client);
});

/// Streams all active (unarchived) habits.
final habitsStreamProvider = StreamProvider<List<Habit>>((ref) {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.watchHabits().map(
        (habits) => habits.where((h) => !h.isArchived).toList(),
      );
});

/// Streams all habit check-ins.
final checkinsStreamProvider = StreamProvider<List<HabitCheckin>>((ref) {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.watchCheckins();
});

/// Habit summary model combining the habit with computed streaks and today's status.
class HabitSummary {
  final Habit habit;
  final Streaks streaks;
  final bool isCheckedToday;
  final Set<DateTime> checkins;

  const HabitSummary({
    required this.habit,
    required this.streaks,
    required this.isCheckedToday,
    required this.checkins,
  });
}

/// Provides combined habit summaries for the UI.
final habitSummariesProvider = Provider<AsyncValue<List<HabitSummary>>>((ref) {
  final habitsAsync = ref.watch(habitsStreamProvider);
  final checkinsAsync = ref.watch(checkinsStreamProvider);

  if (habitsAsync.isLoading || checkinsAsync.isLoading) {
    return const AsyncLoading();
  }
  if (habitsAsync.hasError) {
    return AsyncError(habitsAsync.error!, habitsAsync.stackTrace!);
  }
  if (checkinsAsync.hasError) {
    return AsyncError(checkinsAsync.error!, checkinsAsync.stackTrace!);
  }

  final habits = habitsAsync.value ?? [];
  final checkins = checkinsAsync.value ?? [];
  final today = dateOnly(DateTime.now());

  // Group checkins by habitId
  final checkinsByHabit = <String, Set<DateTime>>{};
  for (final c in checkins) {
    checkinsByHabit.putIfAbsent(c.habitId, () => {}).add(dateOnly(c.date));
  }

  final summaries = habits.map((habit) {
    final habitDates = checkinsByHabit[habit.id] ?? <DateTime>{};
    final streaks = computeStreaks(habit, habitDates, today);
    final isChecked = habitDates.contains(today);

    return HabitSummary(
      habit: habit,
      streaks: streaks,
      isCheckedToday: isChecked,
      checkins: habitDates,
    );
  }).toList();

  return AsyncData(summaries);
});
