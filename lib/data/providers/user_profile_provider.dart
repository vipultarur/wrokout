import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout/core/utils/logger.dart';
import 'package:workout/data/models/user_profile.dart';

/// Provider for SharedPreferences instance.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

/// Provider for managing user profile state and persistence.
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return UserProfileNotifier(prefs);
});

/// Whether the user has completed onboarding.
final isOnboardingCompleteProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).onboardingComplete;
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  final SharedPreferences _prefs;
  // PRESERVED: exact SharedPrefs key string
  static const _key = 'user_profile';

  UserProfileNotifier(this._prefs) : super(const UserProfile()) {
    _load();
  }

  void _load() {
    try {
      final jsonStr = _prefs.getString(_key);
      if (jsonStr != null) {
        final map = json.decode(jsonStr) as Map<String, dynamic>;
        state = UserProfile.fromJson(map);
      }
    } catch (e, st) {
      AppLogger.error('Failed to load user profile from storage', e, st);
    }
  }

  Future<void> _save() async {
    try {
      await _prefs.setString(_key, json.encode(state.toJson()));
    } catch (e, st) {
      AppLogger.error('Failed to save user profile to storage', e, st);
    }
  }

  // ─── Onboarding setters ───

  void setGender(String gender) {
    state = state.copyWith(gender: gender);
    _save();
  }

  void setGoal(String goal) {
    state = state.copyWith(goal: goal);
    _save();
  }

  void setMotivations(List<String> motivations) {
    state = state.copyWith(motivations: motivations);
    _save();
  }

  void toggleMotivation(String motivation) {
    final current = List<String>.from(state.motivations);
    if (current.contains(motivation)) {
      current.remove(motivation);
    } else {
      current.add(motivation);
    }
    state = state.copyWith(motivations: current);
    _save();
  }

  void setActivityLevel(String level) {
    state = state.copyWith(activityLevel: level);
    _save();
  }

  void setFitnessLevel(String level) {
    state = state.copyWith(fitnessLevel: level);
    _save();
  }

  void setFocusAreas(List<String> areas) {
    state = state.copyWith(focusAreas: areas);
    _save();
  }

  void toggleFocusArea(String area) {
    final current = List<String>.from(state.focusAreas);
    if (current.contains(area)) {
      current.remove(area);
    } else {
      current.add(area);
    }
    state = state.copyWith(focusAreas: current);
    _save();
  }

  void setEquipment(String equipment) {
    state = state.copyWith(equipment: equipment);
    _save();
  }

  void setWeeklyGoalDays(int days) {
    state = state.copyWith(weeklyGoalDays: days);
    _save();
  }

  void setFirstDayOfWeek(String day) {
    state = state.copyWith(firstDayOfWeek: day);
    _save();
  }

  void setWeight(double weightKg) {
    state = state.copyWith(weightKg: weightKg);
    _save();
  }

  void setHeight(double heightCm) {
    state = state.copyWith(heightCm: heightCm);
    _save();
  }

  void setUsesMetric(bool usesMetric) {
    state = state.copyWith(usesMetric: usesMetric);
    _save();
  }

  void updateActivityLevel(String level) => setActivityLevel(level);

  void updateFitnessLevel(String level) => setFitnessLevel(level);

  void updateMotivations(List<String> motivations) => setMotivations(motivations);

  void updateFocusAreas(List<String> focusAreas) => setFocusAreas(focusAreas);

  void updateWeeklyGoalDays(int days) => setWeeklyGoalDays(days);

  void updateBodyMetrics({double? weightKg, double? heightCm, int? age}) {
    state = state.copyWith(
      weightKg: weightKg ?? state.weightKg,
      heightCm: heightCm ?? state.heightCm,
      age: age ?? state.age,
    );
    _save();
  }

  void updateSettings({bool? soundEnabled, bool? vibrationEnabled}) {
    state = state.copyWith(
      soundEnabled: soundEnabled ?? state.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? state.vibrationEnabled,
    );
    _save();
  }

  void completeOnboarding() {
    state = state.copyWith(onboardingComplete: true);
    _save();
  }

  void resetProfile() {
    state = const UserProfile();
    _prefs.remove(_key);
  }
}
