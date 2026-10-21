/// Workout template model — a predefined or custom workout.
class Workout {
  /// Unique identifier.
  final String id;

  /// Routine title.
  final String name;

  /// Optional description — nullable if omit.
  final String? description;

  /// Routine category.
  final String category;

  /// Difficulty level tag.
  final String level;

  /// Estimated duration in minutes.
  final int estimatedMinutes;

  /// Required equipment tag.
  final String equipment;

  /// Ordered exercise list.
  final List<WorkoutExercise> exercises;

  /// Custom routine flag.
  final bool isCustom;

  /// Creation timestamp — nullable for built-in routines.
  final DateTime? createdAt;

  const Workout({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.level,
    required this.estimatedMinutes,
    required this.equipment,
    required this.exercises,
    this.isCustom = false,
    this.createdAt,
  });

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets);
  int get exerciseCount => exercises.length;

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'general',
      level: json['level'] as String? ?? 'beginner',
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 15,
      equipment: json['equipment'] as String? ?? 'none',
      exercises: (json['exercises'] as List?)
              ?.map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isCustom: json['isCustom'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'level': level,
      'estimatedMinutes': estimatedMinutes,
      'equipment': equipment,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'isCustom': isCustom,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Workout copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? level,
    int? estimatedMinutes,
    String? equipment,
    List<WorkoutExercise>? exercises,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      level: level ?? this.level,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      equipment: equipment ?? this.equipment,
      exercises: exercises ?? this.exercises,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Workout &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'Workout(id: $id, name: $name, exercises: ${exercises.length})';
}

/// An exercise within a workout template.
class WorkoutExercise {
  final String exerciseId;
  final String exerciseName;
  /// Optional image filename — nullable if fallback used.
  final String? exerciseImage;
  final int sets;
  final int reps;
  final int durationSeconds;
  final int restSeconds;
  final int orderIndex;

  const WorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseImage,
    required this.sets,
    this.reps = 0,
    this.durationSeconds = 0,
    required this.restSeconds,
    required this.orderIndex,
  });

  bool get isTimeBased => durationSeconds > 0;
  bool get isRepBased => reps > 0;

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      exerciseId: json['exerciseId'] as String? ?? '',
      exerciseName: json['exerciseName'] as String? ?? '',
      exerciseImage: json['exerciseImage'] as String?,
      sets: json['sets'] as int? ?? 1,
      reps: json['reps'] as int? ?? 0,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      restSeconds: json['restSeconds'] as int? ?? 20,
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'exerciseImage': exerciseImage,
      'sets': sets,
      'reps': reps,
      'durationSeconds': durationSeconds,
      'restSeconds': restSeconds,
      'orderIndex': orderIndex,
    };
  }

  WorkoutExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    String? exerciseImage,
    int? sets,
    int? reps,
    int? durationSeconds,
    int? restSeconds,
    int? orderIndex,
  }) {
    return WorkoutExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseImage: exerciseImage ?? this.exerciseImage,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutExercise &&
          runtimeType == other.runtimeType &&
          exerciseId == other.exerciseId &&
          orderIndex == other.orderIndex;

  @override
  int get hashCode => exerciseId.hashCode ^ orderIndex.hashCode;

  @override
  String toString() => 'WorkoutExercise(id: $exerciseId, name: $exerciseName)';
}

/// A multi-day workout challenge/program.
class Challenge {
  final String id;
  final String name;
  /// Optional challenge description — nullable if omitted.
  final String? description;
  final int durationDays;
  final String level;
  final String category;
  final String equipment;
  /// Optional artwork asset path — nullable if gradient backdrop used.
  final String? imageAsset;
  final List<String> gradientColors;
  final Map<int, String?> dayWorkoutIds;

  const Challenge({
    required this.id,
    required this.name,
    this.description,
    required this.durationDays,
    required this.level,
    required this.category,
    required this.equipment,
    this.imageAsset,
    this.gradientColors = const ['#536DFE', '#2979FF'],
    this.dayWorkoutIds = const {},
  });
}
