import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout/core/constants/app_decorations.dart';
import 'package:workout/core/constants/app_spacing.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/user_profile_provider.dart';

/// Step 4: Fitness Level / Push-up test step with double theme support.
class FitnessLevelStep extends ConsumerWidget {
  const FitnessLevelStep({super.key});

  static const _levels = [
    {
      'id': 'beginner',
      'title': 'Beginner',
      'pushups': '3 - 5 Push-ups',
      'desc': 'I am new to working out or getting back after a long break.',
      'badge': '🌱 Starter',
    },
    {
      'id': 'intermediate',
      'title': 'Intermediate',
      'pushups': '5 - 15 Push-ups',
      'desc': 'I exercise regularly and can handle moderate intensity.',
      'badge': '🔥 Active',
    },
    {
      'id': 'advanced',
      'title': 'Advanced',
      'pushups': '15+ Push-ups',
      'desc': 'I train hard, understand proper form, and seek high intensity.',
      'badge': '🏆 Expert',
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLevel = ref.watch(
      userProfileProvider.select((p) => p.fitnessLevel),
    );
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: AppSpacing.paddingHorizXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.h12,
          Text(
            'How many push-ups can you do at once?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: context.primaryText,
            ),
          ),
          AppSpacing.h8,
          Text(
            'This quick benchmark determines your starting exercise volume.',
            style: TextStyle(
              fontSize: 14,
              color: context.secondaryText,
            ),
          ),
          AppSpacing.h24,
          Expanded(
            child: ListView.separated(
              itemCount: _levels.length,
              separatorBuilder: (context, index) => AppSpacing.h16,
              itemBuilder: (context, index) {
                final item = _levels[index];
                final id = item['id'] as String;
                final title = item['title'] as String;
                final pushups = item['pushups'] as String;
                final desc = item['desc'] as String;
                final badge = item['badge'] as String;
                final isSelected = selectedLevel == id;

                return GestureDetector(
                  onTap: () {
                    ref
                        .read(userProfileProvider.notifier)
                        .updateFitnessLevel(id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: AppSpacing.paddingAllLg,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor.withAlpha(38)
                          : context.cardBg,
                      borderRadius: AppDecorations.borderRadiusLg,
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : context.cardBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? primaryColor
                                    : context.primaryText,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.isDarkMode
                                    ? AppColors.raisinBlack
                                    : AppColors.cottonSeedLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                badge,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: context.secondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.h8,
                        Text(
                          pushups,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: context.primaryText,
                          ),
                        ),
                        AppSpacing.h4,
                        Text(
                          desc,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
