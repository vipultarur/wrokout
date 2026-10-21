/// Centralized route path string constants across the application.
abstract class AppRoutes {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String exercises = '/exercises';
  static const String exerciseDetail = '/exercise-detail/:id';
  static const String customWorkout = '/custom-workout';
  static const String custom = '/custom-workout';
  static const String customWorkoutEdit = '/custom-workout-edit';
  static const String customWorkoutDetail = '/custom-workout-detail';
  static const String bodyAreaSelector = '/body-area-selector';
  static const String workoutSession = '/workout-session';
  static const String workoutSummary = '/workout-summary';
  static const String workoutPlanDetail = '/workout-plan-detail';
  static const String workoutHistory = '/workout-history';
  static const String report = '/report';
  static const String profile = '/profile';
  static const String challenge = '/challenge';
  static const String challengeDetail = '/challenge-detail';
  static const String bodyFocusCategory = '/body-focus-category';
  static const String search = '/search';
  static const String presetWorkouts = '/preset-workouts';

  static String exerciseDetailPath(String id) => '/exercise-detail/$id';
}


