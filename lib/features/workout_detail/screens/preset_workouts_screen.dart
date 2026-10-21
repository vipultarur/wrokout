import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/common/widgets/muscle_part_svg_icon.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/user_profile_provider.dart';

/// Screen listing workouts for a specific category/section matching application theme and reference screenshots.
class PresetWorkoutsScreen extends ConsumerWidget {
  final String title;

  const PresetWorkoutsScreen({
    super.key,
    this.title = 'Workouts',
  });

  static final Map<String, List<Map<String, dynamic>>> _categoryWorkoutsMap = {
    'Arm': [
      {'title': 'Arm Beginner', 'mins': 18, 'exercises': 19, 'focus': 'Arm', 'level': 'Beginner'},
      {'title': 'Arm Intermediate', 'mins': 23, 'exercises': 25, 'focus': 'Arm', 'level': 'Intermediate'},
      {'title': 'Arm Advanced', 'mins': 31, 'exercises': 28, 'focus': 'Arm', 'level': 'Advanced'},
      {'title': 'Arm Workout (No Push-Ups!)', 'mins': 19, 'exercises': 20, 'focus': 'Arm', 'level': 'Intermediate'},
      {'title': '10 Min Lose Arm Fat', 'mins': 11, 'exercises': 12, 'focus': 'Arm', 'level': 'Beginner'},
      {'title': 'Easy Arm Workout with Dumbbells', 'mins': 17, 'exercises': 12, 'focus': 'Arm', 'level': 'Beginner'},
      {'title': 'Defined Arms with Dumbbells', 'mins': 21, 'exercises': 15, 'focus': 'Arm', 'level': 'Intermediate'},
      {'title': 'Sculpted Arms Workout', 'mins': 9, 'exercises': 8, 'focus': 'Arm', 'level': 'Intermediate'},
      {'title': 'Get Rid of Bat Wings', 'mins': 6, 'exercises': 7, 'focus': 'Arm', 'level': 'Beginner'},
    ],
    'Full Body': [
      {'title': 'Lose Weight for Men', 'subtitle': '30 days plan', 'mins': 20, 'exercises': 25, 'focus': 'Full Body', 'level': 'Intermediate'},
      {'title': 'Lose Weight for Women', 'subtitle': '28 days plan', 'mins': 18, 'exercises': 22, 'focus': 'Full Body', 'level': 'Beginner'},
      {'title': 'Full body challenge', 'subtitle': '28 days plan', 'mins': 25, 'exercises': 30, 'focus': 'Full Body', 'level': 'Advanced'},
      {'title': 'Sculpted body challenge', 'subtitle': '28 days plan', 'mins': 22, 'exercises': 28, 'focus': 'Full Body', 'level': 'Intermediate'},
      {'title': 'Fat Burning HIIT', 'mins': 14, 'exercises': 17, 'focus': 'Full Body', 'level': 'Intermediate'},
      {'title': '7 Min HIIT Fat Burning', 'mins': 8, 'exercises': 7, 'focus': 'Full Body', 'level': 'Beginner'},
      {'title': 'Morning Warm-Up', 'mins': 8, 'exercises': 10, 'focus': 'Full Body', 'level': 'Beginner'},
    ],
    'Fat Burning': [
      {'title': 'Intense Belly Fat Blast', 'subtitle': '14 days plan', 'mins': 15, 'exercises': 18, 'focus': 'Abs', 'level': 'Intermediate'},
      {'title': 'Lose Weight for Men', 'subtitle': '30 days plan', 'mins': 20, 'exercises': 25, 'focus': 'Full Body', 'level': 'Intermediate'},
      {'title': 'Lose Weight for Women', 'subtitle': '28 days plan', 'mins': 18, 'exercises': 22, 'focus': 'Full Body', 'level': 'Beginner'},
      {'title': '10 Min Lose Arm Fat', 'mins': 11, 'exercises': 12, 'focus': 'Arm', 'level': 'Beginner'},
      {'title': 'Belly Fat Burner HIIT Beginner', 'mins': 20, 'exercises': 24, 'focus': 'Abs', 'level': 'Beginner'},
      {'title': 'Belly Fat Burner HIIT Intermediate', 'mins': 26, 'exercises': 30, 'focus': 'Abs', 'level': 'Intermediate'},
      {'title': 'Belly Fat Burner HIIT Advanced', 'mins': 29, 'exercises': 34, 'focus': 'Abs', 'level': 'Advanced'},
      {'title': 'Lose Fat (No Jumping!)', 'mins': 20, 'exercises': 22, 'focus': 'Full Body', 'level': 'Beginner'},
      {'title': 'Fat Burning HIIT', 'mins': 14, 'exercises': 17, 'focus': 'Full Body', 'level': 'Intermediate'},
    ],
    'Intermediate': [
      {'title': 'Abs Intermediate', 'mins': 25, 'exercises': 21, 'focus': 'Abs', 'level': 'Intermediate'},
      {'title': 'Arm Intermediate', 'mins': 23, 'exercises': 25, 'focus': 'Arm', 'level': 'Intermediate'},
      {'title': 'Chest Intermediate', 'mins': 13, 'exercises': 14, 'focus': 'Chest', 'level': 'Intermediate'},
      {'title': 'Leg Intermediate', 'mins': 31, 'exercises': 36, 'focus': 'Leg', 'level': 'Intermediate'},
      {'title': 'Shoulder & Back Intermediate', 'mins': 19, 'exercises': 17, 'focus': 'Shoulder', 'level': 'Intermediate'},
      {'title': '6 Min Tabata', 'mins': 6, 'exercises': 8, 'focus': 'Full Body', 'level': 'Intermediate'},
      {'title': 'Arm Building Circuit', 'mins': 21, 'exercises': 24, 'focus': 'Arm', 'level': 'Intermediate'},
      {'title': 'Arm Workout (No Push-Ups!)', 'mins': 19, 'exercises': 20, 'focus': 'Arm', 'level': 'Intermediate'},
    ],
    'Beginner': [
      {'title': 'Abs Beginner', 'mins': 16, 'exercises': 16, 'focus': 'Abs', 'level': 'Beginner'},
      {'title': 'Arm Beginner', 'mins': 18, 'exercises': 19, 'focus': 'Arm', 'level': 'Beginner'},
      {'title': 'Chest Beginner', 'mins': 9, 'exercises': 11, 'focus': 'Chest', 'level': 'Beginner'},
      {'title': 'Leg Beginner', 'mins': 15, 'exercises': 18, 'focus': 'Leg', 'level': 'Beginner'},
      {'title': 'Shoulder & Back Beginner', 'mins': 14, 'exercises': 15, 'focus': 'Shoulder', 'level': 'Beginner'},
      {'title': 'Beginner Chest Workout', 'mins': 7, 'exercises': 8, 'focus': 'Chest', 'level': 'Beginner'},
      {'title': 'Get Rid of Bat Wings', 'mins': 6, 'exercises': 7, 'focus': 'Arm', 'level': 'Beginner'},
    ],
    'Advanced': [
      {'title': 'Abs Advanced', 'mins': 32, 'exercises': 25, 'focus': 'Abs', 'level': 'Advanced'},
      {'title': 'Arm Advanced', 'mins': 31, 'exercises': 28, 'focus': 'Arm', 'level': 'Advanced'},
      {'title': 'Chest Advanced', 'mins': 19, 'exercises': 20, 'focus': 'Chest', 'level': 'Advanced'},
      {'title': 'Leg Advanced', 'mins': 38, 'exercises': 40, 'focus': 'Leg', 'level': 'Advanced'},
      {'title': 'Shoulder & Back Advanced', 'mins': 26, 'exercises': 24, 'focus': 'Shoulder', 'level': 'Advanced'},
      {'title': 'Belly Fat Burner HIIT Advanced', 'mins': 29, 'exercises': 34, 'focus': 'Abs', 'level': 'Advanced'},
    ],
    'Abs': [
      {'title': 'Abs Beginner', 'mins': 16, 'exercises': 16, 'focus': 'Abs', 'level': 'Beginner'},
      {'title': 'Abs Intermediate', 'mins': 25, 'exercises': 21, 'focus': 'Abs', 'level': 'Intermediate'},
      {'title': 'Abs Advanced', 'mins': 32, 'exercises': 25, 'focus': 'Abs', 'level': 'Advanced'},
      {'title': '10 Min Abs Workout', 'mins': 8, 'exercises': 10, 'focus': 'Abs', 'level': 'Beginner'},
      {'title': 'Intense Belly Fat Blast', 'subtitle': '14 days plan', 'mins': 15, 'exercises': 18, 'focus': 'Abs', 'level': 'Intermediate'},
      {'title': 'Belly Fat Burner HIIT Beginner', 'mins': 20, 'exercises': 24, 'focus': 'Abs', 'level': 'Beginner'},
    ],
    'Chest': [
      {'title': 'Chest Beginner', 'mins': 9, 'exercises': 11, 'focus': 'Chest', 'level': 'Beginner'},
      {'title': 'Chest Intermediate', 'mins': 13, 'exercises': 14, 'focus': 'Chest', 'level': 'Intermediate'},
      {'title': 'Chest Advanced', 'mins': 19, 'exercises': 20, 'focus': 'Chest', 'level': 'Advanced'},
      {'title': 'Beginner Chest Workout', 'mins': 7, 'exercises': 8, 'focus': 'Chest', 'level': 'Beginner'},
      {'title': 'Get Rid of Armpit Fat', 'mins': 7, 'exercises': 8, 'focus': 'Chest', 'level': 'Beginner'},
    ],
    'Leg': [
      {'title': 'Leg Beginner', 'mins': 15, 'exercises': 18, 'focus': 'Leg', 'level': 'Beginner'},
      {'title': 'Leg Intermediate', 'mins': 31, 'exercises': 36, 'focus': 'Leg', 'level': 'Intermediate'},
      {'title': 'Leg Advanced', 'mins': 38, 'exercises': 40, 'focus': 'Leg', 'level': 'Advanced'},
      {'title': 'Slim Legs Workout', 'mins': 10, 'exercises': 12, 'focus': 'Leg', 'level': 'Beginner'},
      {'title': 'Butt Lift & Rounder Booty', 'mins': 8, 'exercises': 9, 'focus': 'Glutes', 'level': 'Beginner'},
    ],
    'Butt & Leg': [
      {'title': 'Leg Beginner', 'mins': 15, 'exercises': 18, 'focus': 'Leg', 'level': 'Beginner'},
      {'title': 'Leg Intermediate', 'mins': 31, 'exercises': 36, 'focus': 'Leg', 'level': 'Intermediate'},
      {'title': 'Leg Advanced', 'mins': 38, 'exercises': 40, 'focus': 'Leg', 'level': 'Advanced'},
      {'title': 'Slim Legs Workout', 'mins': 10, 'exercises': 12, 'focus': 'Leg', 'level': 'Beginner'},
      {'title': 'Butt Lift & Rounder Booty', 'mins': 8, 'exercises': 9, 'focus': 'Glutes', 'level': 'Beginner'},
    ],
    'Shoulder': [
      {'title': 'Shoulder & Back Beginner', 'mins': 14, 'exercises': 15, 'focus': 'Shoulder', 'level': 'Beginner'},
      {'title': 'Shoulder & Back Intermediate', 'mins': 19, 'exercises': 17, 'focus': 'Shoulder', 'level': 'Intermediate'},
      {'title': 'Shoulder & Back Advanced', 'mins': 26, 'exercises': 24, 'focus': 'Shoulder', 'level': 'Advanced'},
    ],
    'Back': [
      {'title': 'Shoulder & Back Beginner', 'mins': 14, 'exercises': 15, 'focus': 'Shoulder', 'level': 'Beginner'},
      {'title': 'Shoulder & Back Intermediate', 'mins': 19, 'exercises': 17, 'focus': 'Shoulder', 'level': 'Intermediate'},
      {'title': 'Shoulder & Back Advanced', 'mins': 26, 'exercises': 24, 'focus': 'Shoulder', 'level': 'Advanced'},
    ],
    'Build Muscle': [
      {'title': 'Arm Building Circuit', 'mins': 21, 'exercises': 24, 'focus': 'Arm', 'level': 'Intermediate'},
      {'title': 'Chest Intermediate', 'mins': 13, 'exercises': 14, 'focus': 'Chest', 'level': 'Intermediate'},
      {'title': 'Defined Arms with Dumbbells', 'mins': 21, 'exercises': 15, 'focus': 'Arm', 'level': 'Intermediate'},
      {'title': 'Sculpted Arms Workout', 'mins': 9, 'exercises': 8, 'focus': 'Arm', 'level': 'Intermediate'},
      {'title': 'Abs Intermediate', 'mins': 25, 'exercises': 21, 'focus': 'Abs', 'level': 'Intermediate'},
    ],
    'HIIT': [
      {'title': '6 Min Tabata', 'mins': 6, 'exercises': 8, 'focus': 'Full Body', 'level': 'Intermediate'},
      {'title': 'Fat Burning HIIT', 'mins': 14, 'exercises': 17, 'focus': 'Full Body', 'level': 'Intermediate'},
      {'title': '7 Min HIIT Fat Burning', 'mins': 8, 'exercises': 7, 'focus': 'Full Body', 'level': 'Beginner'},
      {'title': 'Belly Fat Burner HIIT Beginner', 'mins': 20, 'exercises': 24, 'focus': 'Abs', 'level': 'Beginner'},
      {'title': 'Belly Fat Burner HIIT Intermediate', 'mins': 26, 'exercises': 30, 'focus': 'Abs', 'level': 'Intermediate'},
      {'title': 'Belly Fat Burner HIIT Advanced', 'mins': 29, 'exercises': 34, 'focus': 'Abs', 'level': 'Advanced'},
    ],
    'Warm-Up': [
      {'title': 'Morning Warm-Up', 'mins': 8, 'exercises': 10, 'focus': 'Full Body', 'level': 'Beginner'},
      {'title': 'Full Body Stretch', 'mins': 7, 'exercises': 9, 'focus': 'Full Body', 'level': 'Beginner'},
      {'title': 'Pre-Workout Warm-Up', 'mins': 5, 'exercises': 6, 'focus': 'Full Body', 'level': 'Beginner'},
    ],
    'With Equipment': [
      {'title': 'Easy Arm Workout with Dumbbells', 'mins': 17, 'exercises': 12, 'focus': 'Arm', 'level': 'Beginner'},
      {'title': 'Defined Arms with Dumbbells', 'mins': 21, 'exercises': 15, 'focus': 'Arm', 'level': 'Intermediate'},
      {'title': 'Dumbbell Full Body Blast', 'mins': 25, 'exercises': 18, 'focus': 'Full Body', 'level': 'Intermediate'},
    ],
    'Strength': [
      {'title': 'Arm Building Circuit', 'mins': 21, 'exercises': 24, 'focus': 'Arm', 'level': 'Intermediate'},
      {'title': 'Sculpted body challenge', 'subtitle': '28 days plan', 'mins': 22, 'exercises': 28, 'focus': 'Full Body', 'level': 'Intermediate'},
      {'title': 'Chest Advanced', 'mins': 19, 'exercises': 20, 'focus': 'Chest', 'level': 'Advanced'},
    ],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldBg = context.scaffoldBg;
    final cardBg = context.cardBg;
    final border = context.cardBorder;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final userProfile = ref.watch(userProfileProvider);
    final isFemale = userProfile.gender?.toLowerCase() == 'female';

    // Get workouts matching current category title or fallback to default
    final workouts = _categoryWorkoutsMap[title] ??
        _categoryWorkoutsMap.values.first;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: context.primaryText,
            size: 22,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: context.primaryText,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final workout = workouts[index];
          final workoutTitle = workout['title'] as String;
          final mins = workout['mins'] as int;
          final exercisesCount = workout['exercises'] as int;
          final focusArea = workout['focus'] as String;
          final level = workout['level'] as String;
          final subtitle = workout['subtitle'] as String?;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                context.push(
                  AppRoutes.workoutPlanDetail,
                  extra: {
                    'title': workoutTitle,
                    'category': focusArea,
                    'targetArea': focusArea,
                    'level': level,
                  },
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    // Muscle SVG Thumbnail
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: MusclePartSvgIcon(
                          focusArea: focusArea,
                          isFemale: isFemale,
                          size: 48,
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
                            workoutTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.primaryText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle ?? '$mins mins · $exercisesCount exercises',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: context.secondaryText,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
