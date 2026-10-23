import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovereign/core/router/app_router.dart';
import 'package:sovereign/core/theme/sovereign_theme.dart';
import 'package:sovereign/features/settings/presentation/settings_providers.dart';

/// Sovereign root application widget.
class SovereignApp extends ConsumerWidget {
  const SovereignApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Sovereign',
      debugShowCheckedModeBanner: false,
      theme: SovereignTheme.light,
      darkTheme: SovereignTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
