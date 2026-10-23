import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sovereign/core/theme/sovereign_theme.dart';
import 'package:sovereign/features/habits/presentation/habit_providers.dart';
import 'package:sovereign/features/habits/presentation/habits_screen.dart';

import '../../support/fakes.dart';

void main() {
  group('Habits streaks & Review Focus 2 & 3', () {
    test('dateOnly strips hours and minutes', () {
      final dt = DateTime(2026, 10, 23, 23, 59);
      expect(dateOnly(dt), DateTime(2026, 10, 23));
    });

    test('daily habit checked the last 3 days gives current == 3', () {
      final habit = Habit(id: 'h1', name: 'Hydrate', weekdays: {1, 2, 3, 4, 5, 6, 7});
      final today = DateTime(2026, 10, 23); // Friday
      final checkins = {
        DateTime(2026, 10, 21),
        DateTime(2026, 10, 22),
        DateTime(2026, 10, 23),
      };

      final streaks = computeStreaks(habit, checkins, today);
      expect(streaks.current, 3);
      expect(streaks.longest, 3);
    });

    test('today unchecked but yesterday checked keeps the streak', () {
      final habit = Habit(id: 'h2', name: 'Read', weekdays: {1, 2, 3, 4, 5, 6, 7});
      final today = DateTime(2026, 10, 23);
      final checkins = {
        DateTime(2026, 10, 21),
        DateTime(2026, 10, 22),
      };

      final streaks = computeStreaks(habit, checkins, today);
      expect(streaks.current, 2);
      expect(streaks.longest, 2);
    });

    test('Review Focus 3: Mon/Wed/Fri habit checked Mon, Wed, Fri keeps streak across weekend', () {
      // 2026-10-19: Mon, 21: Wed, 23: Fri, 24: Sat, 25: Sun, 26: Mon
      final habit = Habit(id: 'h3', name: 'Gym', weekdays: {1, 3, 5}); // Mon, Wed, Fri
      final checkins = {
        DateTime(2026, 10, 19),
        DateTime(2026, 10, 21),
        DateTime(2026, 10, 23),
      };

      // Sunday 2026-10-25: unscheduled day
      final sunday = DateTime(2026, 10, 25);
      final streaksSun = computeStreaks(habit, checkins, sunday);
      expect(streaksSun.current, 3);

      // Monday 2026-10-26 before checking in today: yesterday was Sun (unscheduled), Fri was checked
      final monday = DateTime(2026, 10, 26);
      final streaksMon = computeStreaks(habit, checkins, monday);
      expect(streaksMon.current, 3);
    });

    test('a missed scheduled day resets current to 0 but keeps longest', () {
      final habit = Habit(id: 'h4', name: 'Run', weekdays: {1, 2, 3, 4, 5, 6, 7});
      final today = DateTime(2026, 10, 23); // Friday
      final checkins = {
        DateTime(2026, 10, 10),
        DateTime(2026, 10, 11),
        DateTime(2026, 10, 12),
        DateTime(2026, 10, 13), // 4 streak in past
        // Gap until today: today not checked, yesterday not checked
      };

      final streaks = computeStreaks(habit, checkins, today);
      expect(streaks.current, 0);
      expect(streaks.longest, 4);
    });
  });

  group('Habits screen widget test & Review Focus 2', () {
    testWidgets('tapping habit calls setCheckin(id, today, true), tapping again false',
        (tester) async {
      final today = dateOnly(DateTime.now());
      final habit = Habit(
        id: 'habit-1',
        name: 'Cold Shower',
        weekdays: {1, 2, 3, 4, 5, 6, 7},
      );
      final fakeRepo = FakeHabitRepository(initialHabits: [habit]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            theme: SovereignTheme.dark,
            home: const HabitsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final toggleFinder = find.byKey(const Key('habit_toggle_habit-1'));
      expect(toggleFinder, findsOneWidget);

      // First tap -> check in
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      expect(fakeRepo.checkinCalls.length, 1);
      expect(fakeRepo.checkinCalls.first, 'habit-1:$today:true');

      // Second tap -> toggle off (Review Focus 2)
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      expect(fakeRepo.checkinCalls.length, 2);
      expect(fakeRepo.checkinCalls.last, 'habit-1:$today:false');
    });
  });
}
