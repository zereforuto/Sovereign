import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sovereign/core/theme/colors.dart';
import 'package:sovereign/core/widgets/async_value_view.dart';
import 'package:sovereign/features/planner/data/supabase_planner_repository.dart';
import 'package:sovereign/features/planner/presentation/planner_providers.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  DateTime _selectedDate = DateTime.now();

  DateTime get _dateOnly =>
      DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

  void _previousDay() =>
      setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));

  void _nextDay() =>
      setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));

  bool _isToday() {
    final now = DateTime.now();
    return _dateOnly == DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(plannerEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DAILY PLANNER'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Day navigation header ──
          _DayNavBar(
            selectedDate: _selectedDate,
            isToday: _isToday(),
            onPrev: _previousDay,
            onNext: _nextDay,
            onTodayTap: () => setState(() => _selectedDate = DateTime.now()),
          ),
          const Divider(height: 1, color: SovereignColors.surfaceDark),

          // ── Timeline ──
          Expanded(
            child: AsyncValueView<List<PlannerEntry>>(
              value: entriesAsync,
              data: (allEntries) {
                final dayEntries = entriesForDate(allEntries, _selectedDate);
                return _Timeline(
                  entries: dayEntries,
                  onDelete: (id) =>
                      ref.read(plannerRepositoryProvider).delete(id),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_entry_fab'),
        backgroundColor: SovereignColors.rossoCorsa,
        foregroundColor: SovereignColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        onPressed: () => _showAddEntrySheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEntrySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SovereignColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _AddEntrySheet(
        selectedDate: _dateOnly,
        onSave: (entry) {
          ref.read(plannerRepositoryProvider).save(entry);
        },
      ),
    );
  }
}

// ── Day nav bar ─────────────────────────────────────────────────────────────

class _DayNavBar extends StatelessWidget {
  final DateTime selectedDate;
  final bool isToday;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onTodayTap;

  const _DayNavBar({
    required this.selectedDate,
    required this.isToday,
    required this.onPrev,
    required this.onNext,
    required this.onTodayTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = isToday
        ? 'Today, ${DateFormat('MMM d').format(selectedDate)}'
        : DateFormat('EEE, MMM d, yyyy').format(selectedDate);

    return Container(
      color: SovereignColors.ink,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
          ),
          GestureDetector(
            onTap: onTodayTap,
            child: Column(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: SovereignColors.white,
                  ),
                ),
                if (!isToday)
                  const Text(
                    'Tap to go to today',
                    style: TextStyle(
                      fontSize: 11,
                      color: SovereignColors.graySilver,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

// ── Timeline ────────────────────────────────────────────────────────────────

class _Timeline extends StatelessWidget {
  final List<PlannerEntry> entries;
  final void Function(String id) onDelete;

  const _Timeline({required this.entries, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'No blocks scheduled — tap + to add one',
          style: TextStyle(color: SovereignColors.grayMid),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final entry = entries[i];
        return _EntryTile(entry: entry, onDelete: onDelete);
      },
    );
  }
}

class _EntryTile extends StatelessWidget {
  final PlannerEntry entry;
  final void Function(String id) onDelete;

  const _EntryTile({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final hourLabel = entry.hour == 0
        ? '12 AM'
        : entry.hour < 12
            ? '${entry.hour} AM'
            : entry.hour == 12
                ? '12 PM'
                : '${entry.hour - 12} PM';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                hourLabel,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: SovereignColors.graySilver,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: entry.color.withValues(alpha: 0.18),
                border: Border(
                  left: BorderSide(color: entry.color, width: 3),
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: SovereignColors.white,
                          ),
                        ),
                        if (entry.notes.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            entry.notes,
                            style: const TextStyle(
                              fontSize: 12,
                              color: SovereignColors.graySilver,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: SovereignColors.graySilver,
                    onPressed: () => onDelete(entry.id),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Entry Sheet ──────────────────────────────────────────────────────────

class _AddEntrySheet extends StatefulWidget {
  final DateTime selectedDate;
  final void Function(PlannerEntry) onSave;

  const _AddEntrySheet({required this.selectedDate, required this.onSave});

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int _hour = TimeOfDay.now().hour;
  Color _selectedColor = Colors.red;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final err = validatePlannerEntry(_titleCtrl.text, _hour);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    widget.onSave(
      PlannerEntry(
        id: '',
        date: widget.selectedDate,
        hour: _hour,
        title: _titleCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
        color: _selectedColor,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ADD BLOCK',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
              color: SovereignColors.graySilver,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(hintText: 'Title'),
            autofocus: true,
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: 12),

          // Notes
          TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(hintText: 'Notes (optional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Hour picker
          Row(
            children: [
              const Text('Hour: ', style: TextStyle(color: SovereignColors.graySilver)),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _hour,
                dropdownColor: SovereignColors.surfaceDark,
                items: List.generate(24, (h) {
                  final label = h == 0
                      ? '12 AM'
                      : h < 12
                          ? '$h AM'
                          : h == 12
                              ? '12 PM'
                              : '${h - 12} PM';
                  return DropdownMenuItem(value: h, child: Text(label));
                }),
                onChanged: (v) => setState(() => _hour = v!),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Color picker
          const Text('Color:', style: TextStyle(color: SovereignColors.graySilver)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: kPlannerColors.map((c) {
              final selected = c == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: SovereignColors.white, width: 2.5)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),

          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: SovereignColors.rossoCorsa, fontSize: 12),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: SovereignColors.rossoCorsa,
                foregroundColor: SovereignColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
              ),
              child: const Text('SAVE BLOCK'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
