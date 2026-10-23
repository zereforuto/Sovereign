import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sovereign/core/router/app_shell.dart';
import 'package:sovereign/core/supabase/supabase_providers.dart';
import 'package:sovereign/features/auth/presentation/sign_in_screen.dart';
import 'package:sovereign/features/habits/presentation/habits_screen.dart';
import 'package:sovereign/features/tasks/presentation/tasks_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Application router with auth redirection guard.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/tasks',
    redirect: (context, state) {
      final isAuth = authState.asData?.value != null;
      final isSignInLocation = state.uri.path == '/sign-in';

      if (!isAuth && !isSignInLocation) {
        return '/sign-in';
      }
      if (isAuth && isSignInLocation) {
        return '/tasks';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TasksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/habits',
                builder: (context, state) => const HabitsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/focus',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Focus Screen')),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/workouts',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Workouts Screen')),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/planner',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Planner Screen')),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Settings Screen')),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
