import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/data/providers/exercise_provider.dart';

/// Full Exercise Details Screen with double theme support.
class ExerciseDetailScreen extends ConsumerWidget {
  final String exerciseId;

  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(allExercisesProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        elevation: 0,
        title: Text(
          'EXERCISE DETAILS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.primaryText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.star_border_rounded, color: context.primaryText),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Added exercise to Favorites!'),
                  backgroundColor: context.cardBg,
                ),
              );
            },
          ),
        ],
      ),
      body: exercisesAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error loading exercise: $err',
            style: TextStyle(color: context.primaryText),
          ),
        ),
        data: (exercises) {
          final exercise = exercises.firstWhere(
            (e) => e.id == exerciseId,
            orElse: () => Exercise(
              id: exerciseId,
              name: 'Exercise $exerciseId',
              bodyPart: 'general',
              equipment: 'body weight',
              target: 'full body',
              gifUrl: '$exerciseId.gif',
              instructionSteps: const {
                'en': ['Perform exercise with controlled posture and breathing.']
              },
            ),
          );

          return _ExerciseDetailBody(exercise: exercise);
        },
      ),
    );
  }
}

class _ExerciseDetailBody extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseDetailBody({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final steps = exercise.getSteps();
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── 1. Exercise Image Header ───
          Container(
            width: double.infinity,
            height: 260,
            color: Colors.white,
            child: Image.asset(
              exercise.assetGifPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: context.cardBg,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center_rounded,
                        size: 64,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Exercise Animation Preview',
                        style: TextStyle(color: context.secondaryText),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: context.primaryText,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 16),

                // ─── 2. Muscle & Equipment Tags Grid ───
                Row(
                  children: [
                    Expanded(
                      child: DetailCardWidget(
                        title: 'TARGET MUSCLE',
                        value: exercise.target.toUpperCase(),
                        icon: Icons.track_changes_rounded,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DetailCardWidget(
                        title: 'EQUIPMENT',
                        value: exercise.equipment.toUpperCase(),
                        icon: Icons.fitness_center_rounded,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: DetailCardWidget(
                        title: 'BODY PART',
                        value: exercise.bodyPart.toUpperCase(),
                        icon: Icons.accessibility_new_rounded,
                        color: AppColors.lime400,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DetailCardWidget(
                        title: 'SECONDARY MUSCLES',
                        value: exercise.secondaryMuscles.isEmpty
                            ? 'NONE'
                            : exercise.secondaryMuscles.join(', ').toUpperCase(),
                        icon: Icons.grain_rounded,
                        color: Colors.purpleAccent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ─── 3. Instructions ───
                Text(
                  'Step-by-Step Instructions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.primaryText,
                  ),
                ),
                const SizedBox(height: 14),

                if (steps.isEmpty)
                  Text(
                    'No specific instructions available for this exercise.',
                    style: TextStyle(color: context.secondaryText),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: steps.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return InstructionStepTile(
                        index: index + 1,
                        instruction: steps[index],
                      );
                    },
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DetailCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: context.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: context.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class InstructionStepTile extends StatelessWidget {
  final int index;
  final String instruction;

  const InstructionStepTile({
    super.key,
    required this.index,
    required this.instruction,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.raisinBlack,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: context.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
