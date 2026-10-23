import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovereign/core/supabase/supabase_providers.dart';
import 'package:sovereign/features/tasks/data/supabase_task_repository.dart';
import 'package:sovereign/features/tasks/domain/task_logic.dart';
import 'package:sovereign/features/tasks/domain/task_repository.dart';
import 'package:sovereign/features/tasks/domain/todo_task.dart';

export 'package:sovereign/features/tasks/domain/task_logic.dart';
export 'package:sovereign/features/tasks/domain/task_repository.dart';
export 'package:sovereign/features/tasks/domain/todo_task.dart';

/// Provides the active [TaskRepository].
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseTaskRepository(client);
});

/// Streams all tasks from the repository.
final tasksStreamProvider = StreamProvider<List<TodoTask>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchAll();
});

class TaskFilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() => TaskFilter.today;

  void setFilter(TaskFilter filter) => state = filter;
}

final taskFilterProvider =
    NotifierProvider<TaskFilterNotifier, TaskFilter>(TaskFilterNotifier.new);

/// Filtered and sorted tasks for the presentation layer.
final tasksProvider = Provider<AsyncValue<List<TodoTask>>>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  final filter = ref.watch(taskFilterProvider);

  return tasksAsync.whenData((tasks) {
    final filtered = filterTasks(tasks, filter, DateTime.now());
    return sortTasks(filtered);
  });
});
