import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovereign/core/supabase/supabase_providers.dart';
import 'package:sovereign/features/planner/data/supabase_planner_repository.dart';
import 'package:sovereign/features/planner/domain/planner_entry.dart';
import 'package:sovereign/features/planner/domain/planner_repository.dart';

export 'package:sovereign/features/planner/domain/planner_entry.dart';
export 'package:sovereign/features/planner/domain/planner_logic.dart';
export 'package:sovereign/features/planner/domain/planner_repository.dart';

final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabasePlannerRepository(client);
});

final plannerEntriesProvider = StreamProvider<List<PlannerEntry>>((ref) {
  return ref.watch(plannerRepositoryProvider).watchEntries();
});
