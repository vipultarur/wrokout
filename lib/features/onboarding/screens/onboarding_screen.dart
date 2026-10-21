import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/common/widgets/app_button.dart';
import 'package:workout/common/widgets/app_progress_bar.dart';
import 'package:workout/core/constants/app_decorations.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/constants/app_spacing.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/user_profile_provider.dart';
import 'package:workout/features/onboarding/widgets/activity_level_step.dart';
import 'package:workout/features/onboarding/widgets/body_metrics_step.dart';
import 'package:workout/features/onboarding/widgets/fitness_level_step.dart';
import 'package:workout/features/onboarding/widgets/focus_area_step.dart';
import 'package:workout/features/onboarding/widgets/gender_step.dart';
import 'package:workout/features/onboarding/widgets/motivation_step.dart';
import 'package:workout/features/onboarding/widgets/plan_generating_step.dart';
import 'package:workout/features/onboarding/widgets/weekly_goal_step.dart';

/// Full onboarding flow with 8 steps matching reference design with double theme support.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);
  static const int _totalPages = 8;

  Widget _buildStep(int index) {
    switch (index) {
      case 0:
        return const GenderStep();
      case 1:
        return const MotivationStep();
      case 2:
        return const ActivityLevelStep();
      case 3:
        return const FitnessLevelStep();
      case 4:
        return const WeeklyGoalStep();
      case 5:
        return const FocusAreaStep();
      case 6:
        return const BodyMetricsStep();
      case 7:
        return const PlanGeneratingStep();
      default:
        return const SizedBox.shrink();
    }
  }

  void _nextPage() {
    if (_currentPageNotifier.value < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPageNotifier.value > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skip() {
    ref.read(userProfileProvider.notifier).completeOnboarding();
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _currentPageNotifier,
              builder: (context, currentPage, _) {
                if (currentPage >= _totalPages - 1) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      if (currentPage > 0)
                        GestureDetector(
                          onTap: _previousPage,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: context.cardBg,
                              borderRadius: AppDecorations.borderRadiusMd,
                              border: Border.all(color: context.cardBorder),
                            ),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowLeft01,
                              size: 18,
                              color: context.primaryText,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 40),
                      AppSpacing.w16,
                      Expanded(
                        child: AppProgressBar(
                          value: (currentPage + 1) / _totalPages,
                          minHeight: 4,
                        ),
                      ),
                      AppSpacing.w16,
                      GestureDetector(
                        onTap: _skip,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: context.secondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  _currentPageNotifier.value = index;
                },
                itemCount: _totalPages,
                itemBuilder: (context, index) => _buildStep(index),
              ),
            ),

            ValueListenableBuilder<int>(
              valueListenable: _currentPageNotifier,
              builder: (context, currentPage, _) {
                if (currentPage >= _totalPages - 1) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: AppButton(
                    label: 'NEXT',
                    onPressed: _nextPage,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
