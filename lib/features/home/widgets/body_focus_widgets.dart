import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/data/providers/exercise_provider.dart';
import 'package:workout/features/home/providers/home_providers.dart';

/// Helper to get the exact real exercises for a given Body Focus category & difficulty level.
List<Exercise> getExercisesForBodyFocusPlan(String focusTab, String level, List<Exercise> all) {
  if (all.isEmpty) return const [];
  final tabLower = focusTab.toLowerCase();
  final levelLower = level.toLowerCase();

  if (tabLower.contains('abs') || tabLower.contains('waist') || tabLower.contains('six pack')) {
    final absEx = all.where((e) => e.bodyPart == 'waist').toList();
    final bw = all.where((e) => e.equipment == 'body weight').toList();
    final pool = absEx.isNotEmpty ? absEx : (bw.isNotEmpty ? bw : all);
    int count = levelLower.contains('intermediate') ? 21 : (levelLower.contains('advanced') ? 25 : 16);
    return pool.take(count).toList();
  } else if (tabLower.contains('arm') || tabLower.contains('bat wings')) {
    final armEx = all.where((e) => e.bodyPart == 'upper arms' || e.bodyPart == 'lower arms').toList();
    final bw = all.where((e) => e.equipment == 'body weight').toList();
    final pool = armEx.isNotEmpty ? armEx : (bw.isNotEmpty ? bw : all);
    int count = levelLower.contains('intermediate') ? 14 : (levelLower.contains('advanced') ? 18 : 7);
    return pool.take(count).toList();
  } else {
    String targetPart = bodyFocusTabMap[focusTab] ?? '';
    if (targetPart.isEmpty) {
      if (tabLower.contains('forearm')) {
        targetPart = 'lower arms';
      } else if (tabLower.contains('chest')) {
        targetPart = 'chest';
      } else if (tabLower.contains('leg')) {
        targetPart = 'upper legs';
      } else if (tabLower.contains('back')) {
        targetPart = 'back';
      } else if (tabLower.contains('shoulder')) {
        targetPart = 'shoulders';
      } else if (tabLower.contains('cardio')) {
        targetPart = 'cardio';
      } else {
        targetPart = 'waist';
      }
    }

    final categoryEx = all.where((e) => e.bodyPart == targetPart).toList();
    final pool = categoryEx.isNotEmpty ? categoryEx : all.where((e) => e.equipment == 'body weight').toList();
    int count = levelLower.contains('intermediate') ? 18 : (levelLower.contains('advanced') ? 22 : 12);

    final selected = pool.take(count).toList();
    if (selected.length < count && pool.length < all.length) {
      selected.addAll(all.where((e) => !selected.contains(e)).take(count - selected.length));
    }
    return selected;
  }
}

class BodyFocusTabsWidget extends ConsumerWidget {
  const BodyFocusTabsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = bodyFocusTabMap.keys.toList();
    final selectedTab = ref.watch(selectedBodyFocusProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = selectedTab == tab;

          return GestureDetector(
            onTap: () => ref.read(selectedBodyFocusProvider.notifier).state = tab,
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
                tab,
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

class BodyFocusListWidget extends ConsumerWidget {
  const BodyFocusListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(allExercisesProvider);
    final allExercises = allAsync.value ?? [];
    final selectedTab = ref.watch(selectedBodyFocusProvider);
    final tabs = bodyFocusTabMap.keys.toList();

    if (allAsync.isLoading && allExercises.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: Text(
            'Loading exercises...',
            style: TextStyle(color: context.secondaryText),
          ),
        ),
      );
    }

    final tierDefs = [
      {'label': 'Beginner', 'diff': 1},
      {'label': 'Intermediate', 'diff': 2},
      {'label': 'Advanced', 'diff': 3},
    ];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          final currentIndex = tabs.indexOf(selectedTab);
          if (details.primaryVelocity! < -150) {
            // Swipe left -> Next tab
            if (currentIndex != -1 && currentIndex < tabs.length - 1) {
              ref.read(selectedBodyFocusProvider.notifier).state = tabs[currentIndex + 1];
            }
          } else if (details.primaryVelocity! > 150) {
            // Swipe right -> Previous tab
            if (currentIndex > 0) {
              ref.read(selectedBodyFocusProvider.notifier).state = tabs[currentIndex - 1];
            }
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: tierDefs.map((t) {
            final diffLabel = t['label'] as String;
            final diff = t['diff'] as int;
            final tierExercises = getExercisesForBodyFocusPlan(selectedTab, diffLabel, allExercises);

            return _BodyFocusTierCard(
              selectedTab: selectedTab,
              diffLabel: diffLabel,
              diff: diff,
              tierExercises: tierExercises,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _BodyFocusTierCard extends StatelessWidget {
  final String selectedTab;
  final String diffLabel;
  final int diff;
  final List<Exercise> tierExercises;

  const _BodyFocusTierCard({
    required this.selectedTab,
    required this.diffLabel,
    required this.diff,
    required this.tierExercises,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseCount = tierExercises.length;
    int totalSec = 0;
    for (int i = 0; i < tierExercises.length; i++) {
      final ex = tierExercises[i];
      final exSec = ex.isTimeBased ? (ex.durationSeconds > 0 ? ex.durationSeconds : 30) : 30;
      totalSec += exSec;
      if (i < tierExercises.length - 1) {
        totalSec += 20;
      }
    }
    final estimatedMins = totalSec > 0 ? (totalSec / 60).round().clamp(1, 120) : (exerciseCount * 1.2).round();
    final representative = tierExercises.isNotEmpty ? tierExercises.first : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => context.push(
          AppRoutes.workoutPlanDetail,
          extra: {
            'title': '$selectedTab $diffLabel',
            'category': selectedTab,
            'targetArea': selectedTab,
            'level': diffLabel,
          },
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.cardBorder),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: representative != null
                    ? Image.asset(
                        representative.assetImagePath,
                        width: 60,
                        height: 60,
                        cacheWidth: 160,
                        cacheHeight: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _placeholderBox(context, diff),
                      )
                    : _placeholderBox(context, diff),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$selectedTab $diffLabel',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: context.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$estimatedMins mins · $exerciseCount Exercises',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        3,
                        (i) => Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Icon(
                            Icons.bolt_rounded,
                            size: 14,
                            color: i < diff
                                ? Theme.of(context).colorScheme.primary
                                : context.secondaryText.withAlpha(80),
                          ),
                        ),
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
  }

  Widget _placeholderBox(BuildContext context, int diff) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          List.generate(diff, (_) => '⚡').join(),
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

