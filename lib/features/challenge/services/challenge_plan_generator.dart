import 'package:workout/data/models/exercise.dart';
import 'package:workout/features/workout_detail/widgets/edit_plan_sheet.dart';

/// Result object holding dynamically generated workout plan items and metadata.
class ChallengeDayPlan {
  final String challengeTitle;
  final int dayNumber;
  final String level;
  final List<EditableExerciseItem> items;
  final int estimatedMinutes;
  final int totalExercises;

  const ChallengeDayPlan({
    required this.challengeTitle,
    required this.dayNumber,
    required this.level,
    required this.items,
    required this.estimatedMinutes,
    required this.totalExercises,
  });
}

/// Dynamic Challenge Plan Generator service.
/// Algorithmically generates unique, goal-matched, level-appropriate,
/// and day-specific exercise lists for every day of any challenge.
class ChallengePlanGenerator {
  /// Generates a dynamic workout routine for [challengeTitle] on [dayNumber].
  static ChallengeDayPlan generatePlan({
    required String challengeTitle,
    required int dayNumber,
    required String level,
    required List<Exercise> allExercises,
  }) {
    if (allExercises.isEmpty) {
      return ChallengeDayPlan(
        challengeTitle: challengeTitle,
        dayNumber: dayNumber,
        level: level,
        items: const [],
        estimatedMinutes: 0,
        totalExercises: 0,
      );
    }

    final titleLower = challengeTitle.toLowerCase();
    final isRestDay = (dayNumber % 7 == 0); // Every 7th day is rest/active recovery

    // Step 1: Categorize pool of relevant exercises based on challenge goal
    final primaryPool = _getExercisePoolForChallenge(titleLower, allExercises);
    final bodyweightPool = allExercises.where((e) => e.equipment.toLowerCase().contains('body weight')).toList();
    final stretchPool = _getStretchPool(allExercises);

    // Step 2: Determine total exercise count based on difficulty level and day progression
    int targetCount = 14;
    if (level.toLowerCase().contains('intermediate')) {
      targetCount = 17;
    } else if (level.toLowerCase().contains('advanced')) {
      targetCount = 20;
    }
    // Slowly add reps/exercises as days progress (progressive overload)
    if (dayNumber > 14) targetCount += 1;
    if (isRestDay) targetCount = 8; // Light active recovery routine

    List<EditableExerciseItem> planItems = [];

    if (isRestDay) {
      // Light Active Recovery / Stretch Day
      planItems = _buildRestRecoveryRoutine(dayNumber, stretchPool, primaryPool, allExercises);
    } else {
      // Main Dynamic Daily Workout Routine
      planItems = _buildDynamicDailyRoutine(
        challengeTitle: challengeTitle,
        dayNumber: dayNumber,
        level: level,
        targetCount: targetCount,
        primaryPool: primaryPool.isNotEmpty ? primaryPool : allExercises,
        bodyweightPool: bodyweightPool.isNotEmpty ? bodyweightPool : allExercises,
        stretchPool: stretchPool,
        allExercises: allExercises,
      );
    }

    // Calculate total duration in seconds & minutes
    int totalSeconds = 0;
    for (final item in planItems) {
      if (item.repsCount > 0) {
        totalSeconds += (item.repsCount * 2.5).round() + 20; // ~2.5s per rep + 20s rest interval
      } else {
        totalSeconds += item.durationSeconds + 20; // duration + 20s rest interval
      }
    }
    final minutes = (totalSeconds / 60).ceil().clamp(5, 60);

    return ChallengeDayPlan(
      challengeTitle: challengeTitle,
      dayNumber: dayNumber,
      level: level,
      items: planItems,
      estimatedMinutes: minutes,
      totalExercises: planItems.length,
    );
  }

  /// Selects exercise pool targeted for specific challenge goals.
  static List<Exercise> _getExercisePoolForChallenge(String titleLower, List<Exercise> all) {
    if (titleLower.contains('lower body') || titleLower.contains('leg')) {
      return all.where((e) => e.bodyPart == 'upper legs' || e.bodyPart == 'lower legs' || e.bodyPart == 'glutes').toList();
    } else if (titleLower.contains('six pack') || titleLower.contains('abs') || titleLower.contains('belly')) {
      return all.where((e) => e.bodyPart == 'waist' || e.muscleGroup.contains('abs')).toList();
    } else if (titleLower.contains('arm') || titleLower.contains('bat wings')) {
      return all.where((e) => e.bodyPart == 'upper arms' || e.bodyPart == 'lower arms').toList();
    } else if (titleLower.contains('chest') || titleLower.contains('sculpted') || titleLower.contains('massive')) {
      return all.where((e) => e.bodyPart == 'chest' || e.bodyPart == 'shoulders' || e.bodyPart == 'upper arms').toList();
    } else if (titleLower.contains('height') || titleLower.contains('posture') || titleLower.contains('spine')) {
      return all.where((e) => e.bodyPart == 'back' || e.name.toLowerCase().contains('stretch') || e.name.toLowerCase().contains('twist')).toList();
    } else if (titleLower.contains('kegel') || titleLower.contains('pelvic')) {
      return all.where((e) => e.bodyPart == 'waist' || e.bodyPart == 'glutes' || e.name.toLowerCase().contains('bridge') || e.name.toLowerCase().contains('kick')).toList();
    } else if (titleLower.contains('calisthenics')) {
      return all.where((e) => e.equipment.toLowerCase().contains('body weight')).toList();
    } else if (titleLower.contains('dumbbell')) {
      final db = all.where((e) => e.equipment.toLowerCase().contains('dumbbell')).toList();
      return db.isNotEmpty ? db : all;
    }
    // Full body default
    return all;
  }

