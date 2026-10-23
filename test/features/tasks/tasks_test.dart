import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sovereign/core/theme/sovereign_theme.dart';
import 'package:sovereign/features/tasks/presentation/task_form.dart';
import 'package:sovereign/features/tasks/presentation/task_providers.dart';
import 'package:sovereign/features/tasks/presentation/tasks_screen.dart';

import '../../support/fakes.dart';

void main() {
  group('Task domain logic & Review Focus 1', () {
    test('validateTaskTitle rejects empty or whitespace-only', () {
      expect(validateTaskTitle(''), isNotNull);
      expect(validateTaskTitle('   '), isNotNull);
      expect(validateTaskTitle('Run'), isNull);
    });

    test('sortTasks puts high priority before medium and done last', () {
      final now = DateTime(2026, 10, 23, 10, 0);
      final t1 = TodoTask(
        id: '1',
        title: 'Low active',
        notes: '',
        priority: TaskPriority.low,
      );
      final t2 = TodoTask(
        id: '2',
        title: 'High active',
        notes: '',
        priority: TaskPriority.high,
      );
      final t3 = TodoTask(
        id: '3',
        title: 'Med active',
        notes: '',
        priority: TaskPriority.medium,
      );
      final t4 = TodoTask(
        id: '4',
        title: 'High done',
        notes: '',
        priority: TaskPriority.high,
        completedAt: now,
      );

      final sorted = sortTasks([t1, t4, t3, t2]);
      expect(sorted.map((t) => t.id).toList(), ['2', '3', '1', '4']);
    });

    test('filterTasks correctly filters today, upcoming, done', () {
      final now = DateTime(2026, 10, 23, 12, 0);
      final dueToday = TodoTask(
        id: 'today',
        title: 'Due today',
        notes: '',
        priority: TaskPriority.medium,
        dueAt: DateTime(2026, 10, 23, 18, 0),
      );
      final overdue = TodoTask(
        id: 'overdue',
        title: 'Overdue not done',
        notes: '',
        priority: TaskPriority.high,
        dueAt: DateTime(2026, 10, 22, 18, 0),
      );
      final dueTomorrow = TodoTask(
        id: 'tomorrow',
        title: 'Due tomorrow',
        notes: '',
        priority: TaskPriority.low,
        dueAt: DateTime(2026, 10, 24, 10, 0),
      );
      final completed = TodoTask(
        id: 'done',
        title: 'Done task',
        notes: '',
        priority: TaskPriority.medium,
        completedAt: now,
      );

      final all = [dueToday, overdue, dueTomorrow, completed];

      final todayFiltered = filterTasks(all, TaskFilter.today, now);
      expect(todayFiltered.map((t) => t.id), containsAll(['today', 'overdue']));
      expect(todayFiltered.map((t) => t.id), isNot(contains('tomorrow')));
      expect(todayFiltered.map((t) => t.id), isNot(contains('done')));

      final upcomingFiltered = filterTasks(all, TaskFilter.upcoming, now);
      expect(upcomingFiltered.map((t) => t.id), contains('tomorrow'));
      expect(upcomingFiltered.map((t) => t.id), isNot(contains('today')));

      final doneFiltered = filterTasks(all, TaskFilter.done, now);
      expect(doneFiltered.map((t) => t.id), contains('done'));
      expect(doneFiltered.length, 1);
    });
  });

  group('Tasks Widgets & Review Focus 1 widget test', () {
    testWidgets('whitespace title shows error message and create is not called',
        (tester) async {
      final fakeRepo = FakeTaskRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            theme: SovereignTheme.dark,
            home: const Scaffold(
              body: TaskFormSheet(),
            ),
          ),
        ),
      );

      final titleField = find.byKey(const Key('task_title_field'));
      final saveBtn = find.byKey(const Key('task_save_button'));

      await tester.enterText(titleField, '   ');
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Title cannot be empty'), findsOneWidget);
      expect(fakeRepo.createdDrafts, isEmpty);
    });

    testWidgets('checking a task calls setCompleted(id, true)', (tester) async {
      final initialTask = TodoTask(
        id: 'task-1',
        title: 'Inspect rear wing',
        notes: '',
        priority: TaskPriority.high,
      );
      final fakeRepo = FakeTaskRepository(initialTasks: [initialTask]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            theme: SovereignTheme.dark,
            home: const TasksScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final checkbox = find.byKey(const Key('task_checkbox_task-1'));
      expect(checkbox, findsOneWidget);

      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      expect(fakeRepo.completedCalls, contains('task-1:true'));
    });
  });
}
