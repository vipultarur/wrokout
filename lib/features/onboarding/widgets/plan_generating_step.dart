import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/common/widgets/app_button.dart';
import 'package:workout/common/widgets/app_icon.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/user_profile_provider.dart';

/// Step 8: Plan Generation loading & Plan Ready summary screen with double theme support.
class PlanGeneratingStep extends ConsumerStatefulWidget {
  const PlanGeneratingStep({super.key});

  @override
  ConsumerState<PlanGeneratingStep> createState() => _PlanGeneratingStepState();
}

class _PlanGeneratingStepState extends ConsumerState<PlanGeneratingStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final ValueNotifier<int> _progressNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _isReadyNotifier = ValueNotifier<bool>(false);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _startGeneration();
  }

  void _startGeneration() {
    _animController.forward();

    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) return;
      if (_progressNotifier.value < 100) {
        _progressNotifier.value += 1;
      } else {
        _timer?.cancel();
        _isReadyNotifier.value = true;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    _progressNotifier.dispose();
    _isReadyNotifier.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    ref.read(userProfileProvider.notifier).completeOnboarding();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final heightText = profile.displayHeight != '--' ? profile.displayHeight : '168 cm';
    final weightText = profile.displayWeight != '--' ? profile.displayWeight : '65 kg';
    final fitnessLevelText = profile.fitnessLevel != null && profile.fitnessLevel!.isNotEmpty
        ? profile.fitnessLevel![0].toUpperCase() + profile.fitnessLevel!.substring(1)
        : 'Beginner';
    final targetAreaText = profile.focusAreas.isNotEmpty
        ? profile.focusAreas.first.toUpperCase()
        : 'Full Body';

    return ValueListenableBuilder<bool>(
      valueListenable: _isReadyNotifier,
      builder: (context, isReady, _) {
        if (!isReady) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  'GENERATING THE\nPLAN FOR YOU',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: context.primaryText,
                    letterSpacing: 0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Preparing your plan based on your goal...',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.secondaryText,
                  ),
                ),
                const Spacer(),
                RepaintBoundary(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _progressNotifier,
                    builder: (context, progress, _) {
                      return SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: CircularProgressIndicator(
                                value: progress / 100.0,
                                strokeWidth: 14,
                                strokeCap: StrokeCap.round,
                                backgroundColor: context.cardBg,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryColor,
                                ),
                              ),
                            ),
                            Text(
                              '$progress%',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: context.primaryText,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(),
                ValueListenableBuilder<int>(
                  valueListenable: _progressNotifier,
                  builder: (context, progress, _) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.cardBorder),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_rounded,
                                  color: context.isDarkMode ? AppColors.paleLime : AppColors.raisinBlack, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Analyze your body: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.secondaryText,
                                ),
                              ),
                              Text(
                                '$heightText, $weightText',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: context.isDarkMode ? AppColors.paleLime : AppColors.raisinBlack,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              progress > 50
                                  ? Icon(Icons.check_rounded,
                                      color: context.isDarkMode ? AppColors.paleLime : AppColors.raisinBlack, size: 20)
                                  : SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: context.isDarkMode ? AppColors.paleLime : AppColors.raisinBlack,
                                      ),
                                    ),
                              const SizedBox(width: 12),
                              Text(
                                'Adjust your fitness level: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.secondaryText,
                                ),
                              ),
                              Text(
                                fitnessLevelText,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: context.isDarkMode ? AppColors.paleLime : AppColors.raisinBlack,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🏋️‍♂️', style: TextStyle(fontSize: 44)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your plan is ready!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: context.primaryText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'We have selected this plan that suits you best',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.secondaryText,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0052FF), Color(0xFF00A3FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0052FF).withAlpha(100),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'CUSTOMIZED FOR YOU',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'FULL BODY\nSHRED',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(
                          child: _CardFeatureTile(
                            icon: HugeIcons.strokeRoundedCalendar01,
                            value: '7-22 Min',
                            label: 'Daily Time',
                          ),
                        ),
                        Expanded(
                          child: _CardFeatureTile(
                            icon: HugeIcons.strokeRoundedAnalytics01,
                            value: fitnessLevelText,
                            label: 'Level',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _CardFeatureTile(
                            icon: HugeIcons.strokeRoundedTarget01,
                            value: targetAreaText,
                            label: 'Target area',
                          ),
                        ),
                        Expanded(
                          child: _CardFeatureTile(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                            value: profile.equipment ?? 'No Equipment',
                            label: 'Equipment',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'START NOW',
                onPressed: _finishOnboarding,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _finishOnboarding,
                child: Text(
                  'Go to homepage',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.secondaryText,
                    decoration: TextDecoration.underline,
                    decorationColor: context.secondaryText,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _CardFeatureTile extends StatelessWidget {
  final dynamic icon;
  final String value;
  final String label;

  const _CardFeatureTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
          child: AppIcon(icon: icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
