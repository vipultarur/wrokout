import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/custom_workout_provider.dart';
import 'package:workout/features/custom_workout/widgets/add_exercises_sheet.dart';

/// Main Custom Workout Screen matching Image 1 (Empty State & Custom Workout List).
class CustomWorkoutScreen extends ConsumerWidget {
  const CustomWorkoutScreen({super.key});

  Future<void> _startCreateFlow(BuildContext context) async {
    final selectedExercises = await AddExercisesSheet.show(context);
    if (selectedExercises != null && selectedExercises.isNotEmpty && context.mounted) {
      context.push(
        AppRoutes.customWorkoutEdit,
        extra: selectedExercises,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(customWorkoutsProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final scaffoldBg = context.scaffoldBg;
    final cardBg = context.cardBg;
    final border = context.cardBorder;

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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
          'CUSTOM WORKOUT',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: context.primaryText,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: workouts.isEmpty
          ? _buildEmptyState(context, primaryColor)
          : _buildWorkoutList(context, ref, workouts, primaryColor, cardBg, border),
    );
  }

  /// Empty state: circular hero illustration, quote, and + Create button
  Widget _buildEmptyState(BuildContext context, Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Circular Fitness Coach Illustration
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.isDarkMode
                    ? AppColors.darkCardAlt
                    : const Color(0xFFF2F2ED),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/female.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (ctx, err, stack) => Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedDumbbell01,
                      color: primaryColor,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Subtitle description text
            Text(
              'You can design your personalized plans to align with your goals.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: context.secondaryText,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 36),

            // Large Blue "+ Create" Pill Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _startCreateFlow(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(Icons.add, size: 24, color: Colors.white),
                label: const Text(
                  'Create',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  /// List state when custom workouts exist with "+ Create" button at bottom
  Widget _buildWorkoutList(
    BuildContext context,
    WidgetRef ref,
    List<CustomWorkoutPlan> workouts,
    Color primaryColor,
    Color cardBg,
    Color border,
  ) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 175),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Personalized Plans',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.primaryText,
                ),
              ),

              const SizedBox(height: 16),

              // Workout cards list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: workouts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final workout = workouts[index];

                  return InkWell(
                    onTap: () => context.push(
                      AppRoutes.customWorkoutDetail,
                      extra: workout.id,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          // Circular Icon Container
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withAlpha(30),
                            ),
                            child: Center(
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedDumbbell01,
                                color: primaryColor,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Title & Metrics
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  workout.name,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: context.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${workout.exerciseCount} exercises • ${workout.estimatedMinutes} mins',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Play Start Button
                          IconButton(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedPlay,
                              color: primaryColor,
                              size: 32,
                            ),
                            onPressed: () => context.push(
                              AppRoutes.workoutSession,
                              extra: workout.name,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Bottom Fixed Create Button
        Positioned(
          bottom: 95,
          left: 20,
          right: 20,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => _startCreateFlow(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              icon: Icon(Icons.add, size: 24, color: Theme.of(context).colorScheme.onPrimary),
              label: Text(
                'Create',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
