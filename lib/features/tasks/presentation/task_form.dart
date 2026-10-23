import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovereign/features/tasks/presentation/task_providers.dart';

class TaskFormSheet extends ConsumerStatefulWidget {
  const TaskFormSheet({super.key, this.taskToEdit});

  final TodoTask? taskToEdit;

  @override
  ConsumerState<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late TaskPriority _priority;
  DateTime? _dueAt;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _notesController = TextEditingController(text: widget.taskToEdit?.notes ?? '');
    _priority = widget.taskToEdit?.priority ?? TaskPriority.medium;
    _dueAt = widget.taskToEdit?.dueAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(taskRepositoryProvider);
      if (widget.taskToEdit != null) {
        final updated = widget.taskToEdit!.copyWith(
          title: _titleController.text.trim(),
          notes: _notesController.text.trim(),
          priority: _priority,
          dueAt: _dueAt,
          clearDueAt: _dueAt == null,
        );
        await repo.update(updated);
      } else {
        final draft = TodoTask(
          id: '',
          title: _titleController.text.trim(),
          notes: _notesController.text.trim(),
          priority: _priority,
          dueAt: _dueAt,
        );
        await repo.create(draft);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.taskToEdit != null ? 'EDIT TASK' : 'NEW TASK',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('task_title_field'),
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'TITLE'),
                validator: validateTaskTitle,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('task_notes_field'),
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'NOTES (OPTIONAL)'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('PRIORITY: ', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  DropdownButton<TaskPriority>(
                    value: _priority,
                    onChanged: (p) => setState(() => _priority = p!),
                    items: TaskPriority.values.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(p.name.toUpperCase()),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                key: const Key('task_save_button'),
                onPressed: _isLoading ? null : _save,
                child: Text(widget.taskToEdit != null ? 'UPDATE' : 'CREATE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
