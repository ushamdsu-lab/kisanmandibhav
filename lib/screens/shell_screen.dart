import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/locale_provider.dart';
import '../widgets/mandi/voice_bulletin_bar.dart';

class ShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ShellScreen({super.key, required this.navigationShell});

  void _onTabTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: navigationShell),
          const VoiceBulletinBar(),
        ],
      ),
      bottomNavigationBar: Consumer<LocaleProvider>(
        builder: (context, localeProv, _) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onTabTapped,
                backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
                indicatorColor: AppColors.primary.withValues(alpha: 0.15),
                animationDuration: const Duration(milliseconds: 400),
                height: 66,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.grid_view_outlined),
                    selectedIcon: const Icon(Icons.grid_view_rounded, color: AppColors.primary),
                    label: localeProv.t('nav_home'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.storefront_outlined),
                    selectedIcon: const Icon(Icons.storefront_rounded, color: AppColors.mandiAccent),
                    label: localeProv.t('nav_mandi'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.wb_sunny_outlined),
                    selectedIcon: const Icon(Icons.wb_sunny_rounded, color: AppColors.mausamAccent),
                    label: localeProv.t('nav_weather'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.agriculture_outlined),
                    selectedIcon: const Icon(Icons.agriculture_rounded, color: AppColors.khetiAccent),
                    label: localeProv.t('nav_kheti'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.workspace_premium_outlined),
                    selectedIcon: const Icon(Icons.workspace_premium_rounded, color: AppColors.yojnaAccent),
                    label: localeProv.t('nav_yojna'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
