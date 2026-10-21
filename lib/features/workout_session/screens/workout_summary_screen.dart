import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/common/widgets/app_icon.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/data/providers/workout_history_provider.dart';

/// Workout Summary & Celebration Screen shown upon workout completion with double theme support.
class WorkoutSummaryScreen extends ConsumerStatefulWidget {
  final String workoutTitle;
  final int durationSeconds;
  final int completedCount;
  final int totalCount;
  final int caloriesBurned;
  final List<Exercise> completedExercises;

  const WorkoutSummaryScreen({
    super.key,
    required this.workoutTitle,
    required this.durationSeconds,
    required this.completedCount,
    required this.totalCount,
    required this.caloriesBurned,
    this.completedExercises = const [],
  });

  @override
  ConsumerState<WorkoutSummaryScreen> createState() =>
      _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState
    extends ConsumerState<WorkoutSummaryScreen> {
  String _selectedRating = 'Moderate';
  bool _isSaving = false;

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _handleFinish() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final log = WorkoutSessionLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: widget.workoutTitle,
        durationSeconds: widget.durationSeconds,
        caloriesBurned: widget.caloriesBurned,
        exerciseCount: widget.completedCount,
        date: DateTime.now(),
        rating: _selectedRating,
        exercises: widget.completedExercises.map((e) {
          return ExerciseLogSummary(
            id: e.id,
            name: e.name,
            imagePath: e.assetImagePath,
            bodyPart: e.bodyPart,
            durationSeconds: 30,
          );
        }).toList(),
      );

      await ref.read(workoutHistoryProvider.notifier).addSession(log);

      if (!mounted) return;
      
      // Navigate cleanly to home
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      context.go(AppRoutes.home);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedCancel01,
              color: context.primaryText,
              size: 22,
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              context.go(AppRoutes.home);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              // ─── Hero Trophy Badge & Glow ───
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(40),
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor.withAlpha(120), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withAlpha(90),
                        blurRadius: 36,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🏆', style: TextStyle(fontSize: 54)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ─── Title & Subtitle ───
              Text(
                'WORKOUT COMPLETED!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: context.primaryText,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.cardBorder),
                ),
                child: Text(
                  widget.workoutTitle.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ─── Core Stats Cards Grid ───
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SummaryStatColWidget(
                      label: 'EXERCISES',
                      value: '${widget.completedCount}',
                      icon: HugeIcons.strokeRoundedDumbbell01,
                      color: primaryColor,
                    ),
                    Container(width: 1, height: 42, color: context.cardBorder),
                    SummaryStatColWidget(
                      label: 'CALORIES',
                      value: '${widget.caloriesBurned} kcal',
                      icon: HugeIcons.strokeRoundedFire,
                      color: Colors.deepOrangeAccent,
                    ),
                    Container(width: 1, height: 42, color: context.cardBorder),
                    SummaryStatColWidget(
                      label: 'DURATION',
                      value: _formatDuration(widget.durationSeconds),
                      icon: HugeIcons.strokeRoundedTimer01,
                      color: Colors.cyanAccent,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── Effort Rating Selector ───
              Text(
                'How did this workout feel?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.primaryText,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  RatingChipWidget(
                    rating: 'Too Easy',
                    emoji: '😃',
                    isSelected: _selectedRating == 'Too Easy',
                    onTap: () => setState(() => _selectedRating = 'Too Easy'),
                  ),
                  RatingChipWidget(
                    rating: 'Moderate',
                    emoji: '⚡',
                    isSelected: _selectedRating == 'Moderate',
                    onTap: () => setState(() => _selectedRating = 'Moderate'),
                  ),
                  RatingChipWidget(
                    rating: 'Hard',
                    emoji: '🔥',
                    isSelected: _selectedRating == 'Hard',
                    onTap: () => setState(() => _selectedRating = 'Hard'),
                  ),
                  RatingChipWidget(
                    rating: 'Exhausting',
                    emoji: '💦',
                    isSelected: _selectedRating == 'Exhausting',
                    onTap: () => setState(() => _selectedRating = 'Exhausting'),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ─── Completed Exercises Accordion / List ───
              if (widget.completedExercises.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'COMPLETED EXERCISES (${widget.completedExercises.length})',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: context.secondaryText,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.cardBorder),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.completedExercises.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: context.cardBorder),
                    itemBuilder: (context, index) {
                      final ex = widget.completedExercises[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: primaryColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              ex.assetGifPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedDumbbell01,
                                  size: 22,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          ex.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: context.primaryText,
                          ),
                        ),
                        subtitle: Text(
                          ex.isTimeBased
                              ? '00:${(ex.durationSeconds > 0 ? ex.durationSeconds : 30).toString().padLeft(2, '0')}'
                              : 'x${ex.reps} reps',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.secondaryText,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                            color: AppColors.success,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // ─── Primary Finish Action Button ───
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: AppColors.raisinBlack,
                    elevation: 4,
                    shadowColor: primaryColor.withAlpha(120),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.raisinBlack,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedHome01,
                              color: AppColors.raisinBlack,
                              size: 22,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'FINISH & RETURN HOME',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // ─── Secondary View History Button ───
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          // Save session if not already saved, then go to history
                          if (!_isSaving) {
                            setState(() => _isSaving = true);
                            try {
                              final log = WorkoutSessionLog(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                title: widget.workoutTitle,
                                durationSeconds: widget.durationSeconds,
                                caloriesBurned: widget.caloriesBurned,
                                exerciseCount: widget.completedCount,
                                date: DateTime.now(),
                                rating: _selectedRating,
                                exercises: widget.completedExercises.map((e) {
                                  return ExerciseLogSummary(
                                    id: e.id,
                                    name: e.name,
                                    imagePath: e.assetImagePath,
                                    bodyPart: e.bodyPart,
                                    durationSeconds: 30,
                                  );
                                }).toList(),
                              );
                              await ref
                                  .read(workoutHistoryProvider.notifier)
                                  .addSession(log);
                            } catch (_) {}
                          }
                          if (context.mounted) {
                            context.go(AppRoutes.workoutHistory);
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.primaryText,
                    side: BorderSide(color: context.cardBorder, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedTime02,
                    color: context.primaryText,
                    size: 18,
                  ),
                  label: const Text(
                    'View Workout History',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryStatColWidget extends StatelessWidget {
  final String label;
  final String value;
  final dynamic icon;
  final Color color;

  const SummaryStatColWidget({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppIcon(icon: icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: context.primaryText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: context.secondaryText,
          ),
        ),
      ],
    );
  }
}

class RatingChipWidget extends StatelessWidget {
  final String rating;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const RatingChipWidget({
    super.key,
    required this.rating,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withAlpha(40)
              : context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : context.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              rating,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? primaryColor : context.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
