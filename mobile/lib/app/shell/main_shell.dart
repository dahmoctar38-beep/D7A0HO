import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  static const _tabs = [
    (icon: Icons.home_outlined, label: 'Home', route: AppRoutes.home),
    (icon: Icons.history, label: 'History', route: AppRoutes.history),
    (icon: Icons.favorite_border, label: 'Favorites', route: AppRoutes.favorites),
    (icon: Icons.person_outline, label: 'Profile', route: AppRoutes.profile),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        backgroundColor: AppTheme.cardBg,
        indicatorColor: AppTheme.primary.withValues(alpha: 0.15),
        onDestinationSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon),
                  label: t.label,
                  selectedIcon: Icon(t.icon, color: AppTheme.primary),
                ))
            .toList(),
      ),
    );
  }
}
