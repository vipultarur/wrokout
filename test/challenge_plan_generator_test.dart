import 'package:flutter_test/flutter_test.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/features/challenge/services/challenge_plan_generator.dart';

void main() {
  final sampleExercises = [
    const Exercise(
      id: 'ex_1',
      name: 'Squats',
      bodyPart: 'upper legs',
      equipment: 'body weight',
      exerciseType: 'rep-based',
    ),
    const Exercise(
      id: 'ex_2',
      name: 'Donkey Kicks Left',
      bodyPart: 'glutes',
      equipment: 'body weight',
      exerciseType: 'rep-based',
    ),
    const Exercise(
      id: 'ex_3',
      name: 'Butt Bridge',
      bodyPart: 'glutes',
      equipment: 'body weight',
      exerciseType: 'rep-based',
    ),
    const Exercise(
      id: 'ex_4',
      name: 'Plie Squats',
      bodyPart: 'upper legs',
      equipment: 'body weight',
      exerciseType: 'rep-based',
    ),
    const Exercise(
      id: 'ex_5',
      name: 'Mountain Climber',
      bodyPart: 'waist',
      equipment: 'body weight',
      exerciseType: 'rep-based',
    ),
    const Exercise(
      id: 'ex_6',
      name: 'Jumping Jacks',
      bodyPart: 'full body',
      equipment: 'body weight',
      exerciseType: 'time-based',
      durationSeconds: 30,
    ),
    const Exercise(
      id: 'ex_7',
      name: 'Cobra Stretch',
      bodyPart: 'back',
      equipment: 'body weight',
      exerciseType: 'time-based',
      durationSeconds: 30,
    ),
    const Exercise(
      id: 'ex_8',
      name: 'Spine Lumbar Twist Stretch Left',
      bodyPart: 'back',
      equipment: 'body weight',
      exerciseType: 'time-based',
      durationSeconds: 30,
    ),
  ];

  group('ChallengePlanGenerator Tests', () {
    test('generates dynamic plans for different days', () {
      final day1Plan = ChallengePlanGenerator.generatePlan(
        challengeTitle: 'LOWER BODY CHALLENGE',
        dayNumber: 1,
        level: 'Intermediate',
        allExercises: sampleExercises,
      );

      final day2Plan = ChallengePlanGenerator.generatePlan(
        challengeTitle: 'LOWER BODY CHALLENGE',
        dayNumber: 2,
        level: 'Intermediate',
        allExercises: sampleExercises,
      );

      expect(day1Plan.items.isNotEmpty, isTrue);
      expect(day2Plan.items.isNotEmpty, isTrue);
      expect(day1Plan.estimatedMinutes, greaterThan(0));
      expect(day2Plan.estimatedMinutes, greaterThan(0));

      // Day 1 and Day 2 should have unique exercise names/structures
      final day1Names = day1Plan.items.map((e) => e.exercise.name).toList();
      final day2Names = day2Plan.items.map((e) => e.exercise.name).toList();
      expect(day1Names, isNot(equals(day2Names)));
    });

    test('generates appropriate rest day recovery plan on day 7', () {
      final day7Plan = ChallengePlanGenerator.generatePlan(
        challengeTitle: 'FULL BODY SHRED',
        dayNumber: 7,
        level: 'Beginner',
        allExercises: sampleExercises,
      );

      expect(day7Plan.items.isNotEmpty, isTrue);
      expect(day7Plan.items.every((item) => item.category == 'Cool Down' || item.durationSeconds > 0), isTrue);
    });
  });
}
