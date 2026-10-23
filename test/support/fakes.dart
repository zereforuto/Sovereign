import 'dart:async';
import 'package:sovereign/features/auth/domain/app_user.dart';
import 'package:sovereign/features/auth/domain/auth_repository.dart';
import 'package:sovereign/features/tasks/domain/task_repository.dart';
import 'package:sovereign/features/tasks/domain/todo_task.dart';
import 'package:sovereign/features/habits/domain/habit.dart';
import 'package:sovereign/features/habits/domain/habit_repository.dart';
import 'package:sovereign/features/habits/domain/streaks.dart';
import 'package:sovereign/features/focus/domain/focus_repository.dart';
import 'package:sovereign/features/focus/domain/focus_session.dart';

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

class FakeHabitRepository implements HabitRepository {
  final StreamController<List<Habit>> _habitsController =
      StreamController<List<Habit>>.broadcast();
  final StreamController<List<HabitCheckin>> _checkinsController =
      StreamController<List<HabitCheckin>>.broadcast();

  List<Habit> _habits;
  List<HabitCheckin> _checkins;

  final List<String> checkinCalls = [];
  final List<String> archivedIds = [];

  FakeHabitRepository({
    List<Habit>? initialHabits,
    List<HabitCheckin>? initialCheckins,
  })  : _habits = List<Habit>.from(initialHabits ?? []),
        _checkins = List<HabitCheckin>.from(initialCheckins ?? []);

  @override
  Stream<List<Habit>> watchHabits() async* {
    yield _habits;
    yield* _habitsController.stream;
  }

  @override
  Stream<List<HabitCheckin>> watchCheckins() async* {
    yield _checkins;
    yield* _checkinsController.stream;
  }

  @override
  Future<void> create(Habit draft) async {
    final created = draft.copyWith(id: 'habit-${_habits.length + 1}');
    _habits = [..._habits, created];
    _habitsController.add(_habits);
  }

  @override
  Future<void> archive(String id) async {
    archivedIds.add(id);
    _habits = _habits.map((h) {
      if (h.id == id) {
        return h.copyWith(archivedAt: DateTime.now());
      }
      return h;
    }).toList();
    _habitsController.add(_habits);
  }

  @override
  Future<void> setCheckin(String habitId, DateTime date, bool done) async {
    final d = dateOnly(date);
    checkinCalls.add('$habitId:$d:$done');

    if (done) {
      _checkins = [
        ..._checkins.where((c) => !(c.habitId == habitId && dateOnly(c.date) == d)),
        HabitCheckin(habitId: habitId, date: d),
      ];
    } else {
      _checkins = _checkins
          .where((c) => !(c.habitId == habitId && dateOnly(c.date) == d))
          .toList();
    }
    _checkinsController.add(_checkins);
  }

  void dispose() {
    _habitsController.close();
    _checkinsController.close();
  }
}

class FakeFocusRepository implements FocusRepository {
  final StreamController<List<FocusSession>> _controller =
      StreamController<List<FocusSession>>.broadcast();

  List<FocusSession> _sessions;
  final List<FocusSession> savedSessions = [];

  FakeFocusRepository({List<FocusSession>? initialSessions})
      : _sessions = List<FocusSession>.from(initialSessions ?? []);

  @override
  Stream<List<FocusSession>> watchSessions() async* {
    yield _sessions;
    yield* _controller.stream;
  }

  @override
  Future<void> saveSession(FocusSession session) async {
    savedSessions.add(session);
    final saved = FocusSession(
      id: 'session-${_sessions.length + 1}',
      taskId: session.taskId,
      startedAt: session.startedAt,
      durationSeconds: session.durationSeconds,
      completed: session.completed,
    );
    _sessions = [saved, ..._sessions];
    _controller.add(_sessions);
  }

  void dispose() {
    _controller.close();
  }
}



