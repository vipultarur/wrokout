import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/features/home/providers/home_providers.dart';

class PopularGoalsTabsWidget extends ConsumerWidget {
  const PopularGoalsTabsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const goals = ['Build Muscle', 'Burn Fat', 'Keep Fit'];
    final selectedGoal = ref.watch(selectedPopularGoalProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: goals.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final goal = goals[index];
          final isSelected = selectedGoal == goal;

          return GestureDetector(
            onTap: () =>
                ref.read(selectedPopularGoalProvider.notifier).state = goal,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : context.cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? primaryColor : context.cardBorder,
                ),
              ),
              child: Text(
                goal,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? AppColors.raisinBlack
                      : context.secondaryText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PopularGoalsListWidget extends ConsumerWidget {
  const PopularGoalsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = ref.watch(popularGoalsPresetsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: presets.map((preset) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.workoutSession, extra: preset.title),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.cardBorder),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        preset.exercise.assetImagePath,
                        width: 50,
                        height: 50,
                        cacheWidth: 120,
                        cacheHeight: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 50,
                          height: 50,
                          color: Theme.of(context).colorScheme.primary.withAlpha(40),
                          child: const Icon(Icons.fitness_center, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preset.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: context.primaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            preset.subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: context.secondaryText),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
