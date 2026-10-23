import 'package:sovereign/features/planner/domain/planner_entry.dart';

/// Returns all entries whose date matches [date] (ignoring time), sorted by hour.
List<PlannerEntry> entriesForDate(List<PlannerEntry> entries, DateTime date) {
  final dateOnly = DateTime(date.year, date.month, date.day);
  return entries
      .where((e) {
        final entryDate = DateTime(e.date.year, e.date.month, e.date.day);
        return entryDate == dateOnly;
      })
      .toList()
    ..sort((a, b) => a.hour.compareTo(b.hour));
}

/// Returns null when valid; an error message otherwise.
/// Title must be non-empty; hour must be in 0–23.
String? validatePlannerEntry(String title, int hour) {
  if (title.trim().isEmpty) {
    return 'Title cannot be empty';
  }
  if (hour < 0 || hour > 23) {
    return 'Hour must be between 0 and 23';
  }
  return null;
}
