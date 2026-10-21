import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout/core/utils/logger.dart';
import 'package:workout/data/providers/user_profile_provider.dart';

/// Exercise summary model embedded inside a WorkoutSessionLog.
class ExerciseLogSummary {
  final String id;
  final String name;
  final String imagePath;
  final String bodyPart;
  final int durationSeconds;

  const ExerciseLogSummary({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.bodyPart,
    this.durationSeconds = 30,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imagePath': imagePath,
        'bodyPart': bodyPart,
        'durationSeconds': durationSeconds,
      };

  factory ExerciseLogSummary.fromJson(Map<String, dynamic> json) =>
      ExerciseLogSummary(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        imagePath: json['imagePath'] as String? ?? '',
        bodyPart: json['bodyPart'] as String? ?? '',
        durationSeconds: json['durationSeconds'] as int? ?? 30,
      );
}

/// Workout session log data model.
class WorkoutSessionLog {
  final String id;
  final String title;
  final int durationSeconds;
  final int caloriesBurned;
  final int exerciseCount;
  final DateTime date;
  final String rating;
  final List<ExerciseLogSummary> exercises;

  const WorkoutSessionLog({
    required this.id,
    required this.title,
    required this.durationSeconds,
    required this.caloriesBurned,
    required this.exerciseCount,
    required this.date,
    this.rating = 'Moderate',
    this.exercises = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'durationSeconds': durationSeconds,
        'caloriesBurned': caloriesBurned,
        'exerciseCount': exerciseCount,
        'date': date.toIso8601String(),
        'rating': rating,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory WorkoutSessionLog.fromJson(Map<String, dynamic> json) =>
      WorkoutSessionLog(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        durationSeconds: json['durationSeconds'] as int? ?? 0,
        caloriesBurned: json['caloriesBurned'] as int? ?? 0,
        exerciseCount: json['exerciseCount'] as int? ?? 0,
        date: json['date'] != null
            ? DateTime.parse(json['date'] as String)
            : DateTime.now(),
        rating: json['rating'] as String? ?? 'Moderate',
        exercises: (json['exercises'] as List?)
                ?.map((e) => ExerciseLogSummary.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

/// Weight entry log model.
class WeightLogEntry {
  final DateTime date;
  final double weightKg;

  const WeightLogEntry({required this.date, required this.weightKg});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'weightKg': weightKg,
      };

  factory WeightLogEntry.fromJson(Map<String, dynamic> json) => WeightLogEntry(
        date: json['date'] != null
            ? DateTime.parse(json['date'] as String)
            : DateTime.now(),
        weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
      );
}

/// Provider for managing workout history and weight logs.
final workoutHistoryProvider =
    StateNotifierProvider<WorkoutHistoryNotifier, WorkoutHistoryState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return WorkoutHistoryNotifier(prefs);
});

class WorkoutHistoryState {
  final List<WorkoutSessionLog> sessions;
  final List<WeightLogEntry> weightLogs;

  const WorkoutHistoryState({
    this.sessions = const [],
    this.weightLogs = const [],
  });

  int get totalWorkouts => sessions.length;

  int get totalCalories =>
      sessions.fold(0, (sum, item) => sum + item.caloriesBurned);

  int get totalMinutes =>
      (sessions.fold<int>(0, (sum, item) => sum + item.durationSeconds) / 60).round();

  /// Returns total session minutes as a proxy for training volume.
  /// Shown in the Report screen under "Volume(kg)" label (relabelled in UI to "Min").
  int get totalVolumeKg => totalMinutes;

  int get todayMinutes {
    final now = DateTime.now();
    final todaySessions = sessions.where((s) =>
        s.date.year == now.year &&
        s.date.month == now.month &&
        s.date.day == now.day);
    final totalSecs = todaySessions.fold(0, (sum, s) => sum + s.durationSeconds);
    return (totalSecs / 60).round();
  }

  double get weeklyAvgMinutes {
    final now = DateTime.now();
    // Calculate start of current week (Monday=1 in Dart's weekday)
    // now.weekday: Mon=1, Tue=2, ..., Sun=7
    final daysFromMonday = now.weekday - DateTime.monday; // 0..6
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: daysFromMonday));
    final weekSessions = sessions.where(
      (s) => s.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))),
    );
    final totalMins =
        weekSessions.fold(0, (sum, s) => sum + (s.durationSeconds / 60).round());
    // Divide by days elapsed this week (at least 1)
    final daysElapsed = daysFromMonday + 1; // 1..7
    return totalMins / daysElapsed;
  }

  List<Map<String, dynamic>> getWeeklyWorkoutCounts({int numWeeks = 8}) {
    final now = DateTime.now();
    final results = <Map<String, dynamic>>[];

    // Align to current Monday (Dart weekday: Mon=1..Sun=7)
    final daysFromMonday = now.weekday - DateTime.monday; // 0..6
    final currentWeekMonday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: daysFromMonday));

    for (int i = numWeeks - 1; i >= 0; i--) {
      final weekStart = currentWeekMonday.subtract(Duration(days: i * 7));
      final weekEnd = weekStart
          .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      final count = sessions
          .where((s) =>
              s.date.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
              s.date.isBefore(weekEnd))
          .length;

      const monthNames = [
        'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
        'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
      ];
      final label = '${weekStart.day} ${monthNames[weekStart.month - 1]}';

      results.add({'label': label, 'count': count, 'start': weekStart});
    }
    return results;
  }

  Map<String, int> getMuscleFrequencies(String timeframe) {
    final now = DateTime.now();
    DateTime cutoff;
    if (timeframe == 'This Week') {
      cutoff = now.subtract(Duration(days: now.weekday % 7));
    } else if (timeframe == 'This Month') {
      cutoff = DateTime(now.year, now.month, 1);
    } else {
      cutoff = DateTime(2000, 1, 1);
    }

    final filteredSessions = sessions.where((s) => s.date.isAfter(cutoff));
    final map = <String, int>{};

    for (final session in filteredSessions) {
      for (final ex in session.exercises) {
        final part = ex.bodyPart.toLowerCase();
        map[part] = (map[part] ?? 0) + 1;
      }
      if (session.exercises.isEmpty) {
        // Infer body parts from session title if exercises list is empty
        final title = session.title.toLowerCase();
        if (title.contains('abs') || title.contains('core')) {
          map['waist'] = (map['waist'] ?? 0) + 3;
        } else if (title.contains('chest')) {
          map['chest'] = (map['chest'] ?? 0) + 3;
        } else if (title.contains('arm')) {
          map['upper arms'] = (map['upper arms'] ?? 0) + 3;
        } else if (title.contains('leg')) {
          map['upper legs'] = (map['upper legs'] ?? 0) + 3;
        } else {
          map['waist'] = (map['waist'] ?? 0) + 1;
          map['chest'] = (map['chest'] ?? 0) + 1;
          map['upper arms'] = (map['upper arms'] ?? 0) + 1;
        }
      }
    }
    return map;
  }

  WorkoutHistoryState copyWith({
    List<WorkoutSessionLog>? sessions,
    List<WeightLogEntry>? weightLogs,
  }) {
    return WorkoutHistoryState(
      sessions: sessions ?? this.sessions,
      weightLogs: weightLogs ?? this.weightLogs,
    );
  }
}

