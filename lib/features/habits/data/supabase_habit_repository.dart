import 'package:sovereign/core/errors/guard.dart';
import 'package:sovereign/features/habits/domain/habit.dart';
import 'package:sovereign/features/habits/domain/habit_repository.dart';
import 'package:sovereign/features/habits/domain/streaks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHabitRepository implements HabitRepository {
  final SupabaseClient _client;

  SupabaseHabitRepository(this._client);

  @override
  Stream<List<Habit>> watchHabits() {
    return _client
        .from('habits')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((rows) => rows.map((r) => Habit.fromMap(r)).toList());
  }

  @override
  Stream<List<HabitCheckin>> watchCheckins() {
    return _client
        .from('habit_checkins')
        .stream(primaryKey: ['id'])
        .map((rows) => rows.map((r) => HabitCheckin.fromMap(r)).toList());
  }

  @override
  Future<void> create(Habit draft) {
    return guard(() async {
      final userId = _client.auth.currentUser?.id;
      await _client.from('habits').insert(draft.toMap(userId: userId));
    });
  }

  @override
  Future<void> archive(String id) {
    return guard(() async {
      await _client.from('habits').update({
        'archived_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    });
  }

  @override
  Future<void> setCheckin(String habitId, DateTime date, bool done) {
    return guard(() async {
      final userId = _client.auth.currentUser?.id;
      final targetDate = dateOnly(date);
      final dateString =
          '${targetDate.year.toString().padLeft(4, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

      if (done) {
        // Upsert checkin
        await _client.from('habit_checkins').upsert(
          {
            'habit_id': habitId,
            'date': dateString,
            'user_id': ?userId,
          },
          onConflict: 'habit_id, date',
        );
      } else {
        // Remove checkin
        await _client
            .from('habit_checkins')
            .delete()
            .eq('habit_id', habitId)
            .eq('date', dateString);
      }
    });
  }
}
