import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sovereign/core/router/app_router.dart';
import 'package:sovereign/core/supabase/supabase_providers.dart';

void main() {
  group('Router redirect', () {
    testWidgets('redirects /tasks to /sign-in when signed out', (tester) async {
      final container = ProviderContainer(
        overrides: [
          authStateChangesProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(routerProvider);
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final router = container.read(routerProvider);
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        '/sign-in',
      );
    });
  });
}
