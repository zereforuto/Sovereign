import 'package:sovereign/core/errors/guard.dart';
import 'package:sovereign/features/focus/domain/focus_repository.dart';
import 'package:sovereign/features/focus/domain/focus_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFocusRepository implements FocusRepository {
  final SupabaseClient _client;

  SupabaseFocusRepository(this._client);

  @override
  Stream<List<FocusSession>> watchSessions() {
    return _client
        .from('focus_sessions')
        .stream(primaryKey: ['id'])
        .order('started_at', ascending: false)
        .map((rows) => rows.map((r) => FocusSession.fromMap(r)).toList());
  }

  @override
  Future<void> saveSession(FocusSession session) {
    return guard(() async {
      final userId = _client.auth.currentUser?.id;
      await _client.from('focus_sessions').insert(session.toMap(userId: userId));
    });
  }
}
