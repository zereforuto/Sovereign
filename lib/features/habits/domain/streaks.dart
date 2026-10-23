import 'dart:math' as math;
import 'package:sovereign/features/habits/domain/habit.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class Streaks {
  final int current;
  final int longest;

  const Streaks({
    required this.current,
    required this.longest,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Streaks &&
          runtimeType == other.runtimeType &&
          current == other.current &&
          longest == other.longest;

  @override
  int get hashCode => current.hashCode ^ longest.hashCode;
}

/// Computes current and longest streaks for a [Habit].
/// Review Focus 3: Weekday-scheduled habit (e.g. Mon/Wed/Fri) - unscheduled days do NOT break the streak.
Streaks computeStreaks(
  Habit habit,
  Set<DateTime> checkinDates,
  DateTime today,
) {
  final normalizedCheckins = checkinDates.map(dateOnly).toSet();
  final targetToday = dateOnly(today);

  // If habit has no scheduled days, streak is 0
  if (habit.weekdays.isEmpty) {
    return const Streaks(current: 0, longest: 0);
  }

  // 1. Calculate CURRENT streak:
  // Walk backward starting from today or the last scheduled day.
  int currentStreak = 0;
  DateTime cursor = targetToday;

  // Determine starting point for current streak check:
  // If today is scheduled and checked in -> count today and walk backward.
  // If today is scheduled but NOT checked in -> today might still be completed before end of day,
  // so check from the previous scheduled day without breaking yet!
  // If today is unscheduled -> start walking backward from the last scheduled day before today.
  if (habit.weekdays.contains(cursor.weekday)) {
    if (normalizedCheckins.contains(cursor)) {
      currentStreak++;
      cursor = cursor.subtract(const Duration(days: 1));
    } else {
      cursor = cursor.subtract(const Duration(days: 1));
    }
  } else {
    // Today is unscheduled, check from prior scheduled days
    cursor = cursor.subtract(const Duration(days: 1));
  }

  while (true) {
    // Skip unscheduled days
    while (!habit.weekdays.contains(cursor.weekday)) {
      cursor = cursor.subtract(const Duration(days: 1));
      // Safety limit: if we've gone back 2 years with no scheduled day, break
      if (targetToday.difference(cursor).inDays > 730) break;
    }

    if (normalizedCheckins.contains(cursor)) {
      currentStreak++;
      cursor = cursor.subtract(const Duration(days: 1));
    } else {
      // Encountered an unchecked scheduled day
      break;
    }
  }

  // If today was not checked, but yesterday was also missing, current is 0
  // Handled by loop condition naturally since cursor would hit missing previous day.

  // 2. Calculate LONGEST streak historically:
  // Find all scheduled days from the earliest check-in up to today.
  int longestStreak = currentStreak;
  if (normalizedCheckins.isNotEmpty) {
    final sortedCheckins = normalizedCheckins.toList()..sort();
    final earliest = sortedCheckins.first;

    int tempStreak = 0;
    DateTime histCursor = earliest;

    while (!histCursor.isAfter(targetToday)) {
      if (habit.weekdays.contains(histCursor.weekday)) {
        if (normalizedCheckins.contains(histCursor)) {
          tempStreak++;
          longestStreak = math.max(longestStreak, tempStreak);
        } else {
          tempStreak = 0;
        }
      }
      histCursor = histCursor.add(const Duration(days: 1));
    }
  }

  return Streaks(
    current: currentStreak,
    longest: math.max(currentStreak, longestStreak),
  );
}
