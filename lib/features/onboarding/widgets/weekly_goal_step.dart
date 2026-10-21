import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/constants/app_decorations.dart';
import 'package:workout/core/constants/app_spacing.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/user_profile_provider.dart';

/// Step 5: Weekly workout frequency goal with double theme support.
class WeeklyGoalStep extends ConsumerWidget {
  const WeeklyGoalStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyDays = ref.watch(
      userProfileProvider.select((p) => p.weeklyGoalDays),
    );
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: AppSpacing.paddingHorizXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.h12,
          Text(
            'Set your weekly workout goal',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: context.primaryText,
            ),
          ),
          AppSpacing.h8,
          Text(
            'Consistency is key. We recommend starting with 4 days per week.',
            style: TextStyle(
              fontSize: 14,
              color: context.secondaryText,
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Text(
                  '$weeklyDays',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                  ),
                ),
                Text(
                  'DAYS / WEEK',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.secondaryText,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final days = index + 1;
              final isSelected = weeklyDays == days;

              return GestureDetector(
                onTap: () {
                  ref
                      .read(userProfileProvider.notifier)
                      .updateWeeklyGoalDays(days);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : context.cardBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? primaryColor : context.cardBorder,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryColor.withAlpha(100),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$days',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.raisinBlack
                            : context.primaryText,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          AppSpacing.h32,
          Container(
            padding: AppSpacing.paddingAllLg,
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: AppDecorations.borderRadiusLg,
              border: Border.all(color: context.cardBorder),
            ),
            child: Row(
              children: [
                HugeIcon(icon: HugeIcons.strokeRoundedInformationCircle, color: primaryColor),
                AppSpacing.w12,
                Expanded(
                  child: Text(
                    weeklyDays < 4
                        ? 'Great for maintaining fitness and building habit.'
                        : weeklyDays == 4 || weeklyDays == 5
                            ? 'Optimal balance for muscle building & fat loss!'
                            : 'Intense training regime for experienced athletes.',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
