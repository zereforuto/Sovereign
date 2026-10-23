import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovereign/core/theme/colors.dart';
import 'package:sovereign/core/widgets/async_value_view.dart';
import 'package:sovereign/features/habits/presentation/habit_providers.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final selectedDays = <int>{1, 2, 3, 4, 5, 6, 7};

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

            return AlertDialog(
              title: const Text('NEW DISCIPLINE'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const Key('new_habit_name_field'),
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'HABIT NAME'),
                  ),
                  const SizedBox(height: 16),
                  const Text('SCHEDULE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final dayNum = i + 1;
                      final isSelected = selectedDays.contains(dayNum);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              if (selectedDays.length > 1) selectedDays.remove(dayNum);
                            } else {
                              selectedDays.add(dayNum);
                            }
                          });
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? SovereignColors.rossoCorsa
                                : SovereignColors.surfaceDark,
                            border: Border.all(
                              color: isSelected
                                  ? SovereignColors.rossoCorsa
                                  : SovereignColors.grayDark,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            dayLabels[i],
                            style: TextStyle(
                              color: SovereignColors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  key: const Key('create_habit_submit_button'),
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      ref.read(habitRepositoryProvider).create(
                            Habit(id: '', name: name, weekdays: selectedDays),
                          );
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: const Text('CREATE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWeeklyDots(Set<DateTime> checkins, Set<int> weekdays) {
    final today = dateOnly(DateTime.now());
    // Start of current week (Monday)
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(7, (i) {
        final dayDate = startOfWeek.add(Duration(days: i));
        final dayNum = i + 1;
        final isScheduled = weekdays.contains(dayNum);
        final isChecked = checkins.contains(dayDate);
        final isCurrentDay = dayDate == today;

        Color dotColor;
        if (!isScheduled) {
          dotColor = SovereignColors.surfaceDark;
        } else if (isChecked) {
          dotColor = SovereignColors.rossoCorsa;
        } else if (dayDate.isBefore(today)) {
          dotColor = SovereignColors.grayDark;
        } else {
          dotColor = SovereignColors.black;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrentDay
                  ? SovereignColors.white
                  : isScheduled
                      ? SovereignColors.grayDark
                      : Colors.transparent,
              width: 1,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(habitSummariesProvider);
    final today = dateOnly(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('HABITS & DISCIPLINE'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AsyncValueView<List<HabitSummary>>(
        value: summariesAsync,
        data: (summaries) {
          if (summaries.isEmpty) {
            return const Center(
              child: Text(
                'No habits defined yet',
                style: TextStyle(color: SovereignColors.grayMid),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: summaries.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: SovereignColors.surfaceDark),
            itemBuilder: (context, index) {
              final item = summaries[index];
              final hasFlame = item.streaks.current >= 7;
              final isMilestone = item.streaks.current == 7 ||
                  item.streaks.current == 30 ||
                  item.streaks.current >= 100;

              return ListTile(
                leading: IconButton(
                  key: Key('habit_toggle_${item.habit.id}'),
                  icon: Icon(
                    item.isCheckedToday
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: item.isCheckedToday
                        ? SovereignColors.rossoCorsa
                        : SovereignColors.grayMid,
                    size: 26,
                  ),
                  onPressed: () {
                    ref.read(habitRepositoryProvider).setCheckin(
                          item.habit.id,
                          today,
                          !item.isCheckedToday,
                        );
                  },
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.habit.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (hasFlame)
                      Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Icon(
                          Icons.local_fire_department,
                          color: isMilestone
                              ? SovereignColors.racingYellow
                              : SovereignColors.rossoCorsa,
                          size: 20,
                        ),
                      ),
                    Text(
                      '${item.streaks.current}d',
                      style: TextStyle(
                        color: isMilestone
                            ? SovereignColors.racingYellow
                            : SovereignColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Best: ${item.streaks.longest}d',
                        style: const TextStyle(
                          fontSize: 12,
                          color: SovereignColors.graySilver,
                        ),
                      ),
                      _buildWeeklyDots(item.checkins, item.habit.weekdays),
                    ],
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.archive_outlined, size: 20),
                  onPressed: () {
                    ref.read(habitRepositoryProvider).archive(item.habit.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_habit_fab'),
        backgroundColor: SovereignColors.rossoCorsa,
        foregroundColor: SovereignColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
