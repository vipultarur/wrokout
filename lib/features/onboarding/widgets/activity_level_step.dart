import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout/common/widgets/app_selection_card.dart';
import 'package:workout/core/constants/app_spacing.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/user_profile_provider.dart';

/// Step 3: Activity Level selection step with double theme support.
class ActivityLevelStep extends ConsumerWidget {
  const ActivityLevelStep({super.key});

  static const _levels = [
    {
      'id': 'sedentary',
      'title': 'Sedentary',
      'desc': 'Little or no regular exercise, mostly sitting',
      'icon': '🛋️',
    },
    {
      'id': 'light',
      'title': 'Lightly Active',
      'desc': 'Light exercise/sports 1-3 days per week',
      'icon': '🚶',
    },
    {
      'id': 'moderate',
      'title': 'Moderately Active',
      'desc': 'Moderate exercise/sports 3-5 days per week',
      'icon': '🏃',
    },
    {
      'id': 'very_active',
      'title': 'Very Active',
      'desc': 'Hard exercise/sports 6-7 days per week',
      'icon': '⚡',
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLevel = ref.watch(
      userProfileProvider.select((p) => p.activityLevel),
    );

    return Padding(
      padding: AppSpacing.paddingHorizXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.h12,
          Text(
            'How active are you?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: context.primaryText,
            ),
          ),
          AppSpacing.h8,
          Text(
            'This helps us accurately estimate your daily calorie burn and workout intensity.',
            style: TextStyle(
              fontSize: 14,
              color: context.secondaryText,
            ),
          ),
          AppSpacing.h24,
          Expanded(
            child: ListView.separated(
              itemCount: _levels.length,
              separatorBuilder: (context, index) => AppSpacing.h12,
              itemBuilder: (context, index) {
                final item = _levels[index];
                final id = item['id'] as String;
                final title = item['title'] as String;
                final desc = item['desc'] as String;
                final icon = item['icon'] as String;
                final isSelected = selectedLevel == id;

                return AppSelectionCard(
                  title: title,
                  subtitle: desc,
                  iconEmoji: icon,
                  isSelected: isSelected,
                  onTap: () {
                    ref
                        .read(userProfileProvider.notifier)
                        .updateActivityLevel(id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
