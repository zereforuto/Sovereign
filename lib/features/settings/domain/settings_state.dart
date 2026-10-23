import 'package:flutter/material.dart';
import 'package:sovereign/features/settings/domain/weight_unit.dart';

/// Persistent user preferences state.
class SettingsState {
  final ThemeMode themeMode;
  final WeightUnit weightUnit;

  const SettingsState({
    this.themeMode = ThemeMode.dark,
    this.weightUnit = WeightUnit.kg,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    WeightUnit? weightUnit,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      weightUnit: weightUnit ?? this.weightUnit,
    );
  }
}
