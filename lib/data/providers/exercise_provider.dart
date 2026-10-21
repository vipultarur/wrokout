import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout/core/utils/json_isolate.dart';
import 'package:workout/core/utils/logger.dart';
import 'package:workout/data/models/exercise.dart';

/// Provider that loads all exercises from the bundled JSON asset.
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository();
});

/// Provider for the full list of exercises (loaded once and cached).
final allExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repo = ref.read(exerciseRepositoryProvider);
  return repo.loadAllExercises();
});

/// Provider for unique body parts list.
final bodyPartsProvider = FutureProvider<List<String>>((ref) async {
  final exercises = await ref.watch(allExercisesProvider.future);
  final parts = exercises.map((e) => e.bodyPart).toSet().toList()..sort();
  return parts;
});

/// Provider for unique equipment list.
final equipmentListProvider = FutureProvider<List<String>>((ref) async {
  final exercises = await ref.watch(allExercisesProvider.future);
  final equip = exercises.map((e) => e.equipment).toSet().toList()..sort();
  return equip;
});

/// Mapping from UI Focus Area labels to dataset bodyPart values.
const focusAreaToBodyPartMap = <String, List<String>>{
  'Abs': ['waist'],
  'Chest': ['chest'],
  'Back': ['back'],
  'Arm': ['upper arms', 'lower arms'],
  'Leg': ['upper legs', 'lower legs'],
  'Glutes': ['glutes', 'upper legs'],
  'Shoulder': ['shoulders'],
};

/// Mapping from UI Equipment labels to dataset equipment values.
const equipmentLabelToValueMap = <String, String>{
  'No equipment': 'body weight',
  'Dumbbell': 'dumbbell',
  'Band': 'band',
  'Chair': 'chair',
  'Bench': 'bench',
  'Mat': 'mat',
};

/// Additional Filter State Providers
final selectedFocusAreasProvider = StateProvider<Set<String>>((ref) => {});
final selectedDifficultyProvider = StateProvider<String?>((ref) => null);
final selectedTypeProvider = StateProvider<String?>((ref) => null);
final selectedEquipmentSetProvider = StateProvider<Set<String>>((ref) => {});

/// Utility function to test whether an Exercise satisfies active filters.
bool matchesExerciseFilters(
  Exercise exercise, {
  required Set<String> focusAreas,
  required Set<String> equipments,
  required String? difficulty,
  required String? type,
  String bodyPart = 'all',
  String equipment = 'all',
  String query = '',
}) {
  // 1. Single Body Part Filter (from category chips)
  if (bodyPart != 'all' && exercise.bodyPart.toLowerCase() != bodyPart.toLowerCase()) {
    return false;
  }

  // 2. Single Equipment Filter (from equipment chips)
  if (equipment != 'all' && exercise.equipment.toLowerCase() != equipment.toLowerCase()) {
    return false;
  }

  // 3. Focus Area Filter Set (from Filter Sheet)
  if (focusAreas.isNotEmpty) {
    bool matchesFocus = false;
    for (final fa in focusAreas) {
      final targetParts = focusAreaToBodyPartMap[fa] ?? [fa.toLowerCase()];
      if (targetParts.contains(exercise.bodyPart.toLowerCase())) {
        matchesFocus = true;
        break;
      }
    }
    if (!matchesFocus) return false;
  }

  // 4. Equipment Set Filter (from Filter Sheet)
  if (equipments.isNotEmpty) {
    bool matchesEquip = false;
    for (final eqLabel in equipments) {
      final eqVal = equipmentLabelToValueMap[eqLabel] ?? eqLabel.toLowerCase();
      if (exercise.equipment.toLowerCase().contains(eqVal.toLowerCase())) {
        matchesEquip = true;
        break;
      }
    }
    if (!matchesEquip) return false;
  }

  // 5. Search Query
  if (query.isNotEmpty) {
    final lowerQuery = query.toLowerCase();
    final matchName = exercise.name.toLowerCase().contains(lowerQuery);
    final matchTarget = exercise.target.toLowerCase().contains(lowerQuery);
    final matchBodyPart = exercise.bodyPart.toLowerCase().contains(lowerQuery);
    final matchEquipment = exercise.equipment.toLowerCase().contains(lowerQuery);
    if (!matchName && !matchTarget && !matchBodyPart && !matchEquipment) {
      return false;
    }
  }

  return true;
}

