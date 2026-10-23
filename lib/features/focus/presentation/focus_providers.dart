import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovereign/core/supabase/supabase_providers.dart';
import 'package:sovereign/features/focus/data/supabase_focus_repository.dart';
import 'package:sovereign/features/focus/domain/focus_repository.dart';
import 'package:sovereign/features/focus/domain/focus_session.dart';
import 'package:sovereign/features/focus/domain/focus_timer.dart';

export 'package:sovereign/features/focus/domain/focus_repository.dart';
export 'package:sovereign/features/focus/domain/focus_session.dart';
export 'package:sovereign/features/focus/domain/focus_timer.dart';

/// Provides clock function returning DateTime.now(), overridden in tests.
final clockProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

/// Provides active [FocusRepository].
final focusRepositoryProvider = Provider<FocusRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseFocusRepository(client);
});

/// Streams logged focus sessions.
final focusSessionsStreamProvider = StreamProvider<List<FocusSession>>((ref) {
  final repo = ref.watch(focusRepositoryProvider);
  return repo.watchSessions();
});

/// Controller managing focus timer state machine and saving sessions.
class FocusTimerController extends Notifier<FocusTimerState> {
  @override
  FocusTimerState build() => const FocusTimerState();

  void start({
    String? taskId,
    Duration? focusLength,
    Duration? restLength,
  }) {
    final now = ref.read(clockProvider)();
    state = state.copyWith(
      phase: FocusPhase.focus,
      startedAt: now,
      taskId: taskId,
      focusLength: focusLength ?? state.focusLength,
      restLength: restLength ?? state.restLength,
    );
  }

  Future<void> cancel() async {
    if (state.phase == FocusPhase.idle || state.startedAt == null) return;

    final now = ref.read(clockProvider)();
    final elapsedSeconds = now.difference(state.startedAt!).inSeconds;

    // Only save when elapsed is over 60 seconds
    if (elapsedSeconds > 60) {
      final session = FocusSession(
        id: '',
        taskId: state.taskId,
        startedAt: state.startedAt!,
        durationSeconds: elapsedSeconds,
        completed: false,
      );
      await ref.read(focusRepositoryProvider).saveSession(session);
    }

    state = state.copyWith(
      phase: FocusPhase.idle,
      clearStartedAt: true,
      clearTaskId: true,
    );
  }

  Future<void> completeIfDue(DateTime now) async {
    if (state.phase != FocusPhase.focus || state.startedAt == null) return;

    final remainingDuration = state.remaining(now);
    if (remainingDuration == Duration.zero) {
      final session = FocusSession(
        id: '',
        taskId: state.taskId,
        startedAt: state.startedAt!,
        durationSeconds: state.focusLength.inSeconds,
        completed: true,
      );

      // Transition phase to finished immediately to avoid double saves
      state = state.copyWith(phase: FocusPhase.finished);

      await ref.read(focusRepositoryProvider).saveSession(session);
    }
  }

  void reset() {
    state = state.copyWith(
      phase: FocusPhase.idle,
      clearStartedAt: true,
      clearTaskId: true,
    );
  }
}

final focusTimerProvider =
    NotifierProvider<FocusTimerController, FocusTimerState>(
  FocusTimerController.new,
);
