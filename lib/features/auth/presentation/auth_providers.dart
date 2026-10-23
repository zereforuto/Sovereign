import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovereign/core/supabase/supabase_providers.dart';
import 'package:sovereign/features/auth/data/supabase_auth_repository.dart';
import 'package:sovereign/features/auth/domain/app_user.dart';
import 'package:sovereign/features/auth/domain/auth_repository.dart';

export 'package:sovereign/features/auth/domain/auth_repository.dart'
    show validateEmail, validatePassword;

/// Provides the active [AuthRepository] instance.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(client);
});

/// Streams the currently authenticated [AppUser], or null.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authChanges();
});
