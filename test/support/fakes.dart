import 'dart:async';
import 'package:sovereign/features/auth/domain/app_user.dart';
import 'package:sovereign/features/auth/domain/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  List<String> calls = [];

  FakeAuthRepository({AppUser? initialUser}) : _currentUser = initialUser;

  @override
  Stream<AppUser?> authChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    calls.add('signInWithEmail:$email');
    _currentUser = AppUser(id: 'fake-user-id', email: email);
    _controller.add(_currentUser);
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    calls.add('signUpWithEmail:$email');
    _currentUser = AppUser(id: 'fake-user-id', email: email);
    _controller.add(_currentUser);
  }

  @override
  Future<void> signInWithGoogle() async {
    calls.add('signInWithGoogle');
    _currentUser = const AppUser(id: 'fake-google-id', email: 'user@google.com');
    _controller.add(_currentUser);
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    _currentUser = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}
