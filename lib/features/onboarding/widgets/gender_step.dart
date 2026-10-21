import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/user_profile_provider.dart';

/// Interactive Gender Selector with smooth swipe gestures & animated figure backdrops.
class GenderStep extends ConsumerStatefulWidget {
  const GenderStep({super.key});

  @override
  ConsumerState<GenderStep> createState() => _GenderStepState();
}

class _GenderStepState extends ConsumerState<GenderStep> {
  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final notifier = ref.read(userProfileProvider.notifier);
    final isMale = profile.gender != 'female';

    final screenWidth = MediaQuery.sizeOf(context).width;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -100) {
            notifier.setGender('female');
          } else if (details.primaryVelocity! > 100) {
            notifier.setGender('male');
          }
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            "What's your gender?",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: context.primaryText,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Let us know you better',
            style: TextStyle(
              fontSize: 14,
              color: context.secondaryText,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Interactive Swipeable Figure Area
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ─── Male Figure Widget ───
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  left: isMale ? screenWidth * 0.18 : screenWidth * 0.02,
                  top: isMale ? 30 : 60,
                  bottom: isMale ? 60 : 80,
                  child: GestureDetector(
                    onTap: () => notifier.setGender('male'),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: isMale ? 1.0 : 0.35,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 350),
                        scale: isMale ? 1.05 : 0.85,
                        child: SizedBox(
                          width: screenWidth * 0.55,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: isMale ? 1.0 : 0.0,
                                child: Container(
                                  width: 170,
                                  height: 260,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0052FF),
                                    borderRadius: BorderRadius.circular(44),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0052FF).withAlpha(80),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/images/male.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const HugeIcon(
                                    icon: HugeIcons.strokeRoundedMale02,
                                    size: 160,
                                    color: Color(0xFF0052FF),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ─── Female Figure Widget ───
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  right: !isMale ? screenWidth * 0.18 : screenWidth * 0.02,
                  top: !isMale ? 30 : 60,
                  bottom: !isMale ? 60 : 80,
                  child: GestureDetector(
                    onTap: () => notifier.setGender('female'),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: !isMale ? 1.0 : 0.35,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 350),
                        scale: !isMale ? 1.05 : 0.85,
                        child: SizedBox(
                          width: screenWidth * 0.55,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: !isMale ? 1.0 : 0.0,
                                child: Container(
                                  width: 170,
                                  height: 260,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF2D55),
                                    borderRadius: BorderRadius.circular(44),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF2D55).withAlpha(80),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/images/female.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const HugeIcon(
                                    icon: HugeIcons.strokeRoundedFemale02,
                                    size: 160,
                                    color: Color(0xFFFF2D55),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              isMale ? 'Male' : 'Female',
              key: ValueKey(isMale ? 'Male' : 'Female'),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: context.primaryText,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
