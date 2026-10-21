import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/data/providers/custom_workout_provider.dart';
import 'package:workout/data/providers/exercise_provider.dart';
import 'package:workout/features/custom_workout/widgets/add_exercises_sheet.dart';
import 'package:workout/features/custom_workout/widgets/enter_name_dialog.dart';
import 'package:workout/features/workout_detail/widgets/replace_exercise_sheet.dart';

/// Screen for creating and editing custom workout plans.
/// Matches exact layout, reorderable exercise list, rep/time counters, replace button, and save action from Image 3.
class CustomWorkoutEditScreen extends ConsumerStatefulWidget {
  final String? workoutId;
  final dynamic extra;

  const CustomWorkoutEditScreen({
    super.key,
    this.workoutId,
    this.extra,
  });

  @override
  ConsumerState<CustomWorkoutEditScreen> createState() => _CustomWorkoutEditScreenState();
}

class _CustomWorkoutEditScreenState extends ConsumerState<CustomWorkoutEditScreen> {
  late String _workoutId;
  String _title = 'New Training';
  List<CustomExerciseItem> _exercises = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _workoutId = widget.workoutId ?? DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final input = widget.extra ?? widget.workoutId;
      if (input is String) {
        final existing = ref.read(customWorkoutsProvider.notifier).getWorkoutById(input);
        if (existing != null) {
          _workoutId = existing.id;
          _title = existing.name;
          _exercises = List.from(existing.exercises);
        }
      } else if (input is List<Exercise>) {
        _loadFromSelectedExercises(input);
      } else if (input is List<CustomExerciseItem>) {
        _exercises = List.from(input);
      } else if (input is Map) {
        if (input['workoutId'] != null) {
          final existing = ref.read(customWorkoutsProvider.notifier).getWorkoutById(input['workoutId'] as String);
          if (existing != null) {
            _workoutId = existing.id;
            _title = existing.name;
            _exercises = List.from(existing.exercises);
          }
        }
        if (input['initialExercises'] != null && input['initialExercises'] is List<Exercise>) {
          _loadFromSelectedExercises(input['initialExercises'] as List<Exercise>);
        }
      } else {
        _loadDefaultSampleExercises();
      }
      _isInitialized = true;
    }
  }

  void _loadFromSelectedExercises(List<Exercise> list) {
    final items = <CustomExerciseItem>[];
    for (final ex in list) {
      final isTimeBased = ex.isTimeBased;
      items.add(
        CustomExerciseItem(
          exerciseId: ex.id,
          name: ex.name,
          imagePath: ex.assetImagePath,
          gifUrl: ex.gifUrl,
          bodyPart: ex.bodyPart,
          reps: isTimeBased ? 0 : (ex.reps > 0 ? ex.reps : 10),
          durationSeconds: isTimeBased ? (ex.durationSeconds > 0 ? ex.durationSeconds : 20) : 0,
          isTimeBased: isTimeBased,
        ),
      );
    }
    setState(() {
      _exercises = items;
    });
  }

  void _loadDefaultSampleExercises() {
    final allAsync = ref.read(allExercisesProvider);
    final all = allAsync.value ?? [];
    if (all.isNotEmpty && _exercises.isEmpty) {
      final sampleNames = ['wall push-up', 'punch', 'side arm raise', 'abdominal crunch'];
      final initialItems = <CustomExerciseItem>[];

      for (int i = 0; i < sampleNames.length; i++) {
        final match = all.firstWhere(
          (e) => e.name.toLowerCase().contains(sampleNames[i]),
          orElse: () => all[i % all.length],
        );
        initialItems.add(
          CustomExerciseItem(
            exerciseId: match.id,
            name: match.name,
            imagePath: match.assetImagePath,
            gifUrl: match.gifUrl,
            bodyPart: match.bodyPart,
            reps: (i % 2 == 0) ? 10 : 0,
            durationSeconds: (i % 2 == 1) ? 20 : 0,
            isTimeBased: (i % 2 == 1),
          ),
        );
      }
      setState(() {
        _exercises = initialItems;
      });
    }
  }

  Future<void> _showRenameDialog() async {
    final newName = await EnterNameDialog.show(context, initialName: _title);
    if (newName != null && newName.isNotEmpty) {
      setState(() => _title = newName);
    }
  }

  Future<void> _openAddExercisesSheet() async {
    final initialIds = _exercises.map((e) => e.exerciseId).toList();
    final selectedExercises = await AddExercisesSheet.show(
      context,
      initialSelectedIds: initialIds,
    );

    if (selectedExercises != null && selectedExercises.isNotEmpty) {
      final updatedList = List<CustomExerciseItem>.from(_exercises);
      for (final ex in selectedExercises) {
        if (!updatedList.any((e) => e.exerciseId == ex.id)) {
          final isTimeBased = ex.isTimeBased;
          updatedList.add(
            CustomExerciseItem(
              exerciseId: ex.id,
              name: ex.name,
              imagePath: ex.assetImagePath,
              gifUrl: ex.gifUrl,
              bodyPart: ex.bodyPart,
              reps: isTimeBased ? 0 : 10,
              durationSeconds: isTimeBased ? 20 : 0,
              isTimeBased: isTimeBased,
            ),
          );
        }
      }
      setState(() => _exercises = updatedList);
    }
  }

  Future<void> _replaceExercise(int index) async {
    final item = _exercises[index];
    final allAsync = ref.read(allExercisesProvider);
    final all = allAsync.value ?? [];

    Exercise? currentModel;
    try {
      currentModel = all.firstWhere((e) => e.id == item.exerciseId);
    } catch (_) {
      currentModel = Exercise(
        id: item.exerciseId,
        name: item.name,
        image: item.imagePath,
      );
    }

    final replacement = await ReplaceExerciseSheet.show(context, currentExercise: currentModel);

    if (replacement != null) {
      setState(() {
        final isTimeBased = replacement.isTimeBased;
        _exercises[index] = item.copyWith(
          exerciseId: replacement.id,
          name: replacement.name,
          imagePath: replacement.assetImagePath,
          gifUrl: replacement.gifUrl,
          bodyPart: replacement.bodyPart,
          isTimeBased: isTimeBased,
          reps: isTimeBased ? 0 : (item.reps > 0 ? item.reps : 10),
          durationSeconds: isTimeBased ? (item.durationSeconds > 0 ? item.durationSeconds : 20) : 0,
        );
      });
    }
  }

  void _adjustMetric(int index, bool increase) {
    final item = _exercises[index];
    setState(() {
      if (item.isTimeBased) {
        final newDuration = increase
            ? item.durationSeconds + 5
            : (item.durationSeconds > 5 ? item.durationSeconds - 5 : 5);
        _exercises[index] = item.copyWith(durationSeconds: newDuration);
      } else {
        final newReps = increase
            ? item.reps + 1
            : (item.reps > 1 ? item.reps - 1 : 1);
        _exercises[index] = item.copyWith(reps: newReps);
      }
    });
  }

  Future<void> _saveWorkout() async {
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise to save workout.')),
      );
      return;
    }

    // 1. Show EnterNameDialog (Image 3)
    final enteredName = await EnterNameDialog.show(context, initialName: _title);
    if (enteredName == null || enteredName.trim().isEmpty) {
      // User cancelled dialog
      return;
    }

    final finalTitle = enteredName.trim();

    setState(() {
      _title = finalTitle;
    });

    // 2. Save Custom Workout Plan
    final plan = CustomWorkoutPlan(
      id: _workoutId,
      name: finalTitle,
      exercises: _exercises,
      createdAt: DateTime.now(),
    );

    ref.read(customWorkoutsProvider.notifier).saveWorkout(plan);

    // 3. Navigate to CustomWorkoutDetailScreen (Image 4)
    if (mounted) {
      context.pushReplacement(
        AppRoutes.customWorkoutDetail,
        extra: plan.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final scaffoldBg = context.scaffoldBg;

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
        title: Text(
          'EDIT',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: context.primaryText,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Training Title & Edit Pencil Icon Button
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _showRenameDialog,
                        child: Text(
                          _title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: context.secondaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _showRenameDialog,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.isDarkMode
                              ? AppColors.darkCardAlt
                              : const Color(0xFFECECE8),
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedPencilEdit01,
                          color: context.secondaryText,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Exercises Subheader Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Exercises (${_exercises.length})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.primaryText,
                      ),
                    ),
                    TextButton(
                      onPressed: _openAddExercisesSheet,
                      child: Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Reorderable Exercise List
                if (_exercises.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Text(
                      'No exercises added yet.\nTap "+ Add Exercises" to build your workout.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.secondaryText),
                    ),
                  )
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _exercises.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _exercises.removeAt(oldIndex);
                        _exercises.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = _exercises[index];
                      return Container(
                        key: ValueKey('exercise_${item.exerciseId}_$index'),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            // Reorder Drag Handle (3 lines icon)
                            ReorderableDragStartListener(
                              index: index,
                              child: Container(
                                padding: const EdgeInsets.only(right: 12, top: 12, bottom: 12),
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedMenu01,
                                  color: context.secondaryText.withAlpha(120),
                                  size: 22,
                                ),
                              ),
                            ),

                            // Exercise Image Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 64,
                                height: 64,
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

                            // Exercise Name & Reps/Duration Controller
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: context.primaryText,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),

                                  // Adjuster Pill: [-] [ metric ] [+]
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: context.isDarkMode
                                              ? AppColors.darkCardAlt
                                              : const Color(0xFFF2F2ED),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () => _adjustMetric(index, false),
                                              borderRadius: BorderRadius.circular(6),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                child: Text(
                                                  '-',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: context.primaryText,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: Text(
                                                item.displayMetric,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: context.primaryText,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () => _adjustMetric(index, true),
                                              borderRadius: BorderRadius.circular(6),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                child: Text(
                                                  '+',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: context.primaryText,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Swap Icon Button (⇆)
                            IconButton(
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedSorting01,
                                color: primaryColor,
                                size: 22,
                              ),
                              onPressed: () => _replaceExercise(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 20),

                // "+ Add Exercises" Button at Bottom of List
                Center(
                  child: TextButton.icon(
                    onPressed: _openAddExercisesSheet,
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedAdd01,
                      color: primaryColor,
                      size: 20,
                    ),
                    label: Text(
                      'Add Exercises',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Bar with "Save" Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
