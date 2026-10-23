import 'package:sovereign/features/workouts/domain/workout.dart';

/// Review Focus 5: Reject workout with no sets or no exercises.
String? validateWorkout(Workout workout) {
  if (workout.exercises.isEmpty) {
    return 'Add at least one exercise with sets';
  }
  for (final ex in workout.exercises) {
    if (ex.sets.isEmpty) {
      return 'Each exercise must have at least one set';
    }
  }
  return null;
}

/// Review Focus 5: Reps must be > 0; weight must be empty or a non-negative number.
String? validateSet(int reps, String weightText) {
  if (reps <= 0) {
    return 'Reps must be greater than 0';
  }
  final trimmed = weightText.trim();
  if (trimmed.isNotEmpty) {
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return 'Weight must be a non-negative number';
    }
  }
  return null;
}

class WeeklyConsistency {
  final int workoutsThisWeek;
  final int weeklyStreak;

  const WeeklyConsistency({
    required this.workoutsThisWeek,
    required this.weeklyStreak,
  });
}

/// Computes workouts this week and consecutive-week streak (weeks start on Monday).
WeeklyConsistency computeWeeklyConsistency(List<Workout> history, DateTime now) {
  if (history.isEmpty) {
    return const WeeklyConsistency(workoutsThisWeek: 0, weeklyStreak: 0);
  }

  DateTime startOfWeek(DateTime d) {
    final dateOnly = DateTime(d.year, d.month, d.day);
    return dateOnly.subtract(Duration(days: dateOnly.weekday - 1));
  }

  final currentWeekStart = startOfWeek(now);
  final endOfCurrentWeek = currentWeekStart.add(const Duration(days: 7));

  // Count workouts in this current week
  final thisWeekCount = history.where((w) {
    return !w.startedAt.isBefore(currentWeekStart) &&
        w.startedAt.isBefore(endOfCurrentWeek);
  }).length;

  // Group workout dates into distinct week starts
  final weeksWithWorkouts = <DateTime>{};
  for (final w in history) {
    weeksWithWorkouts.add(startOfWeek(w.startedAt));
  }

  // Calculate streak of consecutive weeks ending either at current week or previous week
  int streak = 0;
  DateTime cursor = currentWeekStart;

  // If current week has workouts, start counting from current week
  // If current week has NO workouts yet, check if previous week had workouts (streak still alive for the week!)
  if (weeksWithWorkouts.contains(cursor)) {
    while (weeksWithWorkouts.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 7));
    }
  } else {
    // Current week not completed yet, check starting from last week
    cursor = cursor.subtract(const Duration(days: 7));
    while (weeksWithWorkouts.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 7));
    }
  }

  return WeeklyConsistency(
    workoutsThisWeek: thisWeekCount,
    weeklyStreak: streak,
  );
}

/// Returns the sets logged for this exercise name in the most recent workout containing it.
List<WorkoutSet> lastSetsFor(String exerciseName, List<Workout> history) {
  final sorted = List<Workout>.from(history)
    ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  final lowerTarget = exerciseName.trim().toLowerCase();

  for (final w in sorted) {
    for (final ex in w.exercises) {
      if (ex.name.trim().toLowerCase() == lowerTarget && ex.sets.isNotEmpty) {
        return ex.sets;
      }
    }
  }
  return const [];
}

/// Case-insensitive, de-duplicated exercise name suggestions from workout history.
List<String> exerciseSuggestions(List<Workout> history, String prefix) {
  final cleanPrefix = prefix.trim().toLowerCase();
  final seen = <String>{};
  final suggestions = <String>[];

  for (final w in history) {
    for (final ex in w.exercises) {
      final trimmed = ex.name.trim();
      final lower = trimmed.toLowerCase();
      if (lower.startsWith(cleanPrefix) && !seen.contains(lower)) {
        seen.add(lower);
        suggestions.add(trimmed);
      }
    }
  }
  return suggestions;
}