class WorkoutHistoryNotifier extends StateNotifier<WorkoutHistoryState> {
  final SharedPreferences _prefs;
  // PRESERVED: exact SharedPrefs keys
  static const _sessionsKey = 'workout_sessions_history';
  static const _weightKey = 'weight_logs_history';

  WorkoutHistoryNotifier(this._prefs) : super(const WorkoutHistoryState()) {
    _loadHistory();
  }

  void _loadHistory() {
    final sessionsJson = _prefs.getString(_sessionsKey);
    final weightJson = _prefs.getString(_weightKey);

    List<WorkoutSessionLog> loadedSessions = [];
    if (sessionsJson != null) {
      try {
        final list = json.decode(sessionsJson) as List;
        loadedSessions = list
            .map((e) => WorkoutSessionLog.fromJson(e as Map<String, dynamic>))
            .where((s) => s.id != '1' && s.id != '2' && s.id != '3') // Exclude legacy dummy mock data
            .toList();
      } catch (e, st) {
        AppLogger.error('Failed to parse sessions history', e, st);
      }
    }

    List<WeightLogEntry> loadedWeight = [];
    if (weightJson != null) {
      try {
        final list = json.decode(weightJson) as List;
        loadedWeight = list
            .map((e) => WeightLogEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e, st) {
        AppLogger.error('Failed to parse weight history', e, st);
      }
    }

    state = WorkoutHistoryState(
      sessions: loadedSessions,
      weightLogs: loadedWeight,
    );
  }

  Future<void> addSession(WorkoutSessionLog session) async {
    try {
      final updated = [session, ...state.sessions];
      state = state.copyWith(sessions: updated);
      await _prefs.setString(
          _sessionsKey, json.encode(updated.map((e) => e.toJson()).toList()));
    } catch (e, st) {
      AppLogger.error('Failed to save workout session', e, st);
    }
  }

  Future<void> addWeightEntry(double weightKg) async {
    try {
      final entry = WeightLogEntry(date: DateTime.now(), weightKg: weightKg);
      final updated = [...state.weightLogs, entry];
      state = state.copyWith(weightLogs: updated);
      await _prefs.setString(
          _weightKey, json.encode(updated.map((e) => e.toJson()).toList()));
    } catch (e, st) {
      AppLogger.error('Failed to save weight entry', e, st);
    }
  }
}
