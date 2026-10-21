import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/common/widgets/muscle_part_svg_icon.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/exercise_provider.dart';
import 'package:workout/data/providers/user_profile_provider.dart';
import 'package:workout/features/home/widgets/body_focus_widgets.dart';

/// Screen displaying all Body Focus target areas with gender-aware SVGs and level cards.
class BodyFocusCategoryScreen extends ConsumerWidget {
  const BodyFocusCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldBg = context.scaffoldBg;
    final cardBg = context.cardBg;
    final border = context.cardBorder;
    final userProfile = ref.watch(userProfileProvider);
    final isFemale = userProfile.gender?.toLowerCase() == 'female';

    final categories = [
      {
        'area': 'Abs',
        'title': 'Abs & Core',
        'description': 'Sculpt your waist line, build core stability, and tone abdominal muscles.',
        'levels': ['Beginner', 'Intermediate', 'Advanced'],
      },
      {
        'area': 'Arm',
        'title': 'Arm & Upper Body',
        'description': 'Get rid of bat wings, tone triceps, biceps, and shape sleek arms.',
        'levels': ['Beginner', 'Intermediate', 'Advanced'],
      },
      {
        'area': 'Chest',
        'title': 'Chest Workout',
        'description': 'Target pectoral muscles to firm, lift, and sculpt upper torso.',
        'levels': ['Beginner', 'Intermediate', 'Advanced'],
      },
      {
        'area': 'Leg',
        'title': 'Legs & Thighs',
        'description': 'Tone quads, hamstrings, and calves for strong, lean lower body.',
        'levels': ['Beginner', 'Intermediate', 'Advanced'],
      },
      {
        'area': 'Glutes',
        'title': 'Glutes & Booty',
        'description': 'Lift glutes, shape hips, and strengthen lower posterior chain.',
        'levels': ['Beginner', 'Intermediate', 'Advanced'],
      },
      {
        'area': 'Shoulder',
        'title': 'Shoulders & Neck',
        'description': 'Build shoulder caps, improve posture, and alleviate upper tightness.',
        'levels': ['Beginner', 'Intermediate', 'Advanced'],
      },
      {
        'area': 'Back',
        'title': 'Back & Spine',
        'description': 'Strengthen lats, lower back, and core for superior spinal health.',
        'levels': ['Beginner', 'Intermediate', 'Advanced'],
      },
    ];

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: context.primaryText, size: 22),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Body Focus',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.primaryText,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final area = cat['area'] as String;
          final title = cat['title'] as String;
          final desc = cat['description'] as String;
          final levels = cat['levels'] as List<String>;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Gender-aware Muscle Part SVG
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.lime400.withAlpha(25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: MusclePartSvgIcon(
                          focusArea: area,
                          isFemale: isFemale,
                          size: 40,
                          isSelected: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: context.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            desc,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.secondaryText,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Difficulty Level Chips (Beginner, Intermediate, Advanced)
                Row(
                  children: levels.map((lvl) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: InkWell(
                          onTap: () {
                            context.push(
                              AppRoutes.workoutPlanDetail,
                              extra: {
                                'title': '$area $lvl',
                                'category': area,
                                'targetArea': area,
                                'level': lvl,
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: scaffoldBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: border),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  lvl,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: context.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Builder(
                                  builder: (context) {
                                    final allEx = ref.watch(allExercisesProvider).value ?? [];
                                    final planEx = getExercisesForBodyFocusPlan(area, lvl, allEx);
                                    final count = planEx.length;
                                    int totalSec = 0;
                                    for (int i = 0; i < planEx.length; i++) {
                                      final ex = planEx[i];
                                      final exSec = ex.isTimeBased ? (ex.durationSeconds > 0 ? ex.durationSeconds : 30) : 30;
                                      totalSec += exSec;
                                      if (i < planEx.length - 1) {
                                        totalSec += 20;
                                      }
                                    }
                                    final mins = totalSec > 0 ? (totalSec / 60).round().clamp(1, 120) : (count * 1.2).round();
                                    return Text(
                                      '${mins}m · $count ex',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: context.secondaryText,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