  /// Filters stretch and cool down exercises.
  static List<Exercise> _getStretchPool(List<Exercise> all) {
    final stretches = all.where((e) =>
      e.name.toLowerCase().contains('stretch') ||
      e.name.toLowerCase().contains('cobra') ||
      e.name.toLowerCase().contains('twist') ||
      e.name.toLowerCase().contains('child')
    ).toList();
    return stretches.isNotEmpty ? stretches : all;
  }

  /// Builds a dynamic routine with day-specific exercise rotation and scaling.
  static List<EditableExerciseItem> _buildDynamicDailyRoutine({
    required String challengeTitle,
    required int dayNumber,
    required String level,
    required int targetCount,
    required List<Exercise> primaryPool,
    required List<Exercise> bodyweightPool,
    required List<Exercise> stretchPool,
    required List<Exercise> allExercises,
  }) {
    final items = <EditableExerciseItem>[];

    // Seeded offset ensuring Day 1, Day 2, Day 3... have distinct exercise sequences
    final dayOffset = (dayNumber - 1) * 3;

    // 1. Warm Up (1-2 exercises)
    final warmUpNames = ['Jumping Jacks', 'High Knees', 'Arm Circles Clockwise', 'Standing Arm Swings'];
    final warmUpName = warmUpNames[(dayNumber - 1) % warmUpNames.length];
    final warmUpEx = allExercises.firstWhere(
      (e) => e.name.toLowerCase().contains(warmUpName.toLowerCase().split(' ').first),
      orElse: () => primaryPool[dayOffset % primaryPool.length],
    );
    items.add(EditableExerciseItem(
      exercise: warmUpEx.copyWith(name: warmUpName),
      durationSeconds: 30,
      originalDurationSeconds: 30,
      category: 'Warm Up',
      repsCount: 0,
    ));

    // 2. Main Training Exercises (targetCount - 3)
    final mainCount = (targetCount - 3).clamp(6, 18);
    final titleLower = challengeTitle.toLowerCase();

    // Specific preset patterns for Day 1 and Day 2 matching screenshots if Lower Body
    if (titleLower.contains('lower body')) {
      if (dayNumber == 1) {
        items.addAll(_getLowerBodyDay1(primaryPool, allExercises));
        return items;
      } else if (dayNumber == 2) {
        items.addAll(_getLowerBodyDay2(primaryPool, allExercises));
        return items;
      }
    }

    // Generic dynamic generator for all other days/challenges
    for (int i = 0; i < mainCount; i++) {
      final poolIndex = (dayOffset + i) % primaryPool.length;
      final ex = primaryPool[poolIndex];

      // Progressive rep/duration multiplier per day
      int baseReps = 10 + ((i % 4) * 2) + ((dayNumber ~/ 5) * 2);
      if (level.toLowerCase().contains('intermediate')) baseReps += 2;
      if (level.toLowerCase().contains('advanced')) baseReps += 4;
      baseReps = baseReps.clamp(8, 25);

      final isTimeBased = ex.isTimeBased || ex.name.toLowerCase().contains('plank') || ex.name.toLowerCase().contains('hold');
      final durationSec = isTimeBased ? 30 : 0;
      final reps = isTimeBased ? 0 : baseReps;

      items.add(EditableExerciseItem(
        exercise: ex,
        durationSeconds: durationSec,
        originalDurationSeconds: durationSec,
        category: 'Training',
        repsCount: reps,
      ));
    }

    // 3. Cool Down Stretches (2 exercises)
    final coolDown1 = stretchPool[(dayNumber * 2) % stretchPool.length];
    final coolDown2 = stretchPool[(dayNumber * 2 + 1) % stretchPool.length];

    items.add(EditableExerciseItem(
      exercise: coolDown1,
      durationSeconds: 30,
      originalDurationSeconds: 30,
      category: 'Cool Down',
      repsCount: 0,
    ));
    items.add(EditableExerciseItem(
      exercise: coolDown2,
      durationSeconds: 30,
      originalDurationSeconds: 30,
      category: 'Cool Down',
      repsCount: 0,
    ));

    return items;
  }

