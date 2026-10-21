import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/features/challenge/providers/challenge_provider.dart';

/// Screen 2: Challenge Overview & Weeks Plan Screen matching Image 3.
/// Displays week timelines, completed/active/upcoming day badges,
/// motivational quotes, progress indicator, and a bottom "GO" button.
class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final String title;
  final String category;
  final String targetArea;
  final String level;
  final int totalDays;

  const ChallengeDetailScreen({
    super.key,
    this.title = 'LOWER BODY CHALLENGE',
    this.category = 'Legs',
    this.targetArea = 'Legs & Glutes',
    this.level = 'Intermediate',
    this.totalDays = 28,
  });

  @override
  ConsumerState<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen> {
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    final progress = ref.read(challengeProgressNotifierProvider.notifier).getProgress(
          widget.title,
          defaultTotalDays: widget.totalDays,
        );
    _selectedDay = progress.currentActiveDay;
  }

  String _getMotivationalQuote(String title) {
    final t = title.toLowerCase();
    if (t.contains('lower body') || t.contains('leg')) {
      return 'Leg day is power day. Embrace the burn!';
    } else if (t.contains('six pack') || t.contains('abs') || t.contains('belly')) {
      return 'Core strength builds everything. Feel the squeeze!';
    } else if (t.contains('arm') || t.contains('chest')) {
      return 'Push past your limits. Strong arms win!';
    } else if (t.contains('height') || t.contains('posture')) {
      return 'Stand tall, stretch deep, and feel confident!';
    }
    return 'Consistency is your superpower. Let\'s crush today!';
  }

  void _onDaySelected(int dayNumber) {
    setState(() {
      _selectedDay = dayNumber;
    });
    ref.read(challengeProgressNotifierProvider.notifier).selectActiveDay(widget.title, dayNumber);
  }

  void _onGoPressed() {
    context.push(AppRoutes.workoutPlanDetail, extra: {
      'title': 'DAY $_selectedDay',
      'challengeTitle': widget.title,
      'category': widget.category,
      'targetArea': widget.targetArea,
      'level': widget.level,
      'dayNumber': _selectedDay,
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = context.scaffoldBg;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final allProgress = ref.watch(challengeProgressNotifierProvider);
    final progress = allProgress[widget.title] ??
        ChallengeProgressState(
          challengeTitle: widget.title,
          totalDays: widget.totalDays,
          completedDaysCount: 1,
          completedDayIndexes: const {1},
          currentActiveDay: 2,
        );

    final daysLeft = progress.daysLeft;
    final completionPct = (progress.completionPercentage * 100).round();
    final totalWeeks = (widget.totalDays / 7).ceil().clamp(1, 6);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // Scrollable Body Content
          CustomScrollView(
            slivers: [
              // Sliver App Bar Header Banner
              SliverAppBar(
                expandedHeight: 220.0,
                pinned: true,
                backgroundColor: Colors.black,
                elevation: 0,
                leading: IconButton(
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedMoreVertical, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Dark Athletic Hero Background Gradient
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF020617)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Overlay Dark Tint
                      Container(color: Colors.black.withAlpha(80)),

                      // Title & Progress Header Info
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Days Left & Completion Percentage
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$daysLeft Days left',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  '$completionPct%',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress.completionPercentage,
                                minHeight: 8,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                  child: Column(
                    children: [
                      // Motivational Tip Banner Box with Coach Avatar
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.cardBorder),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: primaryColor.withAlpha(40),
                              child: const HugeIcon(
                                icon: HugeIcons.strokeRoundedUser02,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                _getMotivationalQuote(widget.title),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: context.primaryText,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Weeks Timeline List
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: totalWeeks,
                        itemBuilder: (context, weekIndex) {
                          final weekNumber = weekIndex + 1;
                          final startDayIndex = weekIndex * 7 + 1;
                          final endDayIndex = (startDayIndex + 6).clamp(1, widget.totalDays);

                          // Count completed days in this week
                          int weekCompletedCount = 0;
                          for (int d = startDayIndex; d <= endDayIndex; d++) {
                            if (progress.completedDayIndexes.contains(d)) {
                              weekCompletedCount++;
                            }
                          }

                          final isWeekCompleted = weekCompletedCount == 7;
                          final isCurrentWeek = _selectedDay >= startDayIndex && _selectedDay <= endDayIndex;

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Timeline Node & Vertical Connector Line
                                Column(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: isWeekCompleted || isCurrentWeek
                                            ? primaryColor
                                            : Colors.grey.withAlpha(60),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          isWeekCompleted ? Icons.check : (isCurrentWeek ? Icons.bolt : Icons.bolt_outlined),
                                          size: 16,
                                          color: isWeekCompleted || isCurrentWeek ? AppColors.black : context.secondaryText,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        color: isWeekCompleted
                                            ? primaryColor
                                            : context.cardBorder,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 14),

                                // Right Content: Week Title Header & Days Card
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Week Title Header with completion badge (e.g. Week 1  2/7)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Week $weekNumber',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: context.primaryText,
                                            ),
                                          ),
                                          Text(
                                            '$weekCompletedCount/7',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: context.secondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Days Grid Container Card (Image 3 layout)
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        margin: const EdgeInsets.only(bottom: 24),
                                        decoration: BoxDecoration(
                                          color: context.cardBg,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isCurrentWeek ? primaryColor.withAlpha(120) : context.cardBorder,
                                            width: isCurrentWeek ? 1.5 : 1.0,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            // Row 1: Days 1..4 (or startDayIndex..startDayIndex+3)
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: List.generate(4, (i) {
                                                final dayNum = startDayIndex + i;
                                                if (dayNum > widget.totalDays) return const SizedBox(width: 44);
                                                return _buildDayBadge(
                                                  dayNum: dayNum,
                                                  displayLabel: '${i + 1}',
                                                  isCompleted: progress.completedDayIndexes.contains(dayNum),
                                                  isSelected: _selectedDay == dayNum,
                                                  primaryColor: primaryColor,
                                                );
                                              }),
                                            ),

                                            const SizedBox(height: 12),

                                            // Row 2: Days 5..7 + Trophy Icon!
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                ...List.generate(3, (i) {
                                                  final dayNum = startDayIndex + 4 + i;
                                                  if (dayNum > widget.totalDays) return const SizedBox(width: 44);
                                                  return _buildDayBadge(
                                                    dayNum: dayNum,
                                                    displayLabel: '${i + 5}',
                                                    isCompleted: progress.completedDayIndexes.contains(dayNum),
                                                    isSelected: _selectedDay == dayNum,
                                                    primaryColor: primaryColor,
                                                  );
                                                }),

                                                // Trophy Icon Button (End of Week Reward)
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  decoration: BoxDecoration(
                                                    color: isWeekCompleted ? Colors.amber.withAlpha(40) : context.cardBorder.withAlpha(40),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.emoji_events_rounded,
                                                      color: isWeekCompleted ? Colors.amber : context.secondaryText,
                                                      size: 22,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Pinned Bottom Action Button "GO"
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _onGoPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: AppColors.black,
                  elevation: 8,
                  shadowColor: primaryColor.withAlpha(100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'START DAY $_selectedDay',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      color: AppColors.black,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single day badge button (Completed / Selected / Upcoming)
  Widget _buildDayBadge({
    required int dayNum,
    required String displayLabel,
    required bool isCompleted,
    required bool isSelected,
    required Color primaryColor,
  }) {
    Color bg = context.cardBorder.withAlpha(50);
    Color borderColor = Colors.transparent;
    Color textColor = context.primaryText;
    Widget childWidget = Text(
      displayLabel,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
    );

    if (isCompleted) {
      bg = primaryColor;
      borderColor = primaryColor;
      childWidget = const Icon(Icons.check, size: 18, color: AppColors.black);
    } else if (isSelected) {
      bg = context.scaffoldBg;
      borderColor = primaryColor;
      textColor = primaryColor;
      childWidget = Text(
        displayLabel,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: primaryColor,
        ),
      );
    }

    return GestureDetector(
      onTap: () => _onDaySelected(dayNum),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.5 : 1.0,
          ),
        ),
        child: Center(child: childWidget),
      ),
    );
  }
}
