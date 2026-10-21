import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/features/home/providers/home_providers.dart';

class QuickFilterChipsWidget extends ConsumerWidget {
  const QuickFilterChipsWidget({super.key});

  static const _filters = [
    {'label': 'Recent', 'icon': Icons.history_rounded},
    {'label': '7-15 mins', 'icon': Icons.timer_rounded},
    {'label': 'Advanced', 'icon': Icons.trending_up_rounded},
    {'label': 'Build Muscle', 'icon': Icons.fitness_center_rounded},
    {'label': 'Stretch', 'icon': Icons.self_improvement_rounded},
    {'label': 'Keep Fit', 'icon': Icons.favorite_rounded},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(selectedQuickFilterProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _filters.map((filter) {
          final label = filter['label'] as String;
          final icon = filter['icon'] as IconData;
          final isSelected = selectedFilter == label;

          return _FilterChip(
            label: label,
            icon: icon,
            isSelected: isSelected,
            primaryColor: primaryColor,
            onTap: () {
              ref.read(selectedQuickFilterProvider.notifier).state =
                  isSelected ? '' : label;
              if (!isSelected) {
                context.go(AppRoutes.exercises);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : context.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : context.cardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? AppColors.raisinBlack
                  : context.secondaryText,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.raisinBlack
                    : context.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
