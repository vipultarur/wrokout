import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/data/providers/user_profile_provider.dart';
import 'package:workout/features/body_area_selector/ui/body_area_selector_screen.dart';
import 'package:workout/features/body_area_selector/ui/body_focus_category_screen.dart';
import 'package:workout/features/challenge/screens/challenge_detail_screen.dart';
import 'package:workout/features/challenge/screens/challenge_screen.dart';
import 'package:workout/features/custom_workout/screens/custom_workout_detail_screen.dart';
import 'package:workout/features/custom_workout/screens/custom_workout_edit_screen.dart';
import 'package:workout/features/custom_workout/screens/custom_workout_screen.dart';
import 'package:workout/features/exercises/screens/exercise_detail_screen.dart';
import 'package:workout/features/exercises/screens/exercises_screen.dart';
import 'package:workout/features/home/screens/home_screen.dart';
import 'package:workout/features/home/screens/main_shell.dart';
import 'package:workout/features/onboarding/screens/onboarding_screen.dart';
import 'package:workout/features/profile/screens/profile_screen.dart';
import 'package:workout/features/report/screens/report_screen.dart';
import 'package:workout/features/search/screens/search_screen.dart';
import 'package:workout/features/workout_detail/screens/preset_workouts_screen.dart';
import 'package:workout/features/workout_detail/screens/workout_plan_detail_screen.dart';
import 'package:workout/features/workout_history/screens/workout_history_screen.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/features/workout_session/screens/workout_session_screen.dart';
import 'package:workout/features/workout_session/screens/workout_summary_screen.dart';

/// Navigation keys for the shell routes.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter provider with onboarding redirect logic.
final routerProvider = Provider<GoRouter>((ref) {
  final isOnboardingComplete = ref.watch(isOnboardingCompleteProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: isOnboardingComplete ? AppRoutes.home : AppRoutes.onboarding,
    routes: [
      // ─── Onboarding (full screen, no bottom nav) ───
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ─── Standalone Body Area Selector Screen ───
      GoRoute(
        path: AppRoutes.bodyAreaSelector,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BodyAreaSelectorScreen(),
      ),

      // ─── Main App Shell (with bottom navigation) ───
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.custom,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CustomWorkoutScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.exercises,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ExercisesScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.report,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // ─── Detail screens (full screen, outside shell) ───
      GoRoute(
        path: AppRoutes.workoutSession,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final title = state.extra as String? ?? 'Custom Workout';
          return WorkoutSessionScreen(workoutTitle: title);
        },
      ),
      GoRoute(
        path: AppRoutes.workoutSummary,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          if (state.extra is Map<String, dynamic>) {
            final map = state.extra as Map<String, dynamic>;
            return WorkoutSummaryScreen(
              workoutTitle: map['workoutTitle'] as String? ?? 'Workout',
              durationSeconds: map['durationSeconds'] as int? ?? 0,
              completedCount: map['completedCount'] as int? ?? 0,
              totalCount: map['totalCount'] as int? ?? 0,
              caloriesBurned: map['caloriesBurned'] as int? ?? 0,
              completedExercises: (map['completedExercises'] as List<Exercise>?) ?? const [],
            );
          }
          return const WorkoutSummaryScreen(
            workoutTitle: 'Workout Completed',
            durationSeconds: 0,
            completedCount: 0,
            totalCount: 0,
            caloriesBurned: 0,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.exerciseDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final exerciseId = state.pathParameters['id'] ?? '';
          return ExerciseDetailScreen(exerciseId: exerciseId);
        },
      ),
      GoRoute(
        path: AppRoutes.workoutPlanDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          if (state.extra is Map<String, dynamic>) {
            final map = state.extra as Map<String, dynamic>;
            return WorkoutPlanDetailScreen(
              dayTitle: map['title'] as String? ?? 'DAY 1',
              challengeTitle: map['challengeTitle'] as String? ?? map['title'] as String? ?? '',
              workoutCategory: map['category'] as String? ?? 'Full Body',
              targetArea: map['targetArea'] as String? ?? '',
              level: map['level'] as String? ?? 'Beginner',
              dayNumber: map['dayNumber'] as int? ?? 1,
            );
          }
          final title = state.extra as String? ?? 'DAY 1';
          return WorkoutPlanDetailScreen(dayTitle: title);
        },
      ),
      GoRoute(
        path: AppRoutes.workoutHistory,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WorkoutHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.challenge,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChallengeScreen(),
      ),
      GoRoute(
        path: AppRoutes.challengeDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          if (state.extra is Map<String, dynamic>) {
            final map = state.extra as Map<String, dynamic>;
            return ChallengeDetailScreen(
              title: map['title'] as String? ?? 'LOWER BODY CHALLENGE',
              category: map['category'] as String? ?? 'Legs',
              targetArea: map['targetArea'] as String? ?? 'Legs & Glutes',
              level: map['level'] as String? ?? 'Intermediate',
              totalDays: map['totalDays'] as int? ?? 28,
            );
          }
          final title = state.extra as String? ?? 'LOWER BODY CHALLENGE';
          return ChallengeDetailScreen(title: title);
        },
      ),
      GoRoute(
        path: AppRoutes.bodyFocusCategory,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BodyFocusCategoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.presetWorkouts,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final title = state.extra as String? ?? '7-15 mins';
          return PresetWorkoutsScreen(title: title);
        },
      ),
      GoRoute(
        path: AppRoutes.customWorkoutEdit,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          return CustomWorkoutEditScreen(extra: state.extra);
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.customWorkoutDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final workoutId = state.extra as String? ?? '';
          return CustomWorkoutDetailScreen(workoutId: workoutId);
        },
      ),
    ],

    redirect: (context, state) {
      final onboarding = state.matchedLocation == AppRoutes.onboarding;
      final isSelector = state.matchedLocation == AppRoutes.bodyAreaSelector;
      if (!isOnboardingComplete && !onboarding && !isSelector) {
        return AppRoutes.onboarding;
      }
      if (isOnboardingComplete && onboarding) {
        return AppRoutes.home;
      }
      return null;
    },
  );
});
