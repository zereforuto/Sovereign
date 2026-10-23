import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sovereign/features/settings/domain/settings_state.dart';
import 'package:sovereign/features/settings/domain/weight_unit.dart';

// ── Keys ────────────────────────────────────────────────────────────────────
const _kThemeKey = 'theme_mode';
const _kWeightKey = 'weight_unit';

// ── Notifier ─────────────────────────────────────────────────────────────────

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final themeVal = prefs.getString(_kThemeKey);
    final weightVal = prefs.getString(_kWeightKey);

    return SettingsState(
      themeMode: themeVal == 'light'
          ? ThemeMode.light
          : themeVal == 'system'
              ? ThemeMode.system
              : ThemeMode.dark,
      weightUnit: WeightUnit.fromString(weightVal),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kThemeKey,
      mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.system
              ? 'system'
              : 'dark',
    );
    state = AsyncData(
      state.value?.copyWith(themeMode: mode) ??
          SettingsState(themeMode: mode),
    );
  }

  Future<void> setWeightUnit(WeightUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kWeightKey, unit.name);
    state = AsyncData(
      state.value?.copyWith(weightUnit: unit) ??
          SettingsState(weightUnit: unit),
    );
  }
}

// ── Providers ────────────────────────────────────────────────────────────────

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

/// Convenience read-only provider for current theme mode.
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).value?.themeMode ?? ThemeMode.dark;
});

/// Convenience read-only provider for current weight unit.
final weightUnitProvider = Provider<WeightUnit>((ref) {
  return ref.watch(settingsProvider).value?.weightUnit ?? WeightUnit.kg;
});
