import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovereign/core/theme/colors.dart';
import 'package:sovereign/core/widgets/async_value_view.dart';
import 'package:sovereign/features/focus/presentation/focus_providers.dart';
import 'package:sovereign/features/tasks/presentation/task_providers.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Solely triggers UI rebuilds every second; all remaining time comes from timestamps
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        final now = ref.read(clockProvider)();
        final timerState = ref.read(focusTimerProvider);
        if (timerState.phase == FocusPhase.focus) {
          ref.read(focusTimerProvider.notifier).completeIfDue(now);
        }
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(focusTimerProvider);
    final tasksAsync = ref.watch(tasksProvider);
    final sessionsAsync = ref.watch(focusSessionsStreamProvider);
    final now = ref.watch(clockProvider)();
    final remaining = timerState.remaining(now);
    final isFinished = timerState.phase == FocusPhase.finished;
    final isRunning = timerState.phase == FocusPhase.focus;

    final totalSeconds = timerState.focusLength.inSeconds;
    final progress = totalSeconds > 0
        ? (remaining.inSeconds / totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FOCUS TIMER'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // Task Picker
            tasksAsync.when(
              data: (tasks) {
                final activeTasks = tasks.where((t) => !t.isDone).toList();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: SovereignColors.surfaceDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: DropdownButton<String?>(
                    value: timerState.taskId,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    hint: const Text('LINK TO TASK (OPTIONAL)'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('NO TASK LINKED')),
                      ...activeTasks.map((t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(t.title, overflow: TextOverflow.ellipsis),
                          )),
                    ],
                    onChanged: isRunning
                        ? null
                        : (val) {
                            ref.read(focusTimerProvider.notifier).start(taskId: val);
                          },
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),

            // Countdown dial (Ferrari Red progress, Yellow on finished)
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 240,
                  height: 240,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: SovereignColors.surfaceDark,
                    color: isFinished
                        ? SovereignColors.racingYellow
                        : SovereignColors.rossoCorsa,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDuration(remaining),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: isFinished
                            ? SovereignColors.racingYellow
                            : SovereignColors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isFinished
                          ? 'SESSION COMPLETED!'
                          : isRunning
                              ? 'IN THE ZONE'
                              : 'READY TO ENGAGE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: isFinished
                            ? SovereignColors.racingYellow
                            : SovereignColors.graySilver,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isRunning && !isFinished)
                  ElevatedButton.icon(
                    key: const Key('start_focus_button'),
                    onPressed: () {
                      ref.read(focusTimerProvider.notifier).start();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('START FOCUS'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                  ),
                if (isRunning)
                  OutlinedButton.icon(
                    key: const Key('cancel_focus_button'),
                    onPressed: () {
                      ref.read(focusTimerProvider.notifier).cancel();
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('CANCEL SESSION'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SovereignColors.warning,
                      side: const BorderSide(color: SovereignColors.warning),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                  ),
                if (isFinished)
                  ElevatedButton.icon(
                    key: const Key('reset_focus_button'),
                    onPressed: () {
                      ref.read(focusTimerProvider.notifier).reset();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('NEXT SESSION'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SovereignColors.racingYellow,
                      foregroundColor: SovereignColors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 40),

            // Session History Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'RECENT SESSIONS',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            AsyncValueView<List<FocusSession>>(
              value: sessionsAsync,
              data: (sessions) {
                if (sessions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'No focus sessions logged yet',
                      style: TextStyle(color: SovereignColors.grayMid),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sessions.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: SovereignColors.surfaceDark),
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final minutes = (session.durationSeconds / 60).round();
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        session.completed
                            ? Icons.check_circle
                            : Icons.cancel_outlined,
                        color: session.completed
                            ? SovereignColors.success
                            : SovereignColors.warning,
                      ),
                      title: Text(
                        '${session.completed ? 'Focus Completed' : 'Aborted'} ($minutes min)',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        session.startedAt.toLocal().toString().substring(0, 16),
                        style: const TextStyle(fontSize: 12, color: SovereignColors.grayMid),
                      ),
                      trailing: session.completed
                          ? const Icon(Icons.star, color: SovereignColors.racingYellow, size: 18)
                          : null,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
