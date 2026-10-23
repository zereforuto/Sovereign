import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sovereign/features/planner/domain/planner_entry.dart';
import 'package:sovereign/features/planner/domain/planner_repository.dart';

class SupabasePlannerRepository implements PlannerRepository {
  final SupabaseClient _client;

  const SupabasePlannerRepository(this._client);

  @override
  Stream<List<PlannerEntry>> watchEntries() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Stream.empty();

    return _client
        .from('planner_entries')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) => rows.map(PlannerEntry.fromMap).toList());
  }

  @override
  Future<void> save(PlannerEntry entry) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final map = entry.toMap(userId: userId);
    if (entry.id.isEmpty) {
      await _client.from('planner_entries').insert(map);
    } else {
      await _client.from('planner_entries').upsert(map);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('planner_entries').delete().eq('id', id);
  }
}

/// Canonical entry-point colors for the color picker.
final kPlannerColors = [
  Colors.red,
  Colors.orange,
  Colors.amber,
  Colors.green,
  Colors.teal,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
  Colors.pink,
];
