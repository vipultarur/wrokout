import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout/core/utils/logger.dart';
import 'package:workout/data/providers/user_profile_provider.dart';

/// Single exercise item within a custom workout routine.
class CustomExerciseItem {
  final String exerciseId;
  final String name;
  final String imagePath;
  final String gifUrl;
  final String bodyPart;
  final int sets;
  final int reps;
  final int durationSeconds;
  final bool isTimeBased;

  const CustomExerciseItem({
    required this.exerciseId,
    required this.name,
    required this.imagePath,
    this.gifUrl = '',
    this.bodyPart = '',
    this.sets = 1,
    this.reps = 10,
    this.durationSeconds = 20,
    this.isTimeBased = false,
  });

  String get displayMetric => isTimeBased ? formatTime(durationSeconds) : 'x$reps';

  static String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  CustomExerciseItem copyWith({
    String? exerciseId,
    String? name,
    String? imagePath,
    String? gifUrl,
    String? bodyPart,
    int? sets,
    int? reps,
    int? durationSeconds,
    bool? isTimeBased,
  }) {
    return CustomExerciseItem(
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      gifUrl: gifUrl ?? this.gifUrl,
      bodyPart: bodyPart ?? this.bodyPart,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isTimeBased: isTimeBased ?? this.isTimeBased,
    );
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'name': name,
        'imagePath': imagePath,
        'gifUrl': gifUrl,
        'bodyPart': bodyPart,
        'sets': sets,
        'reps': reps,
        'durationSeconds': durationSeconds,
        'isTimeBased': isTimeBased,
      };

  factory CustomExerciseItem.fromJson(Map<String, dynamic> json) {
    return CustomExerciseItem(
      exerciseId: json['exerciseId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      gifUrl: json['gifUrl'] as String? ?? '',
      bodyPart: json['bodyPart'] as String? ?? '',
      sets: json['sets'] as int? ?? 1,
      reps: json['reps'] as int? ?? 10,
      durationSeconds: json['durationSeconds'] as int? ?? 20,
      isTimeBased: json['isTimeBased'] as bool? ?? false,
    );
  }
}

/// Custom Workout Plan entity matching user created routines.
class CustomWorkoutPlan {
  final String id;
  final String name;
  final List<CustomExerciseItem> exercises;
  final DateTime createdAt;

  const CustomWorkoutPlan({
    required this.id,
    required this.name,
    required this.exercises,
    required this.createdAt,
  });

  int get exerciseCount => exercises.length;

  int get estimatedMinutes {
    int totalSec = 0;
    for (final ex in exercises) {
      if (ex.isTimeBased) {
        totalSec += ex.durationSeconds + 15;
      } else {
        totalSec += (ex.reps * 3) + 15;
      }
    }
    final mins = (totalSec / 60).ceil();
    return mins > 0 ? mins : 1;
  }

  CustomWorkoutPlan copyWith({
    String? id,
    String? name,
    List<CustomExerciseItem>? exercises,
    DateTime? createdAt,
  }) {
    return CustomWorkoutPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory CustomWorkoutPlan.fromJson(Map<String, dynamic> json) {
    return CustomWorkoutPlan(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      exercises: (json['exercises'] as List?)
              ?.map((e) => CustomExerciseItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Riverpod provider for managing state and persistence of Custom Workouts.
final customWorkoutsProvider =
    StateNotifierProvider<CustomWorkoutsNotifier, List<CustomWorkoutPlan>>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return CustomWorkoutsNotifier(prefs);
});

class CustomWorkoutsNotifier extends StateNotifier<List<CustomWorkoutPlan>> {
  final SharedPreferences _prefs;
  static const _storageKey = 'custom_workouts_plans';

  CustomWorkoutsNotifier(this._prefs) : super(const []) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List list = json.decode(rawJson) as List;
        final loaded = list
            .map((e) => CustomWorkoutPlan.fromJson(e as Map<String, dynamic>))
            .toList();
        state = loaded;
      } catch (e, st) {
        AppLogger.error('Failed to parse custom workouts from storage', e, st);
      }
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final encoded = json.encode(state.map((e) => e.toJson()).toList());
      await _prefs.setString(_storageKey, encoded);
    } catch (e, st) {
      AppLogger.error('Failed to save custom workouts to storage', e, st);
    }
  }

  Future<void> saveWorkout(CustomWorkoutPlan workout) async {
    final index = state.indexWhere((w) => w.id == workout.id);
    if (index >= 0) {
      final updatedList = List<CustomWorkoutPlan>.from(state);
      updatedList[index] = workout;
      state = updatedList;
    } else {
      state = [workout, ...state];
    }
    await _saveToStorage();
  }

  Future<void> deleteWorkout(String id) async {
    state = state.where((w) => w.id != id).toList();
    await _saveToStorage();
  }

  CustomWorkoutPlan? getWorkoutById(String id) {
    try {
      return state.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }
}
