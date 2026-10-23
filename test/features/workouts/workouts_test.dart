import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sovereign/core/theme/sovereign_theme.dart';
import 'package:sovereign/features/settings/domain/weight_unit.dart';
import 'package:sovereign/features/workouts/presentation/workout_logger_screen.dart';
import 'package:sovereign/features/workouts/presentation/workout_providers.dart';

import '../../support/fakes.dart';

void main() {
  group('Workout logic & Review Focus 5', () {
    test('validateWorkout rejects no exercises and an exercise with zero sets', () {
      final emptyWorkout = Workout(
        id: '',
        startedAt: DateTime.now(),
        notes: '',
        exercises: [],
      );
      expect(validateWorkout(emptyWorkout), isNotNull);

      final noSetsWorkout = Workout(
        id: '',
        startedAt: DateTime.now(),
        notes: '',
        exercises: [
          const WorkoutExercise(name: 'Bench Press', sets: []),
        ],
      );
      expect(validateWorkout(noSetsWorkout), isNotNull);

      final validWorkout = Workout(
        id: '',
        startedAt: DateTime.now(),
        notes: '',
        exercises: [
          const WorkoutExercise(
            name: 'Bench Press',
            sets: [
              WorkoutSet(setNumber: 1, reps: 8, weight: 80, unit: WeightUnit.kg),
            ],
          ),
        ],
      );
      expect(validateWorkout(validWorkout), isNull);
    });

    test('validateSet rejects invalid reps and invalid weights', () {
      expect(validateSet(0, '50'), isNotNull);
      expect(validateSet(-3, ''), isNotNull);
      expect(validateSet(5, 'abc'), isNotNull);
      expect(validateSet(5, '-2'), isNotNull);

      expect(validateSet(5, ''), isNull);
      expect(validateSet(5, '62.5'), isNull);
    });

    test('weekly consistency computes workouts this week and streaks', () {
      // Current date: Wednesday 2026-10-21 (Week starts Monday 2026-10-19)
      final now = DateTime(2026, 10, 21, 14, 0);

      // Workouts this week (Monday 2026-10-19)
      final w1 = Workout(
        id: 'w1',
        startedAt: DateTime(2026, 10, 19, 10, 0),
        notes: '',
        exercises: [
          const WorkoutExercise(
            name: 'Squat',
            sets: [WorkoutSet(setNumber: 1, reps: 5, weight: 100, unit: WeightUnit.kg)],
          ),
        ],
      );

      // Workout previous week (2026-10-14)
      final w2 = Workout(
        id: 'w2',
        startedAt: DateTime(2026, 10, 14, 10, 0),
        notes: '',
        exercises: [
          const WorkoutExercise(
            name: 'Bench',
            sets: [WorkoutSet(setNumber: 1, reps: 5, weight: 80, unit: WeightUnit.kg)],
          ),
        ],
      );

      // Workout 2 weeks ago (2026-10-07)
      final w3 = Workout(
        id: 'w3',
        startedAt: DateTime(2026, 10, 7, 10, 0),
        notes: '',
        exercises: [
          const WorkoutExercise(
            name: 'Deadlift',
            sets: [WorkoutSet(setNumber: 1, reps: 5, weight: 140, unit: WeightUnit.kg)],
          ),
        ],
      );

      final consistency3 = computeWeeklyConsistency([w1, w2, w3], now);
      expect(consistency3.workoutsThisWeek, 1);
      expect(consistency3.weeklyStreak, 3);

      // Gap week breaks streak to 1 (only this week)
      final wOld = Workout(
        id: 'wOld',
        startedAt: DateTime(2026, 9, 1, 10, 0),
        notes: '',
        exercises: [
          const WorkoutExercise(
            name: 'Deadlift',
            sets: [WorkoutSet(setNumber: 1, reps: 5, weight: 140, unit: WeightUnit.kg)],
          ),
        ],
      );
      final consistencyGap = computeWeeklyConsistency([w1, wOld], now);
      expect(consistencyGap.workoutsThisWeek, 1);
      expect(consistencyGap.weeklyStreak, 1);
    });

    test('lastSetsFor returns the most recent workout sets for exercise', () {
      final olderWorkout = Workout(
        id: 'wOld',
        startedAt: DateTime(2026, 10, 10),
        notes: '',
        exercises: [
          const WorkoutExercise(
            name: 'Squat',
            sets: [WorkoutSet(setNumber: 1, reps: 5, weight: 90, unit: WeightUnit.kg)],
          ),
        ],
      );

      final newerWorkout = Workout(
        id: 'wNew',
        startedAt: DateTime(2026, 10, 15),
        notes: '',
        exercises: [
          const WorkoutExercise(
            name: 'Squat',
            sets: [WorkoutSet(setNumber: 1, reps: 5, weight: 100, unit: WeightUnit.kg)],
          ),
        ],
      );

      final last = lastSetsFor('Squat', [olderWorkout, newerWorkout]);
      expect(last.length, 1);
      expect(last.first.weight, 100);
    });

    test('exerciseSuggestions is case-insensitive and de-duplicated', () {
      final history = [
        Workout(
          id: '1',
          startedAt: DateTime.now(),
          notes: '',
          exercises: [
            const WorkoutExercise(name: 'Squat', sets: []),
            const WorkoutExercise(name: 'squat', sets: []),
            const WorkoutExercise(name: 'SQUAT JUMP', sets: []),
            const WorkoutExercise(name: 'Bench Press', sets: []),
          ],
        ),
      ];

      final suggestions = exerciseSuggestions(history, 'sq');
      expect(suggestions, ['Squat', 'SQUAT JUMP']);
    });
  });

  group('Workout logger widget test & Review Focus 5', () {
    testWidgets('Finish on empty workout shows message and does not call saveWorkout',
        (tester) async {
      final fakeRepo = FakeWorkoutRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            theme: SovereignTheme.dark,
            home: const WorkoutLoggerScreen(),
          ),
        ),
      );

      final finishBtn = find.byKey(const Key('finish_workout_button'));
      expect(finishBtn, findsOneWidget);

      await tester.tap(finishBtn);
      await tester.pumpAndSettle();

      expect(find.text('Add at least one exercise with sets'), findsOneWidget);
      expect(fakeRepo.savedWorkouts, isEmpty);
    });
  });
}
