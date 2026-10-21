/// User profile model — stores all onboarding data and preferences.
class UserProfile {
  /// User biological gender — nullable before onboarding completion.
  final String? gender;

  /// Primary fitness goal — nullable before onboarding step selection.
  final String? goal;

  /// List of main motivation tags.
  final List<String> motivations;

  /// Daily activity level tag — nullable before onboarding step selection.
  final String? activityLevel;

  /// Self-reported fitness level — nullable before onboarding step selection.
  final String? fitnessLevel;

  /// Target body focus area labels.
  final List<String> focusAreas;

  /// Preferred available equipment — nullable before user config.
  final String? equipment;

  /// Target workout days per week.
  final int weeklyGoalDays;

  /// Preferred starting day of week.
  final String firstDayOfWeek;

  /// Body weight in kilograms — nullable before metric logging.
  final double? weightKg;

  /// Body height in centimeters — nullable before metric logging.
  final double? heightCm;

  /// User age in years — nullable before metric logging.
  final int? age;

  /// Unit system toggle (true = Metric kg/cm, false = Imperial lbs/ft).
  final bool usesMetric;

  /// Onboarding flow completion flag.
  final bool onboardingComplete;

  /// Audio cues toggle setting.
  final bool soundEnabled;

  /// Haptic feedback toggle setting.
  final bool vibrationEnabled;

  const UserProfile({
    this.gender,
    this.goal,
    this.motivations = const [],
    this.activityLevel,
    this.fitnessLevel,
    this.focusAreas = const [],
    this.equipment,
    this.weeklyGoalDays = 4,
    this.firstDayOfWeek = 'Sunday',
    this.weightKg,
    this.heightCm,
    this.age,
    this.usesMetric = true,
    this.onboardingComplete = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  double? get bmi {
    if (weightKg == null || heightCm == null || heightCm! == 0) return null;
    final h = heightCm! / 100.0;
    return weightKg! / (h * h);
  }

  String? get bmiCategory {
    final b = bmi;
    if (b == null) return null;
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Normal weight';
    if (b < 30.0) return 'Overweight';
    return 'Obese';
  }

  UserProfile copyWith({
    String? gender,
    String? goal,
    List<String>? motivations,
    String? activityLevel,
    String? fitnessLevel,
    List<String>? focusAreas,
    String? equipment,
    int? weeklyGoalDays,
    String? firstDayOfWeek,
    double? weightKg,
    double? heightCm,
    int? age,
    bool? usesMetric,
    bool? onboardingComplete,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return UserProfile(
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      motivations: motivations ?? this.motivations,
      activityLevel: activityLevel ?? this.activityLevel,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      focusAreas: focusAreas ?? this.focusAreas,
      equipment: equipment ?? this.equipment,
      weeklyGoalDays: weeklyGoalDays ?? this.weeklyGoalDays,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      age: age ?? this.age,
      usesMetric: usesMetric ?? this.usesMetric,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  /// Display weight in user's preferred unit.
  String get displayWeight {
    if (weightKg == null) return '--';
    if (usesMetric) return '${weightKg!.toStringAsFixed(1)} kg';
    return '${(weightKg! * 2.20462).toStringAsFixed(1)} lbs';
  }

  /// Display height in user's preferred unit.
  String get displayHeight {
    if (heightCm == null) return '--';
    if (usesMetric) return '${heightCm!.toInt()} cm';
    final totalInches = heightCm! / 2.54;
    final feet = (totalInches / 12).floor();
    final inches = (totalInches % 12).round();
    return "$feet'$inches\"";
  }

  Map<String, dynamic> toJson() {
    // PRESERVED: exact JSON keys
    return {
      'gender': gender,
      'goal': goal,
      'motivations': motivations,
      'activityLevel': activityLevel,
      'fitnessLevel': fitnessLevel,
      'focusAreas': focusAreas,
      'equipment': equipment,
      'weeklyGoalDays': weeklyGoalDays,
      'firstDayOfWeek': firstDayOfWeek,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'age': age,
      'usesMetric': usesMetric,
      'onboardingComplete': onboardingComplete,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      gender: json['gender'] as String?,
      goal: json['goal'] as String?,
      motivations: (json['motivations'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      activityLevel: json['activityLevel'] as String?,
      fitnessLevel: json['fitnessLevel'] as String?,
      focusAreas: (json['focusAreas'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      equipment: json['equipment'] as String?,
      weeklyGoalDays: json['weeklyGoalDays'] as int? ?? 4,
      firstDayOfWeek: json['firstDayOfWeek'] as String? ?? 'Sunday',
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      age: json['age'] as int?,
      usesMetric: json['usesMetric'] as bool? ?? true,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          gender == other.gender &&
          onboardingComplete == other.onboardingComplete &&
          weightKg == other.weightKg &&
          heightCm == other.heightCm &&
          weeklyGoalDays == other.weeklyGoalDays &&
          firstDayOfWeek == other.firstDayOfWeek &&
          soundEnabled == other.soundEnabled &&
          vibrationEnabled == other.vibrationEnabled &&
          usesMetric == other.usesMetric &&
          fitnessLevel == other.fitnessLevel &&
          activityLevel == other.activityLevel &&
          goal == other.goal;

  @override
  int get hashCode =>
      Object.hash(
        gender,
        onboardingComplete,
        weightKg,
        heightCm,
        weeklyGoalDays,
        firstDayOfWeek,
        soundEnabled,
        vibrationEnabled,
        usesMetric,
        fitnessLevel,
        activityLevel,
        goal,
      );

  @override
  String toString() =>
      'UserProfile(gender: $gender, onboardingComplete: $onboardingComplete, weightKg: $weightKg)';
}
