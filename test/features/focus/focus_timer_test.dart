import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sovereign/features/focus/presentation/focus_providers.dart';

import '../../support/fakes.dart';

void main() {
  group('Focus timer & Review Focus 4', () {
    test('default lengths are 25 and 5 minutes', () {
      final state = FocusTimerState();
      expect(state.focusLength, const Duration(minutes: 25));
      expect(state.restLength, const Duration(minutes: 5));
      expect(state.phase, FocusPhase.idle);
    });

    test('Review Focus 4: remaining time comes from timestamps, not tick counts', () {
      final start = DateTime(2026, 10, 23, 10, 0, 0);
      final state = FocusTimerState(
        phase: FocusPhase.focus,
        startedAt: start,
        focusLength: const Duration(minutes: 25),
        restLength: const Duration(minutes: 5),
      );

      // 10 minutes later (e.g. app was suspended / backgrounded)
      final tenMinutesLater = start.add(const Duration(minutes: 10));
      expect(state.remaining(tenMinutesLater), const Duration(minutes: 15));
      expect(state.phaseAt(tenMinutesLater), FocusPhase.focus);

      // 3 hours later (e.g. overnight / long sleep)
      final threeHoursLater = start.add(const Duration(hours: 3));
      expect(state.remaining(threeHoursLater), Duration.zero);
      expect(state.phaseAt(threeHoursLater), isNot(FocusPhase.focus));
    });

    test('completeIfDue called twice saves exactly one completed session of 1500s', () async {
      final fakeRepo = FakeFocusRepository();
      var fakeNow = DateTime(2026, 10, 23, 10, 0, 0);

      final container = ProviderContainer(
        overrides: [
          focusRepositoryProvider.overrideWithValue(fakeRepo),
          clockProvider.overrideWithValue(() => fakeNow),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(focusTimerProvider.notifier);
      controller.start(focusLength: const Duration(minutes: 25));

      // Fast forward time past 25 minutes
      fakeNow = fakeNow.add(const Duration(minutes: 26));

      await controller.completeIfDue(fakeNow);
      await controller.completeIfDue(fakeNow);

      expect(fakeRepo.savedSessions.length, 1);
      final saved = fakeRepo.savedSessions.first;
      expect(saved.completed, isTrue);
      expect(saved.durationSeconds, 1500);
    });

    test('cancel saves completed: false session only when elapsed > 60 seconds', () async {
      final fakeRepo = FakeFocusRepository();
      var fakeNow = DateTime(2026, 10, 23, 10, 0, 0);

      final container = ProviderContainer(
        overrides: [
          focusRepositoryProvider.overrideWithValue(fakeRepo),
          clockProvider.overrideWithValue(() => fakeNow),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(focusTimerProvider.notifier);

      // Cancel under 60 seconds -> no session saved
      controller.start();
      fakeNow = fakeNow.add(const Duration(seconds: 30));
      await controller.cancel();
      expect(fakeRepo.savedSessions, isEmpty);

      // Cancel after 90 seconds -> saved session with completed: false, 90s
      controller.start();
      fakeNow = fakeNow.add(const Duration(seconds: 90));
      await controller.cancel();
      expect(fakeRepo.savedSessions.length, 1);
      expect(fakeRepo.savedSessions.first.completed, isFalse);
      expect(fakeRepo.savedSessions.first.durationSeconds, 90);
    });
  });
}
