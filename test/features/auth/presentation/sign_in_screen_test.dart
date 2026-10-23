import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sovereign/core/theme/sovereign_theme.dart';
import 'package:sovereign/features/auth/presentation/auth_providers.dart';
import 'package:sovereign/features/auth/presentation/sign_in_screen.dart';

import '../../../support/fakes.dart';

void main() {
  group('Auth validation', () {
    test('validateEmail checks', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail('abc'), isNotNull);
      expect(validateEmail('a@b.co'), isNull);
    });

    test('validatePassword checks', () {
      expect(validatePassword('short'), isNotNull);
      expect(validatePassword('12345678'), isNull);
    });
  });

  group('SignInScreen Widget', () {
    testWidgets('invalid email shows message and does not call signInWithEmail',
        (tester) async {
      final fakeAuth = FakeAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuth),
          ],
          child: MaterialApp(
            theme: SovereignTheme.dark,
            home: const SignInScreen(),
          ),
        ),
      );

      // Find text fields
      final emailFinder = find.byKey(const Key('email_field'));
      final passwordFinder = find.byKey(const Key('password_field'));
      final submitFinder = find.byKey(const Key('auth_submit_button'));

      await tester.enterText(emailFinder, 'invalid-email');
      await tester.enterText(passwordFinder, '12345678');
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(fakeAuth.calls, isEmpty);
    });

    testWidgets('valid input calls signInWithEmail once', (tester) async {
      final fakeAuth = FakeAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuth),
          ],
          child: MaterialApp(
            theme: SovereignTheme.dark,
            home: const SignInScreen(),
          ),
        ),
      );

      final emailFinder = find.byKey(const Key('email_field'));
      final passwordFinder = find.byKey(const Key('password_field'));
      final submitFinder = find.byKey(const Key('auth_submit_button'));

      await tester.enterText(emailFinder, 'driver@scuderia.com');
      await tester.enterText(passwordFinder, 'password123');
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      expect(fakeAuth.calls, contains('signInWithEmail:driver@scuderia.com'));
    });
  });
}
