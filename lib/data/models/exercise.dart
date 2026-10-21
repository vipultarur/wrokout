/// Exercise model matching the exercises.json schema from the dataset.
class Exercise {
  /// Unique identifier of the exercise.
  final String id;

  /// Display name of the exercise.
  final String name;

  /// Category classification.
  final String category;

  /// Primary target body part.
  final String bodyPart;

  /// Equipment required for execution.
  final String equipment;

  /// Instructions localized map.
  final Map<String, String> instructions;

  /// Step-by-step instructions map.
  final Map<String, List<String>> instructionSteps;

  /// Primary muscle group targeted.
  final String muscleGroup;

  /// List of secondary muscles involved.
  final List<String> secondaryMuscles;

  /// Main muscle target string.
  final String target;

  /// Media asset ID for reference.
  final String mediaId;

  /// Image filename string.
  final String image;

  /// GIF animation filename string.
  final String gifUrl;

  /// Exercise type: 'time-based' or 'rep-based'.
  final String exerciseType;

  /// Difficulty level: 'beginner', 'intermediate', 'advanced'.
  final String difficulty;

  /// Recommended duration in seconds (for time-based exercises, max 40s).
  final int durationSeconds;

  /// Recommended repetition count (for rep-based exercises, 10–20 reps).
  final int reps;

  /// Recommended set count (default 3).
  final int sets;

  /// Movement intensity: 'low', 'medium', 'high'.
  final String intensity;

  /// Attribution source string — nullable as dataset entries may omit credit.
  final String? attribution;

  /// ISO timestamp when entry was added — nullable for legacy dataset items.
  final String? createdAt;

  const Exercise({
    required this.id,
    required this.name,
    this.category = '',
    this.bodyPart = '',
    this.equipment = '',
    this.instructions = const {},
    this.instructionSteps = const {},
    this.muscleGroup = '',
    this.secondaryMuscles = const [],
    this.target = '',
    this.mediaId = '',
    this.image = '',
    this.gifUrl = '',
    this.exerciseType = 'rep-based',
    this.difficulty = 'beginner',
    this.durationSeconds = 0,
    this.reps = 12,
    this.sets = 3,
    this.intensity = 'medium',
    this.attribution,
    this.createdAt,
  });

  bool get isTimeBased => exerciseType == 'time-based';
  bool get isRepBased => !isTimeBased;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    // PRESERVED: exact JSON key strings from dataset
    final instructionsMap = <String, String>{};
    if (json['instructions'] is Map) {
      (json['instructions'] as Map).forEach((key, value) {
        instructionsMap[key.toString()] = value.toString();
      });
    }

    final instructionStepsMap = <String, List<String>>{};
    if (json['instruction_steps'] is Map) {
      (json['instruction_steps'] as Map).forEach((key, value) {
        if (value is List) {
          instructionStepsMap[key.toString()] =
              value.map((e) => e.toString()).toList();
        }
      });
    }

    final secondaryMusclesList = <String>[];
    if (json['secondary_muscles'] is List) {
      for (final m in json['secondary_muscles'] as List) {
        secondaryMusclesList.add(m.toString());
      }
    }

    return Exercise(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      bodyPart: json['body_part']?.toString() ?? '',
      equipment: json['equipment']?.toString() ?? '',
      instructions: instructionsMap,
      instructionSteps: instructionStepsMap,
      muscleGroup: json['muscle_group']?.toString() ?? '',
      secondaryMuscles: secondaryMusclesList,
      target: json['target']?.toString() ?? '',
      mediaId: json['media_id']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      gifUrl: json['gif_url']?.toString() ?? '',
      exerciseType: json['exercise_type']?.toString() ?? 'rep-based',
      difficulty: json['difficulty']?.toString() ?? 'beginner',
      durationSeconds: (json['duration_seconds'] as int?) ?? 0,
      reps: (json['reps'] as int?) ?? 12,
      sets: (json['sets'] as int?) ?? 3,
      intensity: json['intensity']?.toString() ?? 'medium',
      attribution: json['attribution']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'body_part': bodyPart,
      'equipment': equipment,
      'instructions': instructions,
      'instruction_steps': instructionSteps,
      'muscle_group': muscleGroup,
      'secondary_muscles': secondaryMuscles,
      'target': target,
      'media_id': mediaId,
      'image': image,
      'gif_url': gifUrl,
      'exercise_type': exerciseType,
      'difficulty': difficulty,
      'duration_seconds': durationSeconds,
      'reps': reps,
      'sets': sets,
      'intensity': intensity,
      'attribution': attribution,
      'created_at': createdAt,
    };
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? category,
    String? bodyPart,
    String? equipment,
    Map<String, String>? instructions,
    Map<String, List<String>>? instructionSteps,
    String? muscleGroup,
    List<String>? secondaryMuscles,
    String? target,
    String? mediaId,
    String? image,
    String? gifUrl,
    String? exerciseType,
    String? difficulty,
    int? durationSeconds,
    int? reps,
    int? sets,
    String? intensity,
    String? attribution,
    String? createdAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      bodyPart: bodyPart ?? this.bodyPart,
      equipment: equipment ?? this.equipment,
      instructions: instructions ?? this.instructions,
      instructionSteps: instructionSteps ?? this.instructionSteps,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      target: target ?? this.target,
      mediaId: mediaId ?? this.mediaId,
      image: image ?? this.image,
      gifUrl: gifUrl ?? this.gifUrl,
      exerciseType: exerciseType ?? this.exerciseType,
      difficulty: difficulty ?? this.difficulty,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      reps: reps ?? this.reps,
      sets: sets ?? this.sets,
      intensity: intensity ?? this.intensity,
      attribution: attribution ?? this.attribution,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get the Flutter asset path for the thumbnail image.
  String get assetImagePath =>
      image.startsWith('assets/') ? image : 'assets/exercises/$image';

  /// Get the Flutter asset path for the GIF animation.
  String get assetGifPath =>
      gifUrl.startsWith('assets/') ? gifUrl : 'assets/exercises/$gifUrl';

  /// Get instruction text in a given language (defaults to English).
  String getInstruction([String lang = 'en']) {
    return instructions[lang] ?? instructions['en'] ?? '';
  }

  /// Get step-by-step instructions in a given language (defaults to English).
  List<String> getSteps([String lang = 'en']) {
    return instructionSteps[lang] ?? instructionSteps['en'] ?? [];
  }

  /// Display-friendly body part name.
  String get displayBodyPart {
    switch (bodyPart) {
      case 'upper arms':
        return 'Arms';
      case 'upper legs':
        return 'Legs';
      case 'lower arms':
        return 'Forearms';
      case 'lower legs':
        return 'Calves';
      case 'waist':
        return 'Abs';
      default:
        if (bodyPart.isEmpty) return 'General';
        return bodyPart[0].toUpperCase() + bodyPart.substring(1);
    }
  }

  /// Display-friendly equipment name.
  String get displayEquipment {
    return equipment.split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exercise &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'Exercise(id: $id, name: $name, target: $target)';
}
