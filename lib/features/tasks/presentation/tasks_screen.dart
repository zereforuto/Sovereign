import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovereign/core/theme/colors.dart';
import 'package:sovereign/core/widgets/async_value_view.dart';
import 'package:sovereign/features/tasks/presentation/task_form.dart';
import 'package:sovereign/features/tasks/presentation/task_providers.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  void _showForm(BuildContext context, [TodoTask? task]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (_) => TaskFormSheet(taskToEdit: task),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final activeFilter = ref.watch(taskFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TASKS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: TaskFilter.values.map((filter) {
                final isSelected = filter == activeFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filter.name.toUpperCase()),
                    selected: isSelected,
                    selectedColor: SovereignColors.rossoCorsa,
                    onSelected: (_) {
                      ref.read(taskFilterProvider.notifier).setFilter(filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: SovereignColors.surfaceDark),
          Expanded(
            child: AsyncValueView<List<TodoTask>>(
              value: tasksAsync,
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tasks in this view',
                      style: TextStyle(color: SovereignColors.grayMid),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: SovereignColors.surfaceDark),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      leading: Checkbox(
                        key: Key('task_checkbox_${task.id}'),
                        value: task.isDone,
                        activeColor: SovereignColors.rossoCorsa,
                        onChanged: (bool? val) {
                          ref
                              .read(taskRepositoryProvider)
                              .setCompleted(task.id, val ?? false);
                        },
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration:
                              task.isDone ? TextDecoration.lineThrough : null,
                          color: task.isDone
                              ? SovereignColors.grayMid
                              : SovereignColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: task.notes.isNotEmpty
                          ? Text(
                              task.notes,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: SovereignColors.grayMid),
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: task.priority == TaskPriority.high
                                  ? SovereignColors.rossoCorsa.withValues(alpha: 0.2)
                                  : SovereignColors.surfaceDark,
                              border: Border.all(
                                color: task.priority == TaskPriority.high
                                    ? SovereignColors.rossoCorsa
                                    : SovereignColors.grayDark,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              task.priority.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: task.priority == TaskPriority.high
                                    ? SovereignColors.rossoCorsa
                                    : SovereignColors.graySilver,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () {
                              ref.read(taskRepositoryProvider).delete(task.id);
                            },
                          ),
                        ],
                      ),
                      onTap: () => _showForm(context, task),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_task_fab'),
        backgroundColor: SovereignColors.rossoCorsa,
        foregroundColor: SovereignColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
