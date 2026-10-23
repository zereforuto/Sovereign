import 'package:sovereign/features/tasks/domain/todo_task.dart';

abstract class TaskRepository {
  Stream<List<TodoTask>> watchAll();
  Future<void> create(TodoTask draft);
  Future<void> update(TodoTask task);
  Future<void> delete(String id);
  Future<void> setCompleted(String id, bool done);
}
