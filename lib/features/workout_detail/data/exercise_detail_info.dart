import 'package:workout/data/models/exercise.dart';

/// Structured information model for exercise detail screens.
class ExerciseDetailInfo {
  final List<String> focusAreas;
  final List<String> targetMuscleIds;
  final List<CommonMistake> commonMistakes;
  final List<String> breathingTips;
  final String instructions;

  const ExerciseDetailInfo({
    required this.focusAreas,
    required this.targetMuscleIds,
    required this.commonMistakes,
    required this.breathingTips,
    required this.instructions,
  });

  /// Factory helper to build rich exercise detail info for any exercise.
  factory ExerciseDetailInfo.forExercise(Exercise exercise) {
    final nameLower = exercise.name.toLowerCase();
    final targetLower = exercise.target.toLowerCase();
    final bodyPartLower = exercise.bodyPart.toLowerCase();

    // Determine focus areas & muscle IDs
    final focusAreas = <String>[];
    final muscleIds = <String>[];

    if (bodyPartLower.contains('chest') || targetLower.contains('pectorals')) {
      focusAreas.addAll(['Chest', 'Shoulders', 'Triceps']);
      muscleIds.addAll(['chest_left', 'chest_right', 'shoulder_left', 'shoulder_right', 'triceps_left', 'triceps_right']);
    } else if (bodyPartLower.contains('waist') || targetLower.contains('abs')) {
      focusAreas.addAll(['Abs', 'Obliques', 'Core']);
      muscleIds.addAll(['abs_1', 'abs_2', 'abs_3', 'abs_4', 'abs_5', 'abs_6', 'oblique_left', 'oblique_right']);
    } else if (bodyPartLower.contains('arm') || targetLower.contains('biceps') || targetLower.contains('triceps')) {
      focusAreas.addAll(['Biceps', 'Forearms', 'Shoulders']);
      muscleIds.addAll(['biceps_left', 'biceps_right', 'triceps_left', 'triceps_right', 'forearm_front_left', 'forearm_front_right']);
    } else if (bodyPartLower.contains('leg') || targetLower.contains('quads') || targetLower.contains('glutes')) {
      focusAreas.addAll(['Quadriceps', 'Glutes', 'Hamstrings', 'Calves']);
      muscleIds.addAll(['quad_left', 'quad_right', 'glute_left', 'glute_right', 'hamstring_left', 'hamstring_right', 'calf_front_left', 'calf_front_right']);
    } else if (bodyPartLower.contains('back') || targetLower.contains('lats')) {
      focusAreas.addAll(['Lats', 'Upper Back', 'Lower Back', 'Biceps']);
      muscleIds.addAll(['traps_back', 'lats_left', 'lats_right', 'lower_back', 'biceps_left', 'biceps_right']);
    } else if (bodyPartLower.contains('shoulder') || targetLower.contains('delts')) {
      focusAreas.addAll(['Shoulders', 'Traps', 'Triceps']);
      muscleIds.addAll(['shoulder_left', 'shoulder_right', 'rear_delt_left', 'rear_delt_right', 'traps_back']);
    } else {
      // Default Full Body / Cardio
      focusAreas.addAll(['Shoulders', 'Quadriceps', 'Adductors', 'Chest', 'Glutes', 'Calves']);
      muscleIds.addAll([
        'shoulder_left',
        'shoulder_right',
        'chest_left',
        'chest_right',
        'quad_left',
        'quad_right',
        'glute_left',
        'glute_right',
        'calf_front_left',
        'calf_front_right'
      ]);
    }

    // Default Common Mistakes & Breathing Tips
    final mistakes = <CommonMistake>[];
    final breathing = <String>[];

    if (nameLower.contains('push-up') || nameLower.contains('chest')) {
      mistakes.addAll([
        const CommonMistake(
          title: 'Sagging lower back',
          description: 'Dropping your hips strains your lower back and reduces core engagement. Keep your core tight and body in a straight line.',
        ),
        const CommonMistake(
          title: 'Flaring elbows outward',
          description: 'Positioning elbows at 90 degrees puts unnecessary stress on your shoulders. Keep elbows tucked at roughly 45 degrees.',
        ),
        const CommonMistake(
          title: 'Incomplete range of motion',
          description: 'Not lowering all the way down deprives your chest of full muscle activation. Lower until your chest nearly touches the floor.',
        ),
      ]);
      breathing.addAll([
        'Inhale as you lower your body down toward the floor.',
        'Exhale forcefully as you press back up to the starting position.',
        'Maintain a steady, rhythmic breathing pattern throughout.',
      ]);
    } else if (nameLower.contains('squat') || nameLower.contains('lunge') || nameLower.contains('leg')) {
      mistakes.addAll([
        const CommonMistake(
          title: 'Knees caving inward',
          description: 'Allowing your knees to collapse inward increases knee joint stress. Push your knees outward in line with your toes.',
        ),
        const CommonMistake(
          title: 'Lifting heels off the ground',
          description: 'Shifting weight onto your toes strains knees. Keep your weight distributed evenly across your heels and mid-foot.',
        ),
        const CommonMistake(
          title: 'Rounding the lower back',
          description: 'Hunching forward strains spinal disks. Keep your chest up, shoulder blades back, and spine neutral.',
        ),
      ]);
      breathing.addAll([
        'Inhale deeply as you bend your knees and lower into the squat.',
        'Exhale as you push through your heels to stand back up.',
        'Keep your spine braced and core engaged on every rep.',
      ]);
    } else if (nameLower.contains('jack') || nameLower.contains('punch') || nameLower.contains('cardio') || nameLower.contains('jump')) {
      mistakes.addAll([
        const CommonMistake(
          title: 'Landing too hard',
          description: 'Landing heavily puts too much impact on your feet, ankles, and knees. Try to land softly on the balls of your feet.',
        ),
        const CommonMistake(
          title: 'Not keeping knees bent',
          description: 'Failing to keep knees slightly bent can lock out joints and cause discomfort or reduced movement efficiency.',
        ),
        const CommonMistake(
          title: 'Not engaging the core',
          description: 'Requires core muscles to be engaged throughout. A relaxed core leads to poor form and lower energy expenditure.',
        ),
      ]);
      breathing.addAll([
        'Inhale as you jump your feet apart.',
        'Exhale as you jump your feet back together.',
        'Take deep breaths to fully oxygenate your body throughout the set.',
      ]);
    } else {
      mistakes.addAll([
        const CommonMistake(
          title: 'Rushing through repetitions',
          description: 'Using momentum instead of controlled muscle contraction reduces exercise effectiveness and increases risk of strain.',
        ),
        const CommonMistake(
          title: 'Holding your breath',
          description: 'Restricting oxygen flow increases blood pressure and leads to premature fatigue. Breathe continuously throughout.',
        ),
        const CommonMistake(
          title: 'Poor posture alignment',
          description: 'Failing to maintain a neutral spine can overload joints. Keep your core tight and shoulders relaxed.',
        ),
      ]);
      breathing.addAll([
        'Inhale during the relaxed phase of movement.',
        'Exhale during the exertion or contraction phase.',
        'Keep breath steady and synchronized with repetitions.',
      ]);
    }

    final fullInstructions = exercise.getInstruction().isNotEmpty
        ? exercise.getInstruction()
        : 'Start with your body in a stable, comfortable position. Maintain proper form and engage your core throughout the movement. Complete each repetition with control.';

    return ExerciseDetailInfo(
      focusAreas: focusAreas,
      targetMuscleIds: muscleIds,
      commonMistakes: mistakes,
      breathingTips: breathing,
      instructions: fullInstructions,
    );
  }
}

class CommonMistake {
  final String title;
  final String description;

  const CommonMistake({
    required this.title,
    required this.description,
  });
}
