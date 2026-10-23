import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovereign/core/theme/colors.dart';
import 'package:sovereign/features/settings/presentation/settings_providers.dart';
import 'package:sovereign/features/workouts/presentation/workout_providers.dart';

class WorkoutLoggerScreen extends ConsumerStatefulWidget {
  const WorkoutLoggerScreen({super.key});

  @override
  ConsumerState<WorkoutLoggerScreen> createState() => _WorkoutLoggerScreenState();
}

class _WorkoutLoggerScreenState extends ConsumerState<WorkoutLoggerScreen> {
  final DateTime _startedAt = DateTime.now();
  final TextEditingController _nameController = TextEditingController(text: 'WORKOUT');
  final TextEditingController _notesController = TextEditingController();
  final List<WorkoutExercise> _exercises = [];
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addExerciseDialog() {
    final nameController = TextEditingController();
    final workouts = ref.read(workoutsStreamProvider).value ?? [];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final suggestions = exerciseSuggestions(workouts, nameController.text);

            return AlertDialog(
              title: const Text('ADD EXERCISE'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    autofocus: true,
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'EXERCISE NAME'),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  if (suggestions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('SUGGESTIONS', style: TextStyle(fontSize: 10, letterSpacing: 1)),
                    Wrap(
                      spacing: 6,
                      children: suggestions.take(5).map((s) {
                        return ActionChip(
                          label: Text(s),
                          onPressed: () {
                            nameController.text = s;
                            setDialogState(() {});
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      setState(() {
                        _exercises.add(WorkoutExercise(name: name, sets: []));
                      });
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: const Text('ADD'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addSet(int exerciseIndex) {
    final currentUnit = ref.read(weightUnitProvider);
    final exercise = _exercises[exerciseIndex];
    final history = ref.read(workoutsStreamProvider).value ?? [];
    final lastSets = lastSetsFor(exercise.name, history);

    // Autofill from previous set in this exercise or last-time reference
    int defaultReps = 10;
    double? defaultWeight;
    if (exercise.sets.isNotEmpty) {
      defaultReps = exercise.sets.last.reps;
      defaultWeight = exercise.sets.last.weight;
    } else if (lastSets.isNotEmpty) {
      defaultReps = lastSets.first.reps;
      defaultWeight = lastSets.first.weight;
    }

    final repsController = TextEditingController(text: defaultReps.toString());
    final weightController = TextEditingController(
      text: defaultWeight != null ? defaultWeight.toString() : '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        String? setValidationError;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('LOG SET #${exercise.sets.length + 1} - ${exercise.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (setValidationError != null) ...[
                    Text(
                      setValidationError!,
                      style: const TextStyle(color: SovereignColors.warning, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                  ],
                  TextField(
                    key: const Key('set_reps_field'),
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'REPS'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('set_weight_field'),
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'WEIGHT (${currentUnit.name.toUpperCase()})',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final reps = int.tryParse(repsController.text) ?? 0;
                    final weightText = weightController.text;
                    final err = validateSet(reps, weightText);
                    if (err != null) {
                      setDialogState(() => setValidationError = err);
                      return;
                    }

                    final weight = weightText.trim().isNotEmpty
                        ? double.tryParse(weightText.trim())
                        : null;

                    setState(() {
                      final updatedSets = [
                        ...exercise.sets,
                        WorkoutSet(
                          setNumber: exercise.sets.length + 1,
                          reps: reps,
                          weight: weight,
                          unit: currentUnit,
                        ),
                      ];
                      _exercises[exerciseIndex] = exercise.copyWith(sets: updatedSets);
                    });
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('LOG SET'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _finishWorkout() async {
    final workout = Workout(
      id: '',
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
      startedAt: _startedAt,
      endedAt: DateTime.now(),
      notes: _notesController.text.trim(),
      exercises: _exercises,
    );

    final error = validateWorkout(workout);
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await ref.read(workoutRepositoryProvider).saveWorkout(workout);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(workoutsStreamProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('LOG WORKOUT'),
        actions: [
          IconButton(
            key: const Key('finish_workout_button'),
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: SovereignColors.white,
                    ),
                  )
                : const Icon(Icons.check, color: SovereignColors.rossoCorsa),
            onPressed: _isSaving ? null : _finishWorkout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SovereignColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: SovereignColors.warning),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: SovereignColors.warning, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
            ],

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'WORKOUT NAME'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'NOTES (OPTIONAL)'),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'EXERCISES',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
                ElevatedButton.icon(
                  key: const Key('add_exercise_button'),
                  onPressed: _addExerciseDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('ADD EXERCISE'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_exercises.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text(
                    'No exercises added yet',
                    style: TextStyle(color: SovereignColors.grayMid),
                  ),
                ),
              ),

            ..._exercises.asMap().entries.map((entry) {
              final idx = entry.key;
              final exercise = entry.value;
              final lastSets = lastSetsFor(exercise.name, history);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            exercise.name.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () {
                              setState(() => _exercises.removeAt(idx));
                            },
                          ),
                        ],
                      ),
                      if (lastSets.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Last time: ${lastSets.map((s) => '${s.reps}x${s.weight ?? 0}${s.unit.name}').join(', ')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: SovereignColors.racingYellow,
                            ),
                          ),
                        ),
                      ...exercise.sets.map((s) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Text('Set ${s.setNumber}:',
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              Text('${s.reps} reps'),
                              if (s.weight != null) ...[
                                const SizedBox(width: 8),
                                Text('@ ${s.weight} ${s.unit.name.toUpperCase()}'),
                              ],
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        key: Key('add_set_button_$idx'),
                        onPressed: () => _addSet(idx),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('ADD SET'),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
