import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/features/home/providers/home_providers.dart';

class ChallengeCarouselWidget extends ConsumerWidget {
  const ChallengeCarouselWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chestExercises = ref.watch(challengeChestExercisesProvider);
    final waistExercises = ref.watch(challengeWaistExercisesProvider);
    return SizedBox(
      height: 210,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _ChallengeCard(
            title: 'FULL BODY\nSHRED',
            subtitle: 'CUSTOMIZED FOR YOU',
            time: '9-26 Min',
            level: 'Beginner',
            gradient: const [Color(0xFF0052FF), Color(0xFF00A3FF)],
            exercises: chestExercises,
            onTapContainer: () => context.push(AppRoutes.challengeDetail, extra: {
              'title': 'FULL BODY SHRED',
              'category': 'Full Body',
              'targetArea': 'Full Body',
              'level': 'Beginner',
              'totalDays': 28,
            }),
            onTapStartDay: () => context.push(AppRoutes.workoutPlanDetail, extra: {
              'title': 'DAY 1',
              'challengeTitle': 'FULL BODY SHRED',
              'category': 'Full Body',
              'targetArea': 'Full Body',
              'level': 'Beginner',
              'dayNumber': 1,
            }),
          ),
          const SizedBox(width: 14),
          _ChallengeCard(
            title: '28 DAY\nHEIGHT\nCHALLENGE',
            subtitle: '28-DAY PROGRAM',
            time: '15-30 Min',
            level: 'Intermediate',
            gradient: const [Color(0xFF7C4DFF), Color(0xFF651FFF)],
            exercises: waistExercises,
            onTapContainer: () => context.push(AppRoutes.challengeDetail, extra: {
              'title': 'HEIGHT INCREASE CHALLENGE',
              'category': 'Build Muscle',
              'targetArea': 'Spine & Posture',
              'level': 'Intermediate',
              'totalDays': 28,
            }),
            onTapStartDay: () => context.push(AppRoutes.workoutPlanDetail, extra: {
              'title': 'DAY 1',
              'challengeTitle': 'HEIGHT INCREASE CHALLENGE',
              'category': 'Build Muscle',
              'targetArea': 'Spine & Posture',
              'level': 'Intermediate',
              'dayNumber': 1,
            }),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String level;
  final List<Color> gradient;
  final List<Exercise> exercises;
  final VoidCallback onTapContainer;
  final VoidCallback onTapStartDay;

  const _ChallengeCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.level,
    required this.gradient,
    required this.exercises,
    required this.onTapContainer,
    required this.onTapStartDay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapContainer,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                if (exercises.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      exercises.first.assetImagePath,
                      width: 70,
                      height: 70,
                      cacheWidth: 160,
                      cacheHeight: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.white24,
                        child: const Icon(Icons.fitness_center, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule_rounded, size: 12, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bar_chart_rounded, size: 12, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(level, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: onTapStartDay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: gradient.first,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'START DAY 1',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
