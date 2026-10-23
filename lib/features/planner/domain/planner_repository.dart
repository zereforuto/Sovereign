import 'package:sovereign/features/planner/domain/planner_entry.dart';

abstract class PlannerRepository {
  Stream<List<PlannerEntry>> watchEntries();
  Future<void> save(PlannerEntry entry);
  Future<void> delete(String id);
}
