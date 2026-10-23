import 'package:sovereign/core/errors/guard.dart';
import 'package:sovereign/features/tasks/domain/task_repository.dart';
import 'package:sovereign/features/tasks/domain/todo_task.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTaskRepository implements TaskRepository {
  final SupabaseClient _client;

  SupabaseTaskRepository(this._client);

  @override
  Stream<List<TodoTask>> watchAll() {
    return _client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.map((row) => TodoTask.fromMap(row)).toList());
  }

  @override
  Future<void> create(TodoTask draft) {
    return guard(() async {
      final userId = _client.auth.currentUser?.id;
      await _client.from('tasks').insert(draft.toMap(userId: userId));
    });
  }

  @override
  Future<void> update(TodoTask task) {
    return guard(() async {
      await _client
          .from('tasks')
          .update(task.toMap())
          .eq('id', task.id);
    });
  }

  @override
  Future<void> delete(String id) {
    return guard(() async {
      await _client.from('tasks').delete().eq('id', id);
    });
  }

  @override
  Future<void> setCompleted(String id, bool done) {
    return guard(() async {
      await _client.from('tasks').update({
        'completed_at': done ? DateTime.now().toIso8601String() : null,
      }).eq('id', id);
    });
  }
}
