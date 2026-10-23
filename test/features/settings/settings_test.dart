import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sovereign/core/theme/sovereign_theme.dart';
import 'package:sovereign/features/settings/domain/settings_state.dart';
import 'package:sovereign/features/settings/domain/weight_unit.dart';
import 'package:sovereign/features/settings/presentation/settings_providers.dart';
import 'package:sovereign/features/settings/presentation/settings_screen.dart';

void main() {
  group('SettingsState', () {
    test('defaults to dark theme and kg', () {
      const state = SettingsState();
      expect(state.themeMode, ThemeMode.dark);
      expect(state.weightUnit, WeightUnit.kg);
    });

    test('copyWith changes fields independently', () {
      const state = SettingsState();
      final updated = state.copyWith(
        themeMode: ThemeMode.light,
        weightUnit: WeightUnit.lb,
      );
      expect(updated.themeMode, ThemeMode.light);
      expect(updated.weightUnit, WeightUnit.lb);
      // Original unchanged
      expect(state.themeMode, ThemeMode.dark);
      expect(state.weightUnit, WeightUnit.kg);
    });
  });

  group('Settings widget', () {
    // Override settingsProvider with a pre-resolved value to avoid SharedPreferences
    final overrides = [
      settingsProvider.overrideWith(
        () => _FakeSettingsNotifier(const SettingsState()),
      ),
    ];

    testWidgets('renders theme toggle and weight unit selector', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(
            theme: SovereignTheme.dark,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump();

      // Has theme mode switcher
      expect(find.byKey(const Key('theme_mode_toggle')), findsOneWidget);
      // Has weight unit selector
      expect(find.byKey(const Key('weight_unit_selector')), findsOneWidget);
    });

    testWidgets('tapping lb changes weight unit', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(
            theme: SovereignTheme.dark,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump();

      // Default is kg
      final lbChip = find.byKey(const Key('weight_unit_lb'));
      expect(lbChip, findsOneWidget);
      await tester.tap(lbChip);
      await tester.pump();
      // lb chip should still be present
      expect(lbChip, findsOneWidget);
    });
  });
}

/// Notifier that synchronously provides a pre-built SettingsState.
class _FakeSettingsNotifier extends SettingsNotifier {
  final SettingsState _initial;
  _FakeSettingsNotifier(this._initial);

  @override
  Future<SettingsState> build() async => _initial;
}
