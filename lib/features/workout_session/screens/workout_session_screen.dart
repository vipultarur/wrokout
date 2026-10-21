import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/data/providers/exercise_provider.dart';
import 'package:workout/data/providers/user_profile_provider.dart';
import 'package:workout/features/workout_detail/widgets/exercise_detail_sheet.dart';

/// Fullscreen Interactive Active Workout Session Player screen with double theme support.
class WorkoutSessionScreen extends ConsumerStatefulWidget {
  final String workoutTitle;
  final List<String>? exerciseIds;

  const WorkoutSessionScreen({
    super.key,
    required this.workoutTitle,
    this.exerciseIds,
  });

  @override
  ConsumerState<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  int _currentExerciseIndex = 0;
  bool _isResting = false;
  bool _isPaused = false;

  Timer? _timer;
  int _secondsRemaining = 30;
  int _defaultRestSeconds = 20;
  int _totalSessionSeconds = 0;
  int _caloriesBurned = 0;

  List<Exercise> _sessionExercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final all = await ref.read(allExercisesProvider.future);
    if (widget.exerciseIds != null && widget.exerciseIds!.isNotEmpty) {
      _sessionExercises = all
          .where((e) => widget.exerciseIds!.contains(e.id))
          .toList();
    }
    if (_sessionExercises.isEmpty) {
      _sessionExercises = all.take(8).toList();
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    _startExerciseTimer();
  }

