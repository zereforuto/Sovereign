import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sovereign/core/theme/sovereign_theme.dart';
import 'package:sovereign/features/planner/presentation/planner_providers.dart';
import 'package:sovereign/features/planner/presentation/planner_screen.dart';

void main() {
  group('PlannerEntry & logic', () {
    test('plannerEntry creates with required fields', () {
      final entry = PlannerEntry(
        id: 'e1',
        date: DateTime(2026, 10, 21),
        hour: 9,
        title: 'Team standup',
        color: Colors.blue,
      );
      expect(entry.hour, 9);
      expect(entry.title, 'Team standup');
    });

    test('entriesForDate filters to correct date', () {
      final today = DateTime(2026, 10, 21);
      final tomorrow = DateTime(2026, 10, 22);
      final entries = [
        PlannerEntry(
          id: '1',
          date: today,
          hour: 9,
          title: 'Morning meeting',
          color: Colors.red,
        ),
        PlannerEntry(
          id: '2',
          date: tomorrow,
          hour: 10,
          title: 'Afternoon sync',
          color: Colors.blue,
        ),
        PlannerEntry(
          id: '3',
          date: today,
          hour: 14,
          title: 'Focus block',
          color: Colors.green,
        ),
      ];

      final result = entriesForDate(entries, today);
      expect(result.length, 2);
      expect(result.map((e) => e.id).toList(), containsAll(['1', '3']));
    });

    test('entriesForDate returns entries sorted by hour', () {
      final date = DateTime(2026, 10, 21);
      final entries = [
        PlannerEntry(
          id: 'b',
          date: date,
          hour: 14,
          title: 'Afternoon',
          color: Colors.orange,
        ),
        PlannerEntry(
          id: 'a',
          date: date,
          hour: 8,
          title: 'Morning',
          color: Colors.orange,
        ),
      ];

      final result = entriesForDate(entries, date);
      expect(result[0].id, 'a');
      expect(result[1].id, 'b');
    });

    test('validatePlannerEntry rejects empty title and invalid hour', () {
      expect(validatePlannerEntry('', 9), isNotNull);
      expect(validatePlannerEntry('Meeting', -1), isNotNull);
      expect(validatePlannerEntry('Meeting', 24), isNotNull);
      expect(validatePlannerEntry('Meeting', 9), isNull);
    });
  });

  group('Planner widget', () {
    testWidgets("renders today's schedule and navigates days", (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Provide an empty entries list so the stream resolves immediately.
            plannerEntriesProvider.overrideWith((_) => Stream.value([])),
          ],
          child: MaterialApp(
            theme: SovereignTheme.dark,
            home: const PlannerScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Planner shows day navigation arrows
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      // Has an add-entry FAB
      expect(find.byKey(const Key('add_entry_fab')), findsOneWidget);
    });
  });
}
