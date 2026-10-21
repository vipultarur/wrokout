import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/common/widgets/app_icon.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';

/// Floating Pill Bottom Navigation Shell Widget with Double Theme (OLED Dark & Warm Light) support.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.exercises) ||
        location.startsWith(AppRoutes.customWorkout) ||
        location.startsWith('/custom')) {
      return 1;
    }
    if (location.startsWith(AppRoutes.report)) {
      return 2;
    }
    if (location.startsWith(AppRoutes.profile)) {
      return 3;
    }
    if (location == AppRoutes.home || location.isEmpty) {
      return 0;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.exercises);
        break;
      case 2:
        context.go(AppRoutes.report);
        break;
      case 3:
        context.go(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final isDark = context.isDarkMode;

    final navItems = [
      const _NavItemData(
        label: 'Home',
        icon: HugeIcons.strokeRoundedHome01,
        selectedIcon: HugeIcons.strokeRoundedHome01,
      ),
      const _NavItemData(
        label: 'Discover',
        icon: HugeIcons.strokeRoundedSearch01,
        selectedIcon: HugeIcons.strokeRoundedSearch01,
      ),
      const _NavItemData(
        label: 'Report',
        icon: HugeIcons.strokeRoundedAnalytics01,
        selectedIcon: HugeIcons.strokeRoundedAnalytics01,
      ),
      const _NavItemData(
        label: 'Settings',
        icon: HugeIcons.strokeRoundedUserCircle,
        selectedIcon: HugeIcons.strokeRoundedUserCircle,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget childWidget, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.015),
                end: Offset.zero,
              ).animate(animation),
              child: childWidget,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(selectedIndex),
          child: child,
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? AppColors.gray900 : AppColors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 90 : 20),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isSelected = selectedIndex == index;

                return Expanded(
                  flex: isSelected ? 2 : 1,
                  child: GestureDetector(
                    onTap: () => _onItemTapped(index, context),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOutCubic,
                        padding: isSelected
                            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
                            : const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.lime400
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppIcon(
                              icon: isSelected ? item.selectedIcon : item.icon,
                              size: 20,
                              color: isSelected
                                  ? AppColors.black
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.black,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final dynamic icon;
  final dynamic selectedIcon;

  const _NavItemData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