  void _startExerciseTimer() {
    _timer?.cancel();
    if (!mounted) return;
    final currentEx = _sessionExercises[_currentExerciseIndex];
    setState(() {
      _isResting = false;
      _secondsRemaining = currentEx.durationSeconds > 0 ? currentEx.durationSeconds : 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_isPaused) return;

      setState(() {
        _totalSessionSeconds++;
        // MET-based estimate: MET ≈ 5 (moderate workout), weight from profile
        final weightKg = ref.read(userProfileProvider).weightKg ?? 70.0;
        _caloriesBurned = (5.0 * weightKg * (_totalSessionSeconds / 3600.0)).round();

        if (_secondsRemaining > 1) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _startRestTimer();
        }
      });
    });
  }

  void _startRestTimer() {
    if (_currentExerciseIndex >= _sessionExercises.length - 1) {
      _finishWorkout();
      return;
    }

    _timer?.cancel();
    if (!mounted) return;
    setState(() {
      _isResting = true;
      _secondsRemaining = _defaultRestSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_isPaused) return;

      setState(() {
        _totalSessionSeconds++;
        if (_secondsRemaining > 1) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _nextExercise();
        }
      });
    });
  }

  void _nextExercise() {
    if (_currentExerciseIndex < _sessionExercises.length - 1) {
      if (!mounted) return;
      setState(() {
        _currentExerciseIndex++;
      });
      _startExerciseTimer();
    } else {
      _finishWorkout();
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      if (!mounted) return;
      setState(() {
        _currentExerciseIndex--;
      });
      _startExerciseTimer();
    }
  }

  void _addRestTime(int seconds) {
    if (!mounted) return;
    setState(() {
      _secondsRemaining += seconds;
    });
  }

  void _setRestTime(int seconds) {
    if (!mounted) return;
    setState(() {
      _secondsRemaining = seconds;
      _defaultRestSeconds = seconds;
    });
  }

  void _finishWorkout() {
    _timer?.cancel();
    if (!mounted) return;
    final doneExercises = _sessionExercises.take(_currentExerciseIndex + 1).toList();
    context.go(
      AppRoutes.workoutSummary,
      extra: {
        'workoutTitle': widget.workoutTitle,
        'durationSeconds': _totalSessionSeconds,
        'completedCount': doneExercises.length,
        'totalCount': _sessionExercises.length,
        'caloriesBurned': _caloriesBurned > 0 ? _caloriesBurned : 65,
        'completedExercises': doneExercises,
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    final currentEx = _sessionExercises[_currentExerciseIndex];
    final progress = (_currentExerciseIndex + 1) / _sessionExercises.length;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: context.primaryText),
          onPressed: () {
            setState(() => _isPaused = true);
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: context.cardBg,
                title: Text('Quit Workout?',
                    style: TextStyle(color: context.primaryText)),
                content: Text(
                  'Are you sure you want to pause and quit this workout session?',
                  style: TextStyle(color: context.secondaryText),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _isPaused = false);
                    },
                    child: const Text('RESUME'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go(AppRoutes.home);
                    },
                    child: const Text('QUIT',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            );
          },
        ),
        title: Column(
          children: [
            Text(
              widget.workoutTitle.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.primaryText,
              ),
            ),
            Text(
              _isResting
                  ? 'Resting...'
                  : 'Exercise ${_currentExerciseIndex + 1} of ${_sessionExercises.length}',
              style: TextStyle(
                fontSize: 11,
                color: context.secondaryText,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: HugeIcon(
              icon: _isPaused ? HugeIcons.strokeRoundedPlay : HugeIcons.strokeRoundedPause,
              color: primaryColor,
            ),
            onPressed: () {
              setState(() => _isPaused = !_isPaused);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            ClipRRect(
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: context.cardBg,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),

            Expanded(
              child: _isResting
                  ? RestScreenWidget(
                      secondsRemaining: _secondsRemaining,
                      exercises: _sessionExercises,
                      currentIndex: _currentExerciseIndex,
                      onAddRest: _addRestTime,
                      onSetRestTime: _setRestTime,
                      onSkip: _nextExercise,
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ActiveExercisePlayerWidget(
                            exercise: currentEx,
                            secondsRemaining: _secondsRemaining,
                          ),
                        ),
                        SessionPlayerControlsWidget(
                          isResting: _isResting,
                          isPaused: _isPaused,
                          canPrevious: _currentExerciseIndex > 0,
                          onPrevious: _previousExercise,
                          onNext: _nextExercise,
                          onTogglePause: () => setState(() => _isPaused = !_isPaused),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActiveExercisePlayerWidget extends StatelessWidget {
  final Exercise exercise;
  final int secondsRemaining;

  const ActiveExercisePlayerWidget({
    super.key,
    required this.exercise,
    required this.secondsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
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
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedDumbbell01,
                        size: 80,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Perform Exercise Form',
                        style: TextStyle(
                          color: context.secondaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  exercise.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: context.primaryText,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'TARGET: ${exercise.target.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${(secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(secondsRemaining % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: secondsRemaining <= 5
                        ? AppColors.error
                        : primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RestScreenWidget extends StatelessWidget {
  final int secondsRemaining;
  final List<Exercise> exercises;
  final int currentIndex;
  final ValueChanged<int> onAddRest;
  final ValueChanged<int> onSetRestTime;
  final VoidCallback onSkip;

  const RestScreenWidget({
    super.key,
    required this.secondsRemaining,
    required this.exercises,
    required this.currentIndex,
    required this.onAddRest,
    required this.onSetRestTime,
    required this.onSkip,
  });

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showEditRestDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EditRestTimeSheet(
        currentSeconds: secondsRemaining,
        onRestTimeUpdated: onSetRestTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nextEx = currentIndex < exercises.length - 1
        ? exercises[currentIndex + 1]
        : null;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final nextDurationText = nextEx == null
        ? ''
        : nextEx.isTimeBased
            ? '00:${(nextEx.durationSeconds > 0 ? nextEx.durationSeconds : 30).toString().padLeft(2, '0')}'
            : 'x${nextEx.reps}';

    return Column(
      children: [
        // 1. TOP PREVIEW: Next Exercise GIF/Animation Container
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: nextEx != null
                  ? Image.asset(
                      nextEx.assetGifPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: context.cardBg,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedDumbbell01,
                                size: 64,
                                color: primaryColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                nextEx.name,
                                style: TextStyle(
                                  color: context.primaryText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'Workout Finish Line!',
                        style: TextStyle(
                          color: context.primaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
            ),
          ),
        ),

        // 2. NEXT EXERCISE INFO BAR
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEXT ${currentIndex + 2}/${exercises.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            (nextEx?.name ?? 'FINISH').toUpperCase(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: context.primaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (nextEx != null) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              ExerciseDetailSheet.show(
                                context,
                                exercise: nextEx,
                                currentIndex: currentIndex + 2,
                                totalCount: exercises.length,
                              );
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: context.cardBg,
                                shape: BoxShape.circle,
                                border: Border.all(color: context.cardBorder),
                              ),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedInformationCircle,
                                size: 18,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (nextEx != null) ...[
                Text(
                  nextDurationText,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: context.primaryText,
                  ),
                ),
              ],
            ],
          ),
        ),

        Divider(height: 1, color: context.cardBorder, indent: 24, endIndent: 24),

        // 3. REST COUNTDOWN DISPLAY SECTION
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'REST',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatTime(secondsRemaining),
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  color: context.primaryText,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 14),

              // Edit Rest Time Button
              InkWell(
                onTap: () => _showEditRestDialog(context),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: primaryColor.withAlpha(90)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedClock01,
                        size: 16,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Edit Rest Time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 4. BOTTOM ACTION BUTTONS (+20s & Skip)
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Row(
            children: [
              // +20s Button
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => onAddRest(20),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.cardBg,
                      foregroundColor: context.primaryText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                        side: BorderSide(color: context.cardBorder, width: 1.5),
                      ),
                    ),
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedAdd01,
                      size: 20,
                      color: context.primaryText,
                    ),
                    label: const Text(
                      '+20s',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Skip Button
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: onSkip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: AppColors.raisinBlack,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EditRestTimeSheet extends StatefulWidget {
  final int currentSeconds;
  final ValueChanged<int> onRestTimeUpdated;

  const EditRestTimeSheet({
    super.key,
    required this.currentSeconds,
    required this.onRestTimeUpdated,
  });

  @override
  State<EditRestTimeSheet> createState() => _EditRestTimeSheetState();
}

class _EditRestTimeSheetState extends State<EditRestTimeSheet> {
  late int _selectedSeconds;

  @override
  void initState() {
    super.initState();
    _selectedSeconds = widget.currentSeconds;
  }

  void _adjustTime(int delta) {
    setState(() {
      _selectedSeconds = (_selectedSeconds + delta).clamp(5, 300);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.secondaryText.withAlpha(60),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Edit Rest Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.primaryText,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: () => _adjustTime(-10),
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedRemove01, size: 24),
                style: IconButton.styleFrom(
                  backgroundColor: context.cardBorder,
                  foregroundColor: context.primaryText,
                ),
              ),
              const SizedBox(width: 24),
              Text(
                '${_selectedSeconds}s',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 24),
              IconButton.filledTonal(
                onPressed: () => _adjustTime(10),
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 24),
                style: IconButton.styleFrom(
                  backgroundColor: context.cardBorder,
                  foregroundColor: context.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [10, 15, 20, 30, 45, 60, 90].map((s) {
              final isSelected = s == _selectedSeconds;
              return ChoiceChip(
                label: Text('${s}s'),
                selected: isSelected,
                selectedColor: primaryColor,
                backgroundColor: context.cardBg,
                side: BorderSide(
                  color: isSelected ? primaryColor : context.cardBorder,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.raisinBlack : context.primaryText,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) {
                  setState(() {
                    _selectedSeconds = s;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.onRestTimeUpdated(_selectedSeconds);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: AppColors.raisinBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Save Rest Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SessionPlayerControlsWidget extends StatelessWidget {
  final bool isResting;
  final bool isPaused;
  final bool canPrevious;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onTogglePause;

  const SessionPlayerControlsWidget({
    super.key,
    required this.isResting,
    required this.isPaused,
    required this.canPrevious,
    required this.onPrevious,
    required this.onNext,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border(top: BorderSide(color: context.cardBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: canPrevious ? onPrevious : null,
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedPrevious, size: 36),
            color: context.primaryText,
            disabledColor: context.secondaryText.withAlpha(100),
          ),
          FloatingActionButton.large(
            onPressed: () {
              if (isResting) {
                onNext();
              } else {
                onTogglePause();
              }
            },
            backgroundColor: primaryColor,
            child: HugeIcon(
              icon: isResting
                  ? HugeIcons.strokeRoundedNext
                  : isPaused
                      ? HugeIcons.strokeRoundedPlay
                      : HugeIcons.strokeRoundedPause,
              size: 40,
              color: AppColors.raisinBlack,
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedNext, size: 36),
            color: context.primaryText,
          ),
        ],
      ),
    );
  }
}

