import 'dart:async';
import 'package:sovereign/features/auth/domain/app_user.dart';
import 'package:sovereign/features/auth/domain/auth_repository.dart';
import 'package:sovereign/features/tasks/domain/task_repository.dart';
import 'package:sovereign/features/tasks/domain/todo_task.dart';

class FakeAuthRepository implements AuthRepository {
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  List<String> calls = [];

  FakeAuthRepository({AppUser? initialUser}) : _currentUser = initialUser;

  @override
  Stream<AppUser?> authChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    calls.add('signInWithEmail:$email');
    _currentUser = AppUser(id: 'fake-user-id', email: email);
    _controller.add(_currentUser);
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    calls.add('signUpWithEmail:$email');
    _currentUser = AppUser(id: 'fake-user-id', email: email);
    _controller.add(_currentUser);
  }

  @override
  Future<void> signInWithGoogle() async {
    calls.add('signInWithGoogle');
    _currentUser = const AppUser(id: 'fake-google-id', email: 'user@google.com');
    _controller.add(_currentUser);
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    _currentUser = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}

class FakeTaskRepository implements TaskRepository {
  final StreamController<List<TodoTask>> _controller =
      StreamController<List<TodoTask>>.broadcast();
  List<TodoTask> _tasks;

  final List<TodoTask> createdDrafts = [];
  final List<String> completedCalls = [];
  final List<String> deletedIds = [];

  FakeTaskRepository({List<TodoTask>? initialTasks})
      : _tasks = List<TodoTask>.from(initialTasks ?? []);

  @override
  Stream<List<TodoTask>> watchAll() async* {
    yield _tasks;
    yield* _controller.stream;
  }

  @override
  Future<void> create(TodoTask draft) async {
    createdDrafts.add(draft);
    final created = draft.copyWith(id: 'task-${_tasks.length + 1}');
    _tasks = [..._tasks, created];
    _controller.add(_tasks);
  }

  @override
  Future<void> update(TodoTask task) async {
    _tasks = _tasks.map((t) => t.id == task.id ? task : t).toList();
    _controller.add(_tasks);
  }

  @override
  Future<void> delete(String id) async {
    deletedIds.add(id);
    _tasks = _tasks.where((t) => t.id != id).toList();
    _controller.add(_tasks);
  }

  @override
  Future<void> setCompleted(String id, bool done) async {
    completedCalls.add('$id:$done');
    _tasks = _tasks.map((t) {
      if (t.id == id) {
        return t.copyWith(
          completedAt: done ? DateTime.now() : null,
          clearCompletedAt: !done,
        );
      }
      return t;
    }).toList();
    _controller.add(_tasks);
  }

  void dispose() {
    _controller.close();
  }
}

