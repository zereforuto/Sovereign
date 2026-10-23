enum FocusPhase {
  idle,
  focus,
  rest,
  finished,
}

/// Pure domain state for Focus timer.
/// Review Focus 4: Remaining time comes from timestamps, not tick counts.
class FocusTimerState {
  final FocusPhase phase;
  final DateTime? startedAt;
  final Duration focusLength;
  final Duration restLength;
  final String? taskId;

  const FocusTimerState({
    this.phase = FocusPhase.idle,
    this.startedAt,
    this.focusLength = const Duration(minutes: 25),
    this.restLength = const Duration(minutes: 5),
    this.taskId,
  });

  FocusTimerState copyWith({
    FocusPhase? phase,
    DateTime? startedAt,
    Duration? focusLength,
    Duration? restLength,
    String? taskId,
    bool clearStartedAt = false,
    bool clearTaskId = false,
  }) {
    return FocusTimerState(
      phase: phase ?? this.phase,
      startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
      focusLength: focusLength ?? this.focusLength,
      restLength: restLength ?? this.restLength,
      taskId: clearTaskId ? null : (taskId ?? this.taskId),
    );
  }

  /// Calculates remaining time dynamically based on [now] and [startedAt].
  Duration remaining(DateTime now) {
    if (startedAt == null || phase == FocusPhase.idle) {
      return focusLength;
    }

    final targetLength = phase == FocusPhase.focus ? focusLength : restLength;
    final elapsed = now.difference(startedAt!);

    if (elapsed >= targetLength) {
      return Duration.zero;
    }
    return targetLength - elapsed;
  }

  /// Derives phase dynamically based on [now] and [startedAt].
  FocusPhase phaseAt(DateTime now) {
    if (startedAt == null || phase == FocusPhase.idle) {
      return FocusPhase.idle;
    }
    final targetLength = phase == FocusPhase.focus ? focusLength : restLength;
    final elapsed = now.difference(startedAt!);

    if (elapsed >= targetLength) {
      return FocusPhase.finished;
    }
    return phase;
  }
}
