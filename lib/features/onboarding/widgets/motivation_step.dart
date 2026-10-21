import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout/common/widgets/app_selection_card.dart';
import 'package:workout/core/constants/app_spacing.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/user_profile_provider.dart';

/// Step 2: Main Motivation multi-select step with double theme support.
class MotivationStep extends ConsumerWidget {
  const MotivationStep({super.key});

  static const _motivations = [
    {'title': 'Lose Weight', 'icon': '🔥', 'subtitle': 'Burn fat & get lean'},
    {'title': 'Build Muscle', 'icon': '💪', 'subtitle': 'Gain strength & mass'},
    {'title': 'Keep Fit', 'icon': '⚡', 'subtitle': 'Maintain peak shape'},
    {'title': 'Relieve Stress', 'icon': '🧘', 'subtitle': 'Feel energized & calm'},
    {'title': 'Improve Stamina', 'icon': '🏃', 'subtitle': 'Increase endurance'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMotivations = ref.watch(
      userProfileProvider.select((p) => p.motivations),
    );

    return Padding(
      padding: AppSpacing.paddingHorizXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.h12,
          Text(
            'What is your main goal?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: context.primaryText,
            ),
          ),
          AppSpacing.h8,
          Text(
            'Select all that apply to help us personalize your workout plan.',
            style: TextStyle(
              fontSize: 14,
              color: context.secondaryText,
            ),
          ),
          AppSpacing.h24,
          Expanded(
            child: ListView.separated(
              itemCount: _motivations.length,
              separatorBuilder: (context, index) => AppSpacing.h12,
              itemBuilder: (context, index) {
                final item = _motivations[index];
                final title = item['title'] as String;
                final icon = item['icon'] as String;
                final subtitle = item['subtitle'] as String;
                final isSelected = selectedMotivations.contains(title);

                return AppSelectionCard(
                  title: title,
                  subtitle: subtitle,
                  iconEmoji: icon,
                  isSelected: isSelected,
                  onTap: () {
                    final current = List<String>.from(selectedMotivations);
                    if (isSelected) {
                      current.remove(title);
                    } else {
                      current.add(title);
                    }
                    ref
                        .read(userProfileProvider.notifier)
                        .updateMotivations(current);
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
