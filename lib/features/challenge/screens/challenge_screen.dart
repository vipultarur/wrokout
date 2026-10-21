import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/common/widgets/app_icon.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';

/// Data model representing a workout challenge item.
class ChallengeItem {
  final String title;
  final String badgeText;
  final String subtitle;
  final String duration;
  final String level;
  final String targetArea;
  final String equipment;
  final String category;
  final List<Color> gradientColors;

  const ChallengeItem({
    required this.title,
    required this.badgeText,
    required this.subtitle,
    required this.duration,
    required this.level,
    required this.targetArea,
    required this.equipment,
    required this.category,
    required this.gradientColors,
  });
}

/// Full Challenge Screen matching Image 1 with adaptive double theme.
class ChallengeScreen extends ConsumerStatefulWidget {
  const ChallengeScreen({super.key});

  @override
  ConsumerState<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends ConsumerState<ChallengeScreen> {
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Build Muscle',
    'Lose Weight',
    'Full Body',
    'Abs',
    'Legs',
  ];

  static const List<ChallengeItem> _allChallenges = [
    ChallengeItem(
      title: 'FULL BODY SHRED',
      badgeText: 'CUSTOMIZED FOR YOU',
      subtitle: 'Burn maximum calories and tone your entire body with targeted high-intensity circuits.',
      duration: '9-35 Min',
      level: 'Beginner',
      targetArea: 'Full Body',
      equipment: 'No Equipment',
      category: 'Full Body',
      gradientColors: [Color(0xFF0066FF), Color(0xFF0044BB)],
    ),
    ChallengeItem(
      title: 'HEIGHT INCREASE CHALLENGE',
      badgeText: '28 DAYS',
      subtitle: 'Stretch, strengthen, and reveal a taller, more confident you!',
      duration: '15 Min',
      level: 'All Levels',
      targetArea: 'Spine & Posture',
      equipment: 'Mat',
      category: 'Build Muscle',
      gradientColors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
    ),
    ChallengeItem(
      title: 'KEGEL POWER BOOST',
      badgeText: '16 DAYS',
      subtitle: 'Strengthen your pelvic floor with targeted exercises for better core stability and power!',
      duration: '10 Min',
      level: 'Beginner',
      targetArea: 'Pelvic Floor',
      equipment: 'No Equipment',
      category: 'Build Muscle',
      gradientColors: [Color(0xFF3A86EF), Color(0xFF2B5C9E)],
    ),
    ChallengeItem(
      title: 'LOWER BODY CHALLENGE',
      badgeText: '28 DAYS',
      subtitle: 'In just 4 weeks, power up your legs, boost lower body strength, and enhance overall athletic performance!',
      duration: '20 Min',
      level: 'Intermediate',
      targetArea: 'Legs & Glutes',
      equipment: 'No Equipment',
      category: 'Legs',
      gradientColors: [Color(0xFF0077B6), Color(0xFF023E8A)],
    ),
    ChallengeItem(
      title: 'CALISTHENICS PLAN',
      badgeText: '28 DAYS',
      subtitle: 'Take on bodyweight exercises to maximize your muscle gain, body control, and fat loss!',
      duration: '25 Min',
      level: 'Advanced',
      targetArea: 'Full Body',
      equipment: 'No Equipment',
      category: 'Build Muscle',
      gradientColors: [Color(0xFF7209B7), Color(0xFF560BAD)],
    ),
    ChallengeItem(
      title: 'LOSE WEIGHT FOR MEN',
      badgeText: '30 DAYS',
      subtitle: 'Lose man boobs and love handles in just 30 days with daily fat-burning workouts!',
      duration: '18 Min',
      level: 'Beginner',
      targetArea: 'Full Body',
      equipment: 'No Equipment',
      category: 'Lose Weight',
      gradientColors: [Color(0xFFF77F00), Color(0xFFD62828)],
    ),
    ChallengeItem(
      title: 'SIX PACK CHALLENGE',
      badgeText: '30 DAYS',
      subtitle: 'Crush this challenge and carve out your six-pack abs in no time!',
      duration: '15 Min',
      level: 'Intermediate',
      targetArea: 'Abs / Core',
      equipment: 'Mat',
      category: 'Abs',
      gradientColors: [Color(0xFF3F37C9), Color(0xFF1F1A78)],
    ),
    ChallengeItem(
      title: 'INTENSE BELLY FAT BURN',
      badgeText: '16 DAYS',
      subtitle: 'Feel the burn, lose the fat — killer abs exercises that work your core fast!',
      duration: '12 Min',
      level: 'Intermediate',
      targetArea: 'Abs',
      equipment: 'No Equipment',
      category: 'Lose Weight',
      gradientColors: [Color(0xFF495057), Color(0xFF212529)],
    ),
    ChallengeItem(
      title: 'FULL BODY CHALLENGE',
      badgeText: '28 DAYS',
      subtitle: 'Start your body-toning journey to target all muscle groups and build your dream body in 4 weeks!',
      duration: '22 Min',
      level: 'All Levels',
      targetArea: 'Full Body',
      equipment: 'No Equipment',
      category: 'Full Body',
      gradientColors: [Color(0xFF0077B6), Color(0xFF03045E)],
    ),
    ChallengeItem(
      title: 'MASSIVE BODY CHALLENGE',
      badgeText: '28 DAYS',
      subtitle: 'Sculpt your upper body and shred your abs in 4 weeks — no equipment needed!',
      duration: '30 Min',
      level: 'Advanced',
      targetArea: 'Chest & Arms',
      equipment: 'No Equipment',
      category: 'Build Muscle',
      gradientColors: [Color(0xFF2B2D42), Color(0xFF1D1E2C)],
    ),
    ChallengeItem(
      title: 'GET RIPPED WITH DUMBBELL',
      badgeText: '30 DAYS',
      subtitle: 'Use dumbbells to build bigger muscles and boost full-body strength in 30 days!',
      duration: '25 Min',
      level: 'Intermediate',
      targetArea: 'Full Body',
      equipment: 'Dumbbell',
      category: 'Build Muscle',
      gradientColors: [Color(0xFF0096C7), Color(0xFF0077B6)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = context.scaffoldBg;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final filteredChallenges = _selectedCategory == 'All'
        ? _allChallenges
        : _allChallenges.where((c) => c.category == _selectedCategory).toList(growable: false);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Challenge',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: context.primaryText,
          ),
        ),
        centerTitle: false,
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: context.primaryText),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs Bar
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;

                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                  selectedColor: primaryColor,
                  backgroundColor: context.cardBg,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.black : context.secondaryText,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? primaryColor : context.cardBorder,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Challenges Vertical List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
              itemCount: filteredChallenges.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final challenge = filteredChallenges[index];
                return RepaintBoundary(
                  child: ChallengeCard(
                    item: challenge,
                    primaryColor: primaryColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Extracted Challenge Card Widget for optimized rebuild isolation.
class ChallengeCard extends StatelessWidget {
  final ChallengeItem item;
  final Color primaryColor;

  const ChallengeCard({
    super.key,
    required this.item,
    required this.primaryColor,
  });

  void _openChallengeDetail(BuildContext context) {
    int totalDays = 28;
    final match = RegExp(r'(\d+)\s*DAYS', caseSensitive: false).firstMatch(item.badgeText);
    if (match != null) {
      totalDays = int.tryParse(match.group(1) ?? '28') ?? 28;
    }
    context.push(AppRoutes.challengeDetail, extra: {
      'title': item.title,
      'category': item.category,
      'targetArea': item.targetArea,
      'level': item.level,
      'totalDays': totalDays,
    });
  }

  void _openDayDetail(BuildContext context) {
    context.push(AppRoutes.workoutPlanDetail, extra: {
      'title': 'DAY 1',
      'challengeTitle': item.title,
      'category': item.category,
      'targetArea': item.targetArea,
      'level': item.level,
      'dayNumber': 1,
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openChallengeDetail(context),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Banner Header with Gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: item.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.badgeText,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Info grid pill badges (Duration, Level, Target, Equipment)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChallengeInfoBadge(icon: HugeIcons.strokeRoundedTimer01, label: item.duration),
                      ChallengeInfoBadge(icon: HugeIcons.strokeRoundedAnalytics01, label: item.level),
                      ChallengeInfoBadge(icon: HugeIcons.strokeRoundedDumbbell01, label: item.targetArea),
                      ChallengeInfoBadge(icon: HugeIcons.strokeRoundedCheckmarkCircle01, label: item.equipment),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(220),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Card Footer Button
            Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _openDayDetail(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: AppColors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'START DAY 1',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(width: 6),
                      HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 14, color: AppColors.black),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extracted Challenge Info Badge Widget.
class ChallengeInfoBadge extends StatelessWidget {
  final dynamic icon;
  final String label;

  const ChallengeInfoBadge({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(60),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon: icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

