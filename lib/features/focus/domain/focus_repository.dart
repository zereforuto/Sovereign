import 'package:sovereign/features/focus/domain/focus_session.dart';

abstract class FocusRepository {
  Stream<List<FocusSession>> watchSessions();
  Future<void> saveSession(FocusSession session);
}
