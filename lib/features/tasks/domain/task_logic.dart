import 'package:sovereign/features/tasks/domain/todo_task.dart';

enum TaskFilter { today, upcoming, done }

/// Review Focus 1: Task title empty or whitespace-only is rejected with a message.
String? validateTaskTitle(String? title) {
  if (title == null || title.trim().isEmpty) {
    return 'Title cannot be empty';
  }
  return null;
}

/// Incomplete first, then priority high to low, then earliest due, no due date last.
List<TodoTask> sortTasks(List<TodoTask> tasks) {
  final list = List<TodoTask>.from(tasks);
  list.sort((a, b) {
    // 1. Incomplete first
    if (a.isDone != b.isDone) {
      return a.isDone ? 1 : -1;
    }
    // 2. Priority high to low (high index > medium > low)
    final priorityOrder = {
      TaskPriority.high: 0,
      TaskPriority.medium: 1,
      TaskPriority.low: 2,
    };
    final pA = priorityOrder[a.priority] ?? 1;
    final pB = priorityOrder[b.priority] ?? 1;
    if (pA != pB) {
      return pA.compareTo(pB);
    }
    // 3. Earliest due date first, tasks without due date last
    if (a.dueAt != null && b.dueAt != null) {
      return a.dueAt!.compareTo(b.dueAt!);
    }
    if (a.dueAt != null && b.dueAt == null) return -1;
    if (a.dueAt == null && b.dueAt != null) return 1;

    return a.title.compareTo(b.title);
  });
  return list;
}

/// Filter tasks according to [TaskFilter].
/// Today: incomplete tasks due on or before today (includes overdue).
/// Upcoming: incomplete tasks due after today.
/// Done: all completed tasks.
List<TodoTask> filterTasks(List<TodoTask> tasks, TaskFilter filter, DateTime now) {
  final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

  return tasks.where((task) {
    switch (filter) {
      case TaskFilter.done:
        return task.isDone;
      case TaskFilter.today:
        if (task.isDone) return false;
        if (task.dueAt == null) return true; // Undated tasks show in Today's inbox
        return task.dueAt!.isBefore(todayEnd);
      case TaskFilter.upcoming:
        if (task.isDone) return false;
        if (task.dueAt == null) return false;
        return task.dueAt!.isAfter(todayEnd);
    }
  }).toList();
}
