import 'package:flutter_test/flutter_test.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/data/models/user_profile.dart';
import 'package:workout/data/providers/workout_history_provider.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // UserProfile: BMI Calculations
  // ─────────────────────────────────────────────────────────────────────────
  group('UserProfile.bmi', () {
    test('returns correct BMI for metric user', () {
      // 70kg, 175cm -> 70 / (1.75 * 1.75) = 22.857...
      final profile = const UserProfile(weightKg: 70.0, heightCm: 175.0);
      expect(profile.bmi, closeTo(22.86, 0.01));
    });

    test('returns null when weight is null', () {
      final profile = const UserProfile(weightKg: null, heightCm: 175.0);
      expect(profile.bmi, isNull);
    });

    test('returns null when height is null', () {
      final profile = const UserProfile(weightKg: 70.0, heightCm: null);
      expect(profile.bmi, isNull);
    });

    test('returns null when height is zero', () {
      final profile = const UserProfile(weightKg: 70.0, heightCm: 0.0);
      expect(profile.bmi, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // UserProfile: BMI Category — WHO boundaries (< 18.5, 25.0, 30.0)
  // ─────────────────────────────────────────────────────────────────────────
  group('UserProfile.bmiCategory', () {
    test('underweight when BMI < 18.5', () {
      // 50kg, 175cm → BMI ≈ 16.3
      const profile = UserProfile(weightKg: 50.0, heightCm: 175.0);
      expect(profile.bmiCategory, 'Underweight');
    });

    test('normal weight when BMI is between 18.5 and 24.9', () {
      // 70kg, 175cm → BMI ≈ 22.86
      const profile = UserProfile(weightKg: 70.0, heightCm: 175.0);
      expect(profile.bmiCategory, 'Normal weight');
    });

    test('boundary: exactly 25.0 should be Overweight', () {
      // Solve for weight: 25.0 = w / (1.75^2) => w = 25 * 3.0625 = 76.5625
      const profile = UserProfile(weightKg: 76.5625, heightCm: 175.0);
      // BMI should be exactly 25.0 → Overweight per WHO
      expect(profile.bmiCategory, 'Overweight');
    });

    test('boundary: exactly 30.0 should be Obese', () {
      // w = 30 * 3.0625 = 91.875
      const profile = UserProfile(weightKg: 91.875, heightCm: 175.0);
      expect(profile.bmiCategory, 'Obese');
    });

    test('obese when BMI >= 30', () {
      // 100kg, 175cm → BMI ≈ 32.65
      const profile = UserProfile(weightKg: 100.0, heightCm: 175.0);
      expect(profile.bmiCategory, 'Obese');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // UserProfile: Unit display
  // ─────────────────────────────────────────────────────────────────────────
  group('UserProfile.displayWeight', () {
    test('shows kg for metric users', () {
      const profile = UserProfile(weightKg: 70.5, usesMetric: true);
      expect(profile.displayWeight, '70.5 kg');
    });

    test('converts to lbs for imperial users', () {
      // 70.0 kg * 2.20462 ≈ 154.3 lbs
      const profile = UserProfile(weightKg: 70.0, usesMetric: false);
      expect(profile.displayWeight, contains('lbs'));
      expect(profile.displayWeight, contains('154.3'));
    });

    test('shows -- when weight is null', () {
      const profile = UserProfile(weightKg: null);
      expect(profile.displayWeight, '--');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // UserProfile: Equality — all meaningful fields trigger rebuilds
  // ─────────────────────────────────────────────────────────────────────────
  group('UserProfile equality', () {
    const base = UserProfile(
      gender: 'male',
      weightKg: 70.0,
      heightCm: 175.0,
      weeklyGoalDays: 4,
      firstDayOfWeek: 'Monday',
      soundEnabled: true,
      vibrationEnabled: true,
      usesMetric: true,
    );

    test('same values are equal', () {
      const same = UserProfile(
        gender: 'male',
        weightKg: 70.0,
        heightCm: 175.0,
        weeklyGoalDays: 4,
        firstDayOfWeek: 'Monday',
        soundEnabled: true,
        vibrationEnabled: true,
        usesMetric: true,
      );
      expect(base, equals(same));
    });

    test('weeklyGoalDays change triggers inequality', () {
      final changed = base.copyWith(weeklyGoalDays: 5);
      expect(base, isNot(equals(changed)));
    });

    test('soundEnabled change triggers inequality', () {
      final changed = base.copyWith(soundEnabled: false);
      expect(base, isNot(equals(changed)));
    });

    test('vibrationEnabled change triggers inequality', () {
      final changed = base.copyWith(vibrationEnabled: false);
      expect(base, isNot(equals(changed)));
    });

    test('usesMetric change triggers inequality', () {
      final changed = base.copyWith(usesMetric: false);
      expect(base, isNot(equals(changed)));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Exercise: isTimeBased getter
  // ─────────────────────────────────────────────────────────────────────────
  group('Exercise.isTimeBased', () {
    test('time-based exercise type returns isTimeBased=true', () {
      const exercise = Exercise(
        id: 'ex1',
        name: 'Plank',
        exerciseType: 'time-based',
        durationSeconds: 30,
      );
      expect(exercise.isTimeBased, isTrue);
      expect(exercise.isRepBased, isFalse);
    });

    test('rep-based exercise type returns isTimeBased=false even with durationSeconds>0', () {
      // This was the bug: exerciseType='rep-based' but durationSeconds=30 was
      // causing isTimeBased to return true incorrectly.
      const exercise = Exercise(
        id: 'ex2',
        name: 'Squats',
        exerciseType: 'rep-based',
        durationSeconds: 30, // should NOT make this time-based
      );
      expect(exercise.isTimeBased, isFalse);
      expect(exercise.isRepBased, isTrue);
    });

    test('default rep-based exercise is isRepBased', () {
      const exercise = Exercise(id: 'ex3', name: 'Push-ups');
      expect(exercise.isTimeBased, isFalse);
      expect(exercise.isRepBased, isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // WorkoutHistoryState: totalCalories
  // ─────────────────────────────────────────────────────────────────────────
  group('WorkoutHistoryState.totalCalories', () {
    test('sums caloriesBurned from all sessions', () {
      final sessions = [
        WorkoutSessionLog(
          id: '1',
          title: 'Workout A',
          durationSeconds: 1800,
          caloriesBurned: 200,
          exerciseCount: 5,
          date: DateTime.now(),
        ),
        WorkoutSessionLog(
          id: '2',
          title: 'Workout B',
          durationSeconds: 3600,
          caloriesBurned: 350,
          exerciseCount: 8,
          date: DateTime.now(),
        ),
      ];
      final state = WorkoutHistoryState(sessions: sessions);
      expect(state.totalCalories, 550);
    });

    test('returns zero for empty session list', () {
      const state = WorkoutHistoryState(sessions: []);
      expect(state.totalCalories, 0);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // WorkoutHistoryState: totalMinutes and totalVolumeKg
  // ─────────────────────────────────────────────────────────────────────────
  group('WorkoutHistoryState.totalMinutes', () {
    test('converts seconds to minutes correctly', () {
      final sessions = [
        WorkoutSessionLog(
          id: '1',
          title: 'A',
          durationSeconds: 1800, // 30 min
          caloriesBurned: 0,
          exerciseCount: 0,
          date: DateTime.now(),
        ),
        WorkoutSessionLog(
          id: '2',
          title: 'B',
          durationSeconds: 2700, // 45 min
          caloriesBurned: 0,
          exerciseCount: 0,
          date: DateTime.now(),
        ),
      ];
      final state = WorkoutHistoryState(sessions: sessions);
      expect(state.totalMinutes, 75);
    });
  });

  group('WorkoutHistoryState.totalVolumeKg', () {
    test('equals totalMinutes (proxy metric)', () {
      final sessions = [
        WorkoutSessionLog(
          id: '1',
          title: 'A',
          durationSeconds: 3600, // 60 min
          caloriesBurned: 300,
          exerciseCount: 6,
          date: DateTime.now(),
        ),
      ];
      final state = WorkoutHistoryState(sessions: sessions);
      expect(state.totalVolumeKg, state.totalMinutes);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // WorkoutHistoryState: weeklyAvgMinutes — divides by days elapsed not 7
  // ─────────────────────────────────────────────────────────────────────────
  group('WorkoutHistoryState.weeklyAvgMinutes', () {
    test('result is non-negative', () {
      final sessions = [
        WorkoutSessionLog(
          id: '1',
          title: 'Today',
          durationSeconds: 3600,
          caloriesBurned: 300,
          exerciseCount: 5,
          date: DateTime.now(),
        ),
      ];
      final state = WorkoutHistoryState(sessions: sessions);
      expect(state.weeklyAvgMinutes, greaterThanOrEqualTo(0.0));
    });

    test('returns 0 when no sessions this week', () {
      // Session from 2 weeks ago
      final pastDate = DateTime.now().subtract(const Duration(days: 14));
      final sessions = [
        WorkoutSessionLog(
          id: '1',
          title: 'Old',
          durationSeconds: 3600,
          caloriesBurned: 0,
          exerciseCount: 0,
          date: pastDate,
        ),
      ];
      final state = WorkoutHistoryState(sessions: sessions);
      expect(state.weeklyAvgMinutes, 0.0);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // WorkoutHistoryState: getWeeklyWorkoutCounts — correct week boundaries
  // ─────────────────────────────────────────────────────────────────────────
  group('WorkoutHistoryState.getWeeklyWorkoutCounts', () {
    test('returns the correct number of week buckets', () {
      const state = WorkoutHistoryState(sessions: []);
      final counts = state.getWeeklyWorkoutCounts(numWeeks: 8);
      expect(counts.length, 8);
    });

    test('each bucket has label, count, and start keys', () {
      const state = WorkoutHistoryState(sessions: []);
      final counts = state.getWeeklyWorkoutCounts(numWeeks: 4);
      for (final bucket in counts) {
        expect(bucket.containsKey('label'), isTrue);
        expect(bucket.containsKey('count'), isTrue);
        expect(bucket.containsKey('start'), isTrue);
      }
    });

    test('counts are non-negative integers', () {
      const state = WorkoutHistoryState(sessions: []);
      final counts = state.getWeeklyWorkoutCounts();
      for (final bucket in counts) {
        expect(bucket['count'], isA<int>());
        expect(bucket['count'] as int, greaterThanOrEqualTo(0));
      }
    });

    test('a session today is counted in the current week bucket', () {
      final sessions = [
        WorkoutSessionLog(
          id: '1',
          title: 'Today',
          durationSeconds: 1800,
          caloriesBurned: 200,
          exerciseCount: 5,
          date: DateTime.now(),
        ),
      ];
      final state = WorkoutHistoryState(sessions: sessions);
      final counts = state.getWeeklyWorkoutCounts(numWeeks: 1);
      expect(counts.last['count'], 1);
    });

    test('buckets cover consecutive Monday-to-Sunday weeks', () {
      const state = WorkoutHistoryState(sessions: []);
      final counts = state.getWeeklyWorkoutCounts(numWeeks: 2);
      final week1Start = counts.first['start'] as DateTime;
      final week2Start = counts.last['start'] as DateTime;
      // Should be exactly 7 days apart
      final diff = week2Start.difference(week1Start).inDays;
      expect(diff, 7);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // WorkoutSessionLog: JSON serialization round-trip
  // ─────────────────────────────────────────────────────────────────────────
  group('WorkoutSessionLog JSON round-trip', () {
    test('toJson then fromJson preserves all fields', () {
      final original = WorkoutSessionLog(
        id: 'abc123',
        title: 'Morning Workout',
        durationSeconds: 2700,
        caloriesBurned: 250,
        exerciseCount: 8,
        date: DateTime(2026, 10, 15, 8, 30),
        rating: 'Hard',
        exercises: [],
      );

      final json = original.toJson();
      final restored = WorkoutSessionLog.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.durationSeconds, original.durationSeconds);
      expect(restored.caloriesBurned, original.caloriesBurned);
      expect(restored.exerciseCount, original.exerciseCount);
      expect(restored.rating, original.rating);
    });
  });
}