/// Search query provider for exercise search.
final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

/// Body part filter provider.
final exerciseBodyPartFilterProvider = StateProvider<String>((ref) => 'all');

/// Equipment filter provider.
final exerciseEquipmentFilterProvider = StateProvider<String>((ref) => 'all');

/// Filtered exercises provider based on search query, body part, equipment, and filter sheet selections.
final filteredExercisesProvider = Provider<List<Exercise>>((ref) {
  final asyncExercises = ref.watch(allExercisesProvider);
  final exercises = asyncExercises.value ?? [];
  final query = ref.watch(exerciseSearchQueryProvider).trim();
  final bodyPart = ref.watch(exerciseBodyPartFilterProvider);
  final equipment = ref.watch(exerciseEquipmentFilterProvider);

  final focusAreas = ref.watch(selectedFocusAreasProvider);
  final equipments = ref.watch(selectedEquipmentSetProvider);
  final difficulty = ref.watch(selectedDifficultyProvider);
  final type = ref.watch(selectedTypeProvider);

  return exercises.where((e) {
    return matchesExerciseFilters(
      e,
      focusAreas: focusAreas,
      equipments: equipments,
      difficulty: difficulty,
      type: type,
      bodyPart: bodyPart,
      equipment: equipment,
      query: query,
    );
  }).toList();
});

/// Repository for loading and querying exercises from bundled JSON.
class ExerciseRepository {
  List<Exercise>? _cachedExercises;

  /// Load all exercises from the bundled JSON asset.
  /// PERF: Offloaded 17.5 MB JSON string decoding to a background Isolate.
  Future<List<Exercise>> loadAllExercises() async {
    if (_cachedExercises != null) return _cachedExercises!;

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/exercises.json');
      
      // PERF: Execute JSON decoding in background isolate to keep UI frame rate smooth (60/120fps)
      final List<dynamic> jsonList = await parseJsonInIsolate(jsonString);

      _cachedExercises = jsonList
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList();

      AppLogger.info('Successfully loaded ${_cachedExercises!.length} exercises from JSON in isolate.');
      return _cachedExercises!;
    } catch (e, st) {
      AppLogger.error('Failed to load exercises dataset', e, st);
      return [];
    }
  }

  /// Get exercises filtered by body part.
  Future<List<Exercise>> getByBodyPart(String bodyPart) async {
    final all = await loadAllExercises();
    return all.where((e) => e.bodyPart == bodyPart).toList();
  }

  /// Get exercises filtered by equipment.
  Future<List<Exercise>> getByEquipment(String equipment) async {
    final all = await loadAllExercises();
    return all.where((e) => e.equipment == equipment).toList();
  }

  /// Get exercises filtered by target muscle.
  Future<List<Exercise>> getByTarget(String target) async {
    final all = await loadAllExercises();
    return all.where((e) => e.target == target).toList();
  }

  /// Search exercises by name.
  Future<List<Exercise>> search(String query) async {
    final all = await loadAllExercises();
    final lower = query.toLowerCase();
    return all
        .where((e) =>
            e.name.toLowerCase().contains(lower) ||
            e.target.toLowerCase().contains(lower) ||
            e.bodyPart.toLowerCase().contains(lower) ||
            e.equipment.toLowerCase().contains(lower))
        .toList();
  }

  /// Get body-weight only exercises (no equipment needed).
  Future<List<Exercise>> getBodyweightExercises() async {
    return getByEquipment('body weight');
  }

  /// Get exercise by ID.
  Future<Exercise?> getById(String id) async {
    final all = await loadAllExercises();
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get exercises by multiple body parts.
  Future<List<Exercise>> getByBodyParts(List<String> bodyParts) async {
    final all = await loadAllExercises();
    return all.where((e) => bodyParts.contains(e.bodyPart)).toList();
  }
}