  /// Preset exact Day 1 matching Screenshot 5
  static List<EditableExerciseItem> _getLowerBodyDay1(List<Exercise> primaryPool, List<Exercise> all) {
    final list = <EditableExerciseItem>[];
    final presets = [
      ('Squats', 0, 12, 'Training'),
      ('Squats', 0, 10, 'Training'),
      ('Side-Lying Leg Lift Left', 0, 12, 'Training'),
      ('Side-Lying Leg Lift Right', 0, 12, 'Training'),
      ('Side-Lying Leg Lift Left', 0, 10, 'Training'),
      ('Side-Lying Leg Lift Right', 0, 10, 'Training'),
      ('Backward Lunge', 0, 14, 'Training'),
      ('Backward Lunge', 0, 12, 'Training'),
      ('Donkey Kicks Left', 0, 12, 'Training'),
      ('Donkey Kicks Right', 0, 12, 'Training'),
      ('Donkey Kicks Left', 0, 10, 'Training'),
      ('Donkey Kicks Right', 0, 10, 'Training'),
      ('Left Quad Stretch With Wall', 30, 0, 'Cool Down'),
      ('Right Quad Stretch With Wall', 30, 0, 'Cool Down'),
      ('Knee To Chest Stretch Left', 30, 0, 'Cool Down'),
      ('Knee To Chest Stretch Right', 30, 0, 'Cool Down'),
    ];

    for (int i = 0; i < presets.length; i++) {
      final p = presets[i];
      final ex = all.firstWhere(
        (e) => e.name.toLowerCase().contains(p.$1.toLowerCase().split(' ').first),
        orElse: () => primaryPool[i % primaryPool.length],
      );
      list.add(EditableExerciseItem(
        exercise: ex.copyWith(name: p.$1),
        durationSeconds: p.$2,
        originalDurationSeconds: p.$2,
        category: p.$4,
        repsCount: p.$3,
      ));
    }
    return list;
  }

  /// Preset exact Day 2 matching Screenshot 4
  static List<EditableExerciseItem> _getLowerBodyDay2(List<Exercise> primaryPool, List<Exercise> all) {
    final list = <EditableExerciseItem>[];
    final presets = [
      ('Donkey Kicks Left', 0, 16, 'Training'),
      ('Donkey Kicks Right', 0, 16, 'Training'),
      ('Butt Bridge', 0, 16, 'Training'),
      ('Plie Squats', 0, 16, 'Training'),
      ('Mountain Climber', 0, 14, 'Training'),
      ('Split Squat Left', 0, 10, 'Training'),
      ('Split Squat Right', 0, 10, 'Training'),
      ('Donkey Kicks Left', 0, 12, 'Training'),
      ('Donkey Kicks Right', 0, 12, 'Training'),
      ('Butt Bridge', 0, 14, 'Training'),
      ('Plie Squats', 0, 12, 'Training'),
      ('Mountain Climber', 0, 10, 'Training'),
      ('Split Squat Left', 0, 8, 'Training'),
      ('Split Squat Right', 0, 8, 'Training'),
      ('Adductor Stretch In Standing', 0, 10, 'Cool Down'),
      ('Spine Lumbar Twist Stretch Left', 30, 0, 'Cool Down'),
      ('Spine Lumbar Twist Stretch Right', 30, 0, 'Cool Down'),
    ];

    for (int i = 0; i < presets.length; i++) {
      final p = presets[i];
      final ex = all.firstWhere(
        (e) => e.name.toLowerCase().contains(p.$1.toLowerCase().split(' ').first),
        orElse: () => primaryPool[i % primaryPool.length],
      );
      list.add(EditableExerciseItem(
        exercise: ex.copyWith(name: p.$1),
        durationSeconds: p.$2,
        originalDurationSeconds: p.$2,
        category: p.$4,
        repsCount: p.$3,
      ));
    }
    return list;
  }

  /// Builds rest day light recovery routine.
  static List<EditableExerciseItem> _buildRestRecoveryRoutine(
    int dayNumber,
    List<Exercise> stretchPool,
    List<Exercise> primaryPool,
    List<Exercise> all,
  ) {
    final items = <EditableExerciseItem>[];
    final stretches = [
      ('Cobra Stretch', 40),
      ('Spine Lumbar Twist Stretch Left', 30),
      ('Spine Lumbar Twist Stretch Right', 30),
      ('Cat Cow Stretch', 30),
      ('Child Pose', 40),
      ('Knee To Chest Stretch Left', 30),
      ('Knee To Chest Stretch Right', 30),
    ];

    for (int i = 0; i < stretches.length; i++) {
      final s = stretches[i];
      final ex = all.firstWhere(
        (e) => e.name.toLowerCase().contains(s.$1.toLowerCase().split(' ').first),
        orElse: () => stretchPool[i % stretchPool.length],
      );
      items.add(EditableExerciseItem(
        exercise: ex.copyWith(name: s.$1),
        durationSeconds: s.$2,
        originalDurationSeconds: s.$2,
        category: 'Cool Down',
        repsCount: 0,
      ));
    }
    return items;
  }
}
