import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sovereign/core/theme/colors.dart';
import 'package:sovereign/features/settings/domain/weight_unit.dart';
import 'package:sovereign/features/settings/presentation/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Appearance ──────────────────────────────────────────────────
            _SectionHeader(title: 'APPEARANCE'),
            const SizedBox(height: 12),

            _SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: SovereignColors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ThemeModeToggle(
                    current: settings.themeMode,
                    onChanged: (m) =>
                        ref.read(settingsProvider.notifier).setThemeMode(m),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Units ────────────────────────────────────────────────────────
            _SectionHeader(title: 'UNITS'),
            const SizedBox(height: 12),

            _SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weight unit',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: SovereignColors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _WeightUnitSelector(
                    key: const Key('weight_unit_selector'),
                    current: settings.weightUnit,
                    onChanged: (u) =>
                        ref.read(settingsProvider.notifier).setWeightUnit(u),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── About ────────────────────────────────────────────────────────
            _SectionHeader(title: 'ABOUT'),
            const SizedBox(height: 12),

            _SettingsCard(
              child: Column(
                children: [
                  _AboutRow(label: 'App', value: 'Sovereign'),
                  _AboutRow(label: 'Version', value: '1.0.0'),
                  _AboutRow(label: 'Built with', value: 'Flutter & Supabase'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.6,
        color: SovereignColors.graySilver,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SovereignColors.surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _ThemeModeToggle extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModeToggle({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      key: const Key('theme_mode_toggle'),
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        backgroundColor: SovereignColors.ink,
        selectedBackgroundColor: SovereignColors.rossoCorsa,
        selectedForegroundColor: SovereignColors.white,
        foregroundColor: SovereignColors.graySilver,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      segments: const [
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode, size: 16),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.light_mode, size: 16),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.settings_suggest, size: 16),
        ),
      ],
      selected: {current},
      onSelectionChanged: (sel) => onChanged(sel.first),
    );
  }
}

class _WeightUnitSelector extends StatelessWidget {
  final WeightUnit current;
  final ValueChanged<WeightUnit> onChanged;

  const _WeightUnitSelector({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: WeightUnit.values.map((unit) {
        final selected = unit == current;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            key: Key('weight_unit_${unit.name}'),
            label: Text(unit.name.toUpperCase()),
            selected: selected,
            selectedColor: SovereignColors.rossoCorsa,
            backgroundColor: SovereignColors.ink,
            labelStyle: TextStyle(
              color: selected ? SovereignColors.white : SovereignColors.graySilver,
              fontWeight: FontWeight.bold,
            ),
            onSelected: (_) => onChanged(unit),
          ),
        );
      }).toList(),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;

  const _AboutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: SovereignColors.graySilver),
          ),
          Text(
            value,
            style: const TextStyle(
              color: SovereignColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
