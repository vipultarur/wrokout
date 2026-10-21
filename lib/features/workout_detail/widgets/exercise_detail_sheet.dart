import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/features/workout_detail/data/exercise_detail_info.dart';
import 'package:workout/features/workout_detail/widgets/gender_body_map_widget.dart';
import 'package:workout/features/workout_detail/widgets/replace_exercise_sheet.dart';

/// Exercise Detail Bottom Sheet updated with KREW application theme.
class ExerciseDetailSheet extends StatefulWidget {
  final Exercise exercise;
  final int currentIndex;
  final int totalCount;
  final ValueChanged<int>? onNavigateIndex;
  final ValueChanged<Exercise>? onExerciseReplaced;

  const ExerciseDetailSheet({
    super.key,
    required this.exercise,
    this.currentIndex = 1,
    this.totalCount = 16,
    this.onNavigateIndex,
    this.onExerciseReplaced,
  });

  static Future<void> show(
    BuildContext context, {
    required Exercise exercise,
    int currentIndex = 1,
    int totalCount = 16,
    ValueChanged<int>? onNavigateIndex,
    ValueChanged<Exercise>? onExerciseReplaced,
  }) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseDetailSheet(
        exercise: exercise,
        currentIndex: currentIndex,
        totalCount: totalCount,
        onNavigateIndex: onNavigateIndex,
        onExerciseReplaced: onExerciseReplaced,
      ),
    );
  }

  @override
  State<ExerciseDetailSheet> createState() => _ExerciseDetailSheetState();
}

class _ExerciseDetailSheetState extends State<ExerciseDetailSheet> {
  late Exercise _currentExercise;
  int _selectedTab = 0; // 0: Video, 1: Muscle, 2: How to do
  int _durationSeconds = 20;

  @override
  void initState() {
    super.initState();
    _currentExercise = widget.exercise;
  }

  @override
  void didUpdateWidget(covariant ExerciseDetailSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise != widget.exercise) {
      setState(() {
        _currentExercise = widget.exercise;
      });
    }
  }

  void _incrementDuration() {
    setState(() => _durationSeconds += 5);
  }

  void _decrementDuration() {
    if (_durationSeconds > 5) {
      setState(() => _durationSeconds -= 5);
    }
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _openReplaceSheet() async {
    final newExercise = await ReplaceExerciseSheet.show(
      context,
      currentExercise: _currentExercise,
    );
    if (newExercise != null && mounted) {
      setState(() {
        _currentExercise = newExercise;
      });
      widget.onExerciseReplaced?.call(newExercise);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = ExerciseDetailInfo.forExercise(_currentExercise);
    final isDark = context.isDarkMode;
    final sheetBg = context.scaffoldBg;
    final cardBg = context.cardBg;
    final border = context.cardBorder;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.96,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: border, width: 0.8),
          ),
          child: Column(
            children: [
              // Top Drag Handle & Title Header Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.secondaryText.withAlpha(80),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _currentExercise.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                              color: context.primaryText,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _openReplaceSheet,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCardAlt : const Color(0xFFEFEFED),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const HugeIcon(icon: HugeIcons.strokeRoundedExchange01, color: AppColors.lime400, size: 18),

                                const SizedBox(width: 4),
                                Text(
                                  'Replace',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: context.primaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main Scrollable Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    // Media Preview Card
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 52),
                              child: _selectedTab == 1
                                  ? Center(
                                      child: GenderBodyMapWidget(
                                        targetMuscleIds: info.targetMuscleIds,
                                        height: 155,
                                      ),
                                    )
                                  : _selectedTab == 2
                                      ? Container(
                                          padding: const EdgeInsets.all(16),
                                          alignment: Alignment.center,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const HugeIcon(icon: HugeIcons.strokeRoundedBookOpen01, color: AppColors.lime400, size: 28),
                                                const SizedBox(height: 8),
                                                Text(
                                                  info.instructions,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    height: 1.4,
                                                    color: context.primaryText,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Image.asset(
                                          _currentExercise.assetGifPath,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, _, _) => Image.asset(
                                            _currentExercise.assetImagePath,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, _, _) => const Center(
                                              child: HugeIcon(icon: HugeIcons.strokeRoundedDumbbell01, size: 64, color: AppColors.lime400),
                                            ),
                                          ),
                                        ),
                            ),
                          ),
                          // View selector tabs (Video / Muscle / How to do)
                          Positioned(
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.black.withAlpha(200) : Colors.white.withAlpha(240),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: border),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(20),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildTabPill('Video', 0),
                                  _buildTabPill('Muscle', 1),
                                  _buildTabPill('How to do', 2),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Duration Stepper Row
                    Row(
                      children: [
                        const Text(
                          'DURATION',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: AppColors.lime400,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: HugeIcon(icon: HugeIcons.strokeRoundedRemove01, size: 18, color: context.primaryText),
                                onPressed: _decrementDuration,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  _formatDuration(_durationSeconds),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: context.primaryText,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 18, color: context.primaryText),
                                onPressed: _incrementDuration,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Instructions Section
                    const Text(
                      'INSTRUCTIONS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors.lime400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      info.instructions,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: context.secondaryText,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Focus Area Section
                    const Text(
                      'FOCUS AREA',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors.lime400,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Focus Area Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: info.focusAreas.map((area) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.lime400,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                area,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.primaryText,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Gender-aware Body SVG Diagram
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: border),
                      ),
                      child: GenderBodyMapWidget(
                        targetMuscleIds: info.targetMuscleIds,
                        height: 250,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Common Mistakes Section
                    const Text(
                      'COMMON MISTAKES',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors.lime400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...info.commonMistakes.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final m = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: AppColors.lime400,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$idx',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: context.primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    m.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.secondaryText,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Breathing Tips Section
                    const Text(
                      'BREATHING TIPS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors.lime400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...info.breathingTips.map((tip) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.lime400,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                tip,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.secondaryText,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // Bottom Navigation & Close Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: sheetBg,
                  border: Border(top: BorderSide(color: border)),
                ),
                child: Row(
                  children: [
                    // Prev Button
                    InkWell(
                      onTap: widget.currentIndex > 1
                          ? () => widget.onNavigateIndex?.call(widget.currentIndex - 1)
                          : null,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: border),
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowLeft01,
                          size: 14,
                          color: widget.currentIndex > 1 ? AppColors.lime400 : context.secondaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${widget.currentIndex}/${widget.totalCount}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: context.primaryText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Next Button
                    InkWell(
                      onTap: widget.currentIndex < widget.totalCount
                          ? () => widget.onNavigateIndex?.call(widget.currentIndex + 1)
                          : null,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: border),
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          size: 14,
                          color: widget.currentIndex < widget.totalCount ? AppColors.lime400 : context.secondaryText,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Start Exercise CTA Button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lime400,
                          foregroundColor: AppColors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.push(
                            AppRoutes.workoutSession,
                            extra: _currentExercise.name,
                          );
                        },
                        child: const Text(
                          'START EXERCISE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabPill(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lime400 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.black : context.secondaryText,
          ),
        ),
      ),
    );
  }
}
