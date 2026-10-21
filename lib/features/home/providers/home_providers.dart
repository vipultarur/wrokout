import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/data/providers/exercise_provider.dart';

// ─── Body Part Mapping for Tab → Dataset Filter ───
const bodyFocusTabMap = <String, String>{
  'Abs': 'waist',
  'Arm': 'upper arms',
  'Forearm': 'lower arms',
  'Chest': 'chest',
  'Legs': 'upper legs',
  'Back': 'back',
  'Shoulders': 'shoulders',
  'Cardio': 'cardio',
};

/// Home Screen Provider: exercises grouped by the selected body-focus tab.
final selectedBodyFocusProvider = StateProvider<String>((ref) => 'Abs');

final bodyFocusExercisesProvider = Provider<List<Exercise>>((ref) {
  final selectedTab = ref.watch(selectedBodyFocusProvider);
  final asyncExercises = ref.watch(allExercisesProvider);
  final exercises = asyncExercises.value ?? [];
  final datasetBodyPart = bodyFocusTabMap[selectedTab] ?? 'waist';
  return exercises.where((e) => e.bodyPart == datasetBodyPart).toList();
});

/// Quick filter state provider.
final selectedQuickFilterProvider = StateProvider<String>((ref) => '');

/// Popular goals tab state provider.
final selectedPopularGoalProvider = StateProvider<String>((ref) => 'Build Muscle');

/// Memoized provider for challenge chest exercises
final challengeChestExercisesProvider = Provider<List<Exercise>>((ref) {
  final exercises = ref.watch(allExercisesProvider).value ?? [];
  return exercises.where((e) => e.bodyPart == 'chest').take(3).toList();
});

/// Memoized provider for challenge waist exercises
final challengeWaistExercisesProvider = Provider<List<Exercise>>((ref) {
  final exercises = ref.watch(allExercisesProvider).value ?? [];
  return exercises.where((e) => e.bodyPart == 'waist').take(3).toList();
});

/// Memoized provider for recommended exercises
final recommendedExercisesProvider = Provider<List<Exercise>>((ref) {
  final exercises = ref.watch(allExercisesProvider).value ?? [];
  return exercises.where((e) => e.equipment == 'body weight').take(7).toList();
});

/// Memoized provider for Just For You presets
final justForYouPresetsProvider = Provider<List<WorkoutPreset>>((ref) {
  final exercises = ref.watch(allExercisesProvider).value ?? [];
  if (exercises.isEmpty) return const [];

  final justForYou = <WorkoutPreset>[];
  final backExercises = exercises.where((e) => e.bodyPart == 'back').toList();
  final shoulderExercises = exercises.where((e) => e.bodyPart == 'shoulders').toList();
  final upperLegExercises = exercises.where((e) => e.bodyPart == 'upper legs').toList();
  final chestExercises = exercises.where((e) => e.bodyPart == 'chest').toList();

  // 1. V-Taper: Back + Shoulders focus
  final vTaperList = <Exercise>[];
  if (backExercises.length >= 4) vTaperList.addAll(backExercises.take(4));
  if (shoulderExercises.length >= 4) vTaperList.addAll(shoulderExercises.take(4));

  if (vTaperList.isNotEmpty) {
    justForYou.add(WorkoutPreset(
      title: 'Intense V-Taper Challenge',
      subtitle: '16 min · Advanced',
      exercises: vTaperList,
    ));
  }

  // 2. Full Body: Compound split across Chest, Back, Legs, Shoulders
  final fullBodyList = <Exercise>[];
  if (chestExercises.length >= 2) fullBodyList.addAll(chestExercises.take(2));
  if (backExercises.length >= 2) fullBodyList.addAll(backExercises.take(2));
  if (upperLegExercises.length >= 2) fullBodyList.addAll(upperLegExercises.take(2));
  if (shoulderExercises.length >= 2) fullBodyList.addAll(shoulderExercises.take(2));

  if (fullBodyList.isNotEmpty) {
    justForYou.add(WorkoutPreset(
      title: 'Full Body Muscle Growth',
      subtitle: '16 min · Intermediate',
      exercises: fullBodyList,
    ));
  }

  // 3. Shoulder Sculpt: Shoulders focus
  if (shoulderExercises.length >= 5) {
    justForYou.add(WorkoutPreset(
      title: 'Shoulder Sculpt Express',
      subtitle: '10 min · Beginner',
      exercises: shoulderExercises.sublist(0, 5),
    ));
  }
  return justForYou;
});

/// Memoized provider for stretch & warm up exercises
final stretchExercisesProvider = Provider<Map<String, List<Exercise>>>((ref) {
  final exercises = ref.watch(allExercisesProvider).value ?? [];
  final stretchExercises = exercises
      .where((e) =>
          e.equipment == 'body weight' &&
          (e.bodyPart == 'back' || e.bodyPart == 'upper legs' || e.bodyPart == 'waist'))
      .toList();

  final backRelief = stretchExercises.where((e) => e.bodyPart == 'back').take(7).toList();
  final lowerBody = stretchExercises.where((e) => e.bodyPart == 'upper legs').take(9).toList();

  return {
    'backRelief': backRelief,
    'lowerBody': lowerBody,
  };
});

/// Memoized provider for popular goals presets
final popularGoalsPresetsProvider = Provider<List<GoalPreset>>((ref) {
  final selectedGoal = ref.watch(selectedPopularGoalProvider);
  final exercises = ref.watch(allExercisesProvider).value ?? [];
  const goalBodyParts = <String, List<String>>{
    'Build Muscle': ['chest', 'upper arms', 'back'],
    'Burn Fat': ['cardio', 'waist', 'upper legs'],
    'Keep Fit': ['shoulders', 'lower arms', 'lower legs'],
  };

  final bodyParts = goalBodyParts[selectedGoal] ?? ['chest'];
  final presets = <GoalPreset>[];
  for (final part in bodyParts) {
    final partExercises = exercises.where((e) => e.bodyPart == part).toList();
    if (partExercises.isEmpty) continue;

    final count = min(partExercises.length, 12);
    final selectedExercises = partExercises.sublist(0, count);
    
    int totalSec = 0;
    for (int i = 0; i < selectedExercises.length; i++) {
      final ex = selectedExercises[i];
      final exSec = ex.isTimeBased ? (ex.durationSeconds > 0 ? ex.durationSeconds : 30) : 30;
      totalSec += exSec;
      if (i < selectedExercises.length - 1) {
        totalSec += 20; // 20s rest interval
      }
    }
    final mins = totalSec > 0 ? (totalSec / 60).round().clamp(1, 120) : (count * 1.5).round();
    final levels = ['Beginner', 'Intermediate', 'Advanced'];
    final level = levels[(presets.length) % 3];

    presets.add(GoalPreset(
      title: '${capitalize(part)} ${selectedGoal == 'Build Muscle' ? 'Building Circuit' : selectedGoal == 'Burn Fat' ? 'Fat Burner' : 'Fitness Routine'}',
      subtitle: '$mins min · $level',
      exercise: selectedExercises.first,
      exerciseCount: count,
    ));
  }
  return presets;
});

String capitalize(String s) {
  if (s.isEmpty) return s;
  return s.split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
}

class WorkoutPreset {
  final String title;
  final String subtitle;
  final List<Exercise> exercises;

  const WorkoutPreset({
    required this.title,
    required this.subtitle,
    required this.exercises,
  });
}

class GoalPreset {
  final String title;
  final String subtitle;
  final Exercise exercise;
  final int exerciseCount;

  const GoalPreset({
    required this.title,
    required this.subtitle,
    required this.exercise,
    required this.exerciseCount,
  });
}
