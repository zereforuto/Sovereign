import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovereign/core/theme/colors.dart';
import 'package:sovereign/core/widgets/async_value_view.dart';
import 'package:sovereign/features/workouts/presentation/workout_logger_screen.dart';
import 'package:sovereign/features/workouts/presentation/workout_providers.dart';

class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutsStreamProvider);
    final consistency = ref.watch(weeklyConsistencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WORKOUTS & CONDITIONING'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Weekly Consistency Card (Racing Yellow for high streaks)
            Card(
              color: SovereignColors.surfaceDark,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${consistency.workoutsThisWeek}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: SovereignColors.rossoCorsa,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'THIS WEEK',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: SovereignColors.graySilver,
                          ),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 48, color: SovereignColors.grayDark),
                    Column(
                      children: [
                        Row(
                          children: [
                            if (consistency.weeklyStreak >= 4)
                              const Padding(
                                padding: EdgeInsets.only(right: 4.0),
                                child: Icon(
                                  Icons.star,
                                  color: SovereignColors.racingYellow,
                                  size: 24,
                                ),
                              ),
                            Text(
                              '${consistency.weeklyStreak}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: consistency.weeklyStreak >= 4
                                    ? SovereignColors.racingYellow
                                    : SovereignColors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'WEEK STREAK',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: SovereignColors.graySilver,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'WORKOUT LOGS',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 12),

            AsyncValueView<List<Workout>>(
              value: workoutsAsync,
              data: (workouts) {
                if (workouts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        'No workouts completed yet',
                        style: TextStyle(color: SovereignColors.grayMid),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: workouts.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: SovereignColors.surfaceDark),
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    final dateStr =
                        workout.startedAt.toLocal().toString().substring(0, 16);

                    return ExpansionTile(
                      leading: const Icon(
                        Icons.fitness_center,
                        color: SovereignColors.rossoCorsa,
                      ),
                      title: Text(
                        workout.name ?? 'Workout',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '$dateStr • ${workout.exercises.length} exercises',
                        style: const TextStyle(fontSize: 12, color: SovereignColors.grayMid),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () {
                          ref.read(workoutRepositoryProvider).delete(workout.id);
                        },
                      ),
                      children: workout.exercises.map((ex) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: SovereignColors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ex.sets
                                    .map((s) =>
                                        '${s.reps} reps${s.weight != null ? ' @ ${s.weight}${s.unit.name}' : ''}')
                                    .join('  |  '),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: SovereignColors.graySilver,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('start_workout_fab'),
        backgroundColor: SovereignColors.rossoCorsa,
        foregroundColor: SovereignColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const WorkoutLoggerScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
