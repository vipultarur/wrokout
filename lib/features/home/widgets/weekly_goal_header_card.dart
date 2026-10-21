import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/user_profile_provider.dart';
import 'package:workout/data/providers/workout_history_provider.dart';
import 'package:workout/features/home/widgets/set_weekly_goal_sheet.dart';

class WeeklyGoalHeaderCard extends ConsumerWidget {
  const WeeklyGoalHeaderCard({super.key});

  DateTime _getStartOfWeek(DateTime date, String firstDayOfWeek) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    int targetStartWeekday = DateTime.monday;
    final fdw = firstDayOfWeek.trim().toLowerCase();
    if (fdw == 'sunday') {
      targetStartWeekday = DateTime.sunday;
    } else if (fdw == 'saturday') {
      targetStartWeekday = DateTime.saturday;
    }

    int diff = cleanDate.weekday - targetStartWeekday;
    if (diff < 0) diff += 7;
    return cleanDate.subtract(Duration(days: diff));
  }

  List<String> _getDayNames(String firstDayOfWeek) {
    final fdw = firstDayOfWeek.trim().toLowerCase();
    if (fdw == 'sunday') {
      return const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    } else if (fdw == 'saturday') {
      return const ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    } else {
      return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final history = ref.watch(workoutHistoryProvider);

    final now = DateTime.now();
    final weekStart = _getStartOfWeek(now, profile.firstDayOfWeek);
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    final dayNames = _getDayNames(profile.firstDayOfWeek);
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Collect unique worked-out day dates within the current week
    final workedOutDayKeys = <String>{}; // 'YYYY-MM-DD' unique keys
    final workedOutDays = <int>{}; // indices 0-6 for display
    for (final session in history.sessions) {
      final sessDate = DateTime(session.date.year, session.date.month, session.date.day);
      for (int i = 0; i < 7; i++) {
        final d = days[i];
        if (sessDate.year == d.year && sessDate.month == d.month && sessDate.day == d.day) {
          final key = '${d.year}-${d.month}-${d.day}';
          if (workedOutDayKeys.add(key)) {
            // First time seeing this date — mark the day index
            workedOutDays.add(i);
          }
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(AppRoutes.workoutHistory),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 20,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Weekly Goal',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: context.primaryText,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => SetWeeklyGoalSheet.show(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              '${workedOutDays.length}/${profile.weeklyGoalDays}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: context.isDarkMode ? AppColors.paleLime : AppColors.raisinBlack,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.edit_rounded, size: 14, color: context.secondaryText),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    final day = days[index];
                    final isToday = day.day == now.day && day.month == now.month && day.year == now.year;
                    final hasWorkout = workedOutDays.contains(index);

                    return Column(
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isToday
                                ? (context.isDarkMode ? AppColors.paleLime : AppColors.raisinBlack)
                                : context.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dayNames[index],
                          style: TextStyle(
                            fontSize: 9,
                            color: context.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: hasWorkout
                                ? primaryColor
                                : isToday
                                    ? primaryColor.withAlpha(60)
                                    : (context.isDarkMode ? AppColors.raisinBlack : AppColors.cottonSeedLight),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: hasWorkout || isToday ? primaryColor : context.cardBorder,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              hasWorkout
                                  ? Icons.check_rounded
                                  : Icons.circle_outlined,
                              size: 14,
                              color: hasWorkout
                                  ? AppColors.raisinBlack
                                  : context.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.isDarkMode ? AppColors.raisinBlack : AppColors.cottonSeedLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: primaryColor,
                        child: const Text('🏋️', style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          workedOutDays.length >= profile.weeklyGoalDays
                              ? '🎉 Amazing! You crushed your weekly goal!'
                              : 'Hi, my friend! Let\'s continue crushing your goals!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

