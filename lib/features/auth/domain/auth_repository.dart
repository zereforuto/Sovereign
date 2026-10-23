import 'package:sovereign/features/auth/domain/app_user.dart';

/// Pure domain validation rules for authentication.
String? validateEmail(String? email) {
  if (email == null || email.trim().isEmpty) {
    return 'Email is required';
  }
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailRegex.hasMatch(email.trim())) {
    return 'Enter a valid email address';
  }
  return null;
}

String? validatePassword(String? password) {
  if (password == null || password.isEmpty) {
    return 'Password is required';
  }
  if (password.length < 8) {
    return 'Password must be at least 8 characters';
  }
  return null;
}

/// Abstract contract for authentication data operations.
abstract class AuthRepository {
  Stream<AppUser?> authChanges();
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> signOut();
}
