import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Progress state model for a workout challenge.
class ChallengeProgressState {
  final String challengeTitle;
  final int totalDays;
  final int completedDaysCount;
  final Set<int> completedDayIndexes;
  final int currentActiveDay;

  const ChallengeProgressState({
    required this.challengeTitle,
    this.totalDays = 28,
    this.completedDaysCount = 1,
    this.completedDayIndexes = const {1},
    this.currentActiveDay = 2,
  });

  double get completionPercentage => (completedDaysCount / totalDays).clamp(0.0, 1.0);
  int get daysLeft => totalDays - completedDaysCount;

  ChallengeProgressState copyWith({
    String? challengeTitle,
    int? totalDays,
    int? completedDaysCount,
    Set<int>? completedDayIndexes,
    int? currentActiveDay,
  }) {
    return ChallengeProgressState(
      challengeTitle: challengeTitle ?? this.challengeTitle,
      totalDays: totalDays ?? this.totalDays,
      completedDaysCount: completedDaysCount ?? this.completedDaysCount,
      completedDayIndexes: completedDayIndexes ?? this.completedDayIndexes,
      currentActiveDay: currentActiveDay ?? this.currentActiveDay,
    );
  }
}

/// StateNotifier to manage challenge progress state.
class ChallengeProgressNotifier extends StateNotifier<Map<String, ChallengeProgressState>> {
  ChallengeProgressNotifier() : super({});

  ChallengeProgressState getProgress(String challengeTitle, {int defaultTotalDays = 28}) {
    return state[challengeTitle] ??
        ChallengeProgressState(
          challengeTitle: challengeTitle,
          totalDays: defaultTotalDays,
          completedDaysCount: 1,
          completedDayIndexes: const {1},
          currentActiveDay: 2,
        );
  }

  void markDayCompleted(String challengeTitle, int dayNumber) {
    final current = getProgress(challengeTitle);
    final updatedCompleted = {...current.completedDayIndexes, dayNumber};
    final nextActive = (dayNumber + 1 <= current.totalDays) ? dayNumber + 1 : dayNumber;

    final updated = current.copyWith(
      completedDaysCount: updatedCompleted.length,
      completedDayIndexes: updatedCompleted,
      currentActiveDay: nextActive,
    );

    state = {...state, challengeTitle: updated};
  }

  void selectActiveDay(String challengeTitle, int dayNumber) {
    final current = getProgress(challengeTitle);
    final updated = current.copyWith(currentActiveDay: dayNumber);
    state = {...state, challengeTitle: updated};
  }
}

/// Provider for challenge progress tracking.
final challengeProgressNotifierProvider = StateNotifierProvider<ChallengeProgressNotifier, Map<String, ChallengeProgressState>>((ref) {
  return ChallengeProgressNotifier();
});
