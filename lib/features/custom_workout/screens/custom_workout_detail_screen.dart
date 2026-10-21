import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/custom_workout_provider.dart';

/// Screen displaying custom workout plan details with exercise list and Start CTA button.
/// Matches layout, metrics header, start button, and exercise items from Image 4.
class CustomWorkoutDetailScreen extends ConsumerStatefulWidget {
  final String workoutId;

  const CustomWorkoutDetailScreen({
    super.key,
    required this.workoutId,
  });

  @override
  ConsumerState<CustomWorkoutDetailScreen> createState() => _CustomWorkoutDetailScreenState();
}

class _CustomWorkoutDetailScreenState extends ConsumerState<CustomWorkoutDetailScreen> {
  late CustomWorkoutPlan _workout;

  @override
  Widget build(BuildContext context) {
    final workouts = ref.watch(customWorkoutsProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final scaffoldBg = context.scaffoldBg;

    final found = workouts.firstWhere(
      (w) => w.id == widget.workoutId,
      orElse: () => CustomWorkoutPlan(
        id: widget.workoutId,
        name: 'NEW',
        exercises: const [],
        createdAt: DateTime.now(),
      ),
    );
    _workout = found;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: context.primaryText,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedPencilEdit01,
              color: context.primaryText,
            ),
            onPressed: () => context.push(
              AppRoutes.customWorkoutEdit,
              extra: _workout.id,
            ),
          ),
          PopupMenuButton<String>(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedMoreVertical,
              color: context.primaryText,
            ),
            onSelected: (val) {
              if (val == 'delete') {
                ref.read(customWorkoutsProvider.notifier).deleteWorkout(_workout.id);
                context.pop();
              } else if (val == 'edit') {
                context.push(
                  AppRoutes.customWorkoutEdit,
                  extra: _workout.id,
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Workout'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Delete Workout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header (e.g. "NEW" or "Push Day")
            Text(
              _workout.name.toUpperCase(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: context.primaryText,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 12),

            // Summary Metrics Row: [⏱️ X mins]  [🔥 Y Exercises]
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedClock01,
                  color: context.secondaryText,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_workout.estimatedMinutes} mins',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.secondaryText,
                  ),
                ),
                const SizedBox(width: 20),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedFire,
                  color: context.secondaryText,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_workout.exerciseCount} Exercises',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.secondaryText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Prominent Blue "Start" Pill Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_workout.exercises.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No exercises in this workout plan.')),
                    );
                    return;
                  }
                  context.push(
                    AppRoutes.workoutSession,
                    extra: _workout.name,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Exercises Section Header
            Text(
              'Exercises',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.primaryText,
              ),
            ),

            const SizedBox(height: 16),

            // Exercise List Items matching Image 4
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _workout.exercises.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = _workout.exercises[index];
                return Row(
                  children: [
                    // Reorder handle icon (=)
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedMenu01,
                      color: context.secondaryText.withAlpha(120),
                      size: 22,
                    ),

                    const SizedBox(width: 14),

                    // Exercise Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 60,
                        height: 60,
                        color: context.isDarkMode
                            ? AppColors.darkCardAlt
                            : const Color(0xFFF2F2ED),
                        child: Image.asset(
                          item.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedDumbbell01,
                              color: context.secondaryText,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Title & Reps/Time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.displayMetric,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.secondaryText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Swap Icon
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedSorting01,
                      color: context.secondaryText.withAlpha(150),
                      size: 20,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }
}
