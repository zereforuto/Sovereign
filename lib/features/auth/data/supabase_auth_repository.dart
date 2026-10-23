import 'package:flutter/foundation.dart';
import 'package:sovereign/core/errors/guard.dart';
import 'package:sovereign/features/auth/domain/app_user.dart';
import 'package:sovereign/features/auth/domain/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  @override
  Stream<AppUser?> authChanges() {
    return _client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null || user.email == null) return null;
      return AppUser(id: user.id, email: user.email!);
    });
  }

  @override
  Future<void> signInWithEmail(String email, String password) {
    return guard(() async {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    });
  }

  @override
  Future<void> signUpWithEmail(String email, String password) {
    return guard(() async {
      await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
    });
  }

  @override
  Future<void> signInWithGoogle() {
    return guard(() async {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? Uri.base.origin : null,
      );
    });
  }

  @override
  Future<void> signOut() {
    return guard(() async {
      await _client.auth.signOut();
    });
  }
}
