import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sovereign/core/theme/colors.dart';

/// App shell providing responsive navigation (NavigationBar on mobile/narrow screens, NavigationRail >= 800px).
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'SOVEREIGN',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: SovereignColors.rossoCorsa,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.check_circle_outline),
                      selectedIcon: Icon(Icons.check_circle, color: SovereignColors.white),
                      label: Text('TASKS'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.repeat),
                      selectedIcon: Icon(Icons.repeat, color: SovereignColors.white),
                      label: Text('HABITS'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.timer_outlined),
                      selectedIcon: Icon(Icons.timer, color: SovereignColors.white),
                      label: Text('FOCUS'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.fitness_center_outlined),
                      selectedIcon: Icon(Icons.fitness_center, color: SovereignColors.white),
                      label: Text('WORKOUTS'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_today_outlined),
                      selectedIcon: Icon(Icons.calendar_today, color: SovereignColors.white),
                      label: Text('PLANNER'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings, color: SovereignColors.white),
                      label: Text('SETTINGS'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: SovereignColors.surfaceDark),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }

        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.check_circle_outline),
                selectedIcon: Icon(Icons.check_circle, color: SovereignColors.white),
                label: 'Tasks',
              ),
              NavigationDestination(
                icon: Icon(Icons.repeat),
                selectedIcon: Icon(Icons.repeat, color: SovereignColors.white),
                label: 'Habits',
              ),
              NavigationDestination(
                icon: Icon(Icons.timer_outlined),
                selectedIcon: Icon(Icons.timer, color: SovereignColors.white),
                label: 'Focus',
              ),
              NavigationDestination(
                icon: Icon(Icons.fitness_center_outlined),
                selectedIcon: Icon(Icons.fitness_center, color: SovereignColors.white),
                label: 'Workouts',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today, color: SovereignColors.white),
                label: 'Planner',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings, color: SovereignColors.white),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
