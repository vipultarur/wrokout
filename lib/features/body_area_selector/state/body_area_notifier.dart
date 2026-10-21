import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout/features/body_area_selector/data/body_area.dart';

/// Notifier managing the selected body areas with state synchronization rules.
class BodyAreaNotifier extends StateNotifier<Set<BodyArea>> {
  BodyAreaNotifier([Set<BodyArea>? initial])
      : super(initial ?? {BodyArea.abs});

  /// Toggle an area (either an individual body area or Full Body).
  // PRESERVED: exact selection state machine rules
  void toggleArea(BodyArea area) {
    final nextState = Set<BodyArea>.from(state);

    if (area == BodyArea.fullBody) {
      if (nextState.contains(BodyArea.fullBody)) {
        nextState.clear();
      } else {
        nextState.addAll(BodyArea.values);
      }
    } else {
      if (nextState.contains(area)) {
        nextState.remove(area);
        nextState.remove(BodyArea.fullBody);
      } else {
        nextState.add(area);
        final allIndividualSelected = BodyArea.individualAreas
            .every((indArea) => nextState.contains(indArea));
        if (allIndividualSelected) {
          nextState.add(BodyArea.fullBody);
        }
      }
    }

    state = nextState;
  }

  /// Toggle selection by tapping a muscle shape ID.
  void toggleMuscle(String muscleId) {
    final area = BodyArea.fromMuscleId(muscleId);
    if (area != null) {
      toggleArea(area);
    }
  }

  /// Check whether a specific muscle shape ID should be highlighted.
  bool isMuscleSelected(String muscleId) {
    if (muscleId.startsWith('static_')) return false;
    final area = BodyArea.fromMuscleId(muscleId);
    return area != null && state.contains(area);
  }
}

/// Riverpod provider for body area selection state.
final bodyAreaSelectionProvider =
    StateNotifierProvider<BodyAreaNotifier, Set<BodyArea>>((ref) {
  return BodyAreaNotifier();
});
