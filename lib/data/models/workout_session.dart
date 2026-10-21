/// Workout session log — records a completed workout.
class WorkoutSession {
  final String id;
  final String workoutId;
  final String workoutName;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final int caloriesBurned;
  final double totalVolume;
  final List<ExerciseLog> exerciseLogs;

  const WorkoutSession({
    required this.id,
    required this.workoutId,
    required this.workoutName,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    this.caloriesBurned = 0,
    this.totalVolume = 0,
    this.exerciseLogs = const [],
  });

  int get durationMinutes => (durationSeconds / 60).round();

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String? ?? '',
      workoutId: json['workoutId'] as String? ?? '',
      workoutName: json['workoutName'] as String? ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : DateTime.now(),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      caloriesBurned: json['caloriesBurned'] as int? ?? 0,
      totalVolume: (json['totalVolume'] as num?)?.toDouble() ?? 0.0,
      exerciseLogs: (json['exerciseLogs'] as List?)
              ?.map((e) => ExerciseLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutId': workoutId,
      'workoutName': workoutName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationSeconds': durationSeconds,
      'caloriesBurned': caloriesBurned,
      'totalVolume': totalVolume,
      'exerciseLogs': exerciseLogs.map((e) => e.toJson()).toList(),
    };
  }

  WorkoutSession copyWith({
    String? id,
    String? workoutId,
    String? workoutName,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    int? caloriesBurned,
    double? totalVolume,
    List<ExerciseLog>? exerciseLogs,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      workoutName: workoutName ?? this.workoutName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      totalVolume: totalVolume ?? this.totalVolume,
      exerciseLogs: exerciseLogs ?? this.exerciseLogs,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSession &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WorkoutSession(id: $id, workoutName: $workoutName)';
}

/// Log for a single exercise within a workout session.
class ExerciseLog {
  final String exerciseId;
  final String exerciseName;
  final List<SetLog> sets;

  const ExerciseLog({
    required this.exerciseId,
    required this.exerciseName,
    this.sets = const [],
  });

  double get totalVolume =>
      sets.fold(0.0, (sum, s) => sum + (s.weight * s.reps));

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    return ExerciseLog(
      exerciseId: json['exerciseId'] as String? ?? '',
      exerciseName: json['exerciseName'] as String? ?? '',
      sets: (json['sets'] as List?)
              ?.map((e) => SetLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets.map((e) => e.toJson()).toList(),
    };
  }

  ExerciseLog copyWith({
    String? exerciseId,
    String? exerciseName,
    List<SetLog>? sets,
  }) {
    return ExerciseLog(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseLog &&
          runtimeType == other.runtimeType &&
          exerciseId == other.exerciseId;

  @override
  int get hashCode => exerciseId.hashCode;

  @override
  String toString() => 'ExerciseLog(exerciseId: $exerciseId, name: $exerciseName)';
}

/// Log for a single set.
class SetLog {
  final int setNumber;
  final int reps;
  final double weight;
  final int durationSeconds;
  final bool completed;

  const SetLog({
    required this.setNumber,
    this.reps = 0,
    this.weight = 0,
    this.durationSeconds = 0,
    this.completed = true,
  });

  factory SetLog.fromJson(Map<String, dynamic> json) {
    return SetLog(
      setNumber: json['setNumber'] as int? ?? 1,
      reps: json['reps'] as int? ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      completed: json['completed'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'reps': reps,
      'weight': weight,
      'durationSeconds': durationSeconds,
      'completed': completed,
    };
  }

  SetLog copyWith({
    int? setNumber,
    int? reps,
    double? weight,
    int? durationSeconds,
    bool? completed,
  }) {
    return SetLog(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completed: completed ?? this.completed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetLog &&
          runtimeType == other.runtimeType &&
          setNumber == other.setNumber;

  @override
  int get hashCode => setNumber.hashCode;

  @override
  String toString() => 'SetLog(setNumber: $setNumber, reps: $reps, weight: $weight)';
}

/// Body measurement record.
class BodyMetric {
  final String id;
  final DateTime date;
  final double weightKg;
  /// Optional body fat percentage — nullable if omitted by user.
  final double? bodyFatPercent;
  /// Optional note tag — nullable if omitted by user.
  final String? note;

  const BodyMetric({
    required this.id,
    required this.date,
    required this.weightKg,
    this.bodyFatPercent,
    this.note,
  });
}
