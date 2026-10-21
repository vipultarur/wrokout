import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/user_profile_provider.dart';
import 'package:workout/data/providers/workout_history_provider.dart';

/// Workout History Screen matching application theme and reference layout.
class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  late DateTime _selectedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }

  /// Calculates the starting date of the week containing [date] based on [firstDayOfWeek].
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

  /// Returns weekday headers based on [firstDayOfWeek].
  List<String> _getDayHeaders(String firstDayOfWeek) {
    final fdw = firstDayOfWeek.trim().toLowerCase();
    if (fdw == 'sunday') {
      return ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    } else if (fdw == 'saturday') {
      return ['S', 'S', 'M', 'T', 'W', 'T', 'F'];
    } else {
      return ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    }
  }

  /// Format date range string e.g. "Oct 4 - Oct 10".
  String _formatWeekRange(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final startMonthStr = monthNames[weekStart.month - 1];
    final endMonthStr = monthNames[weekEnd.month - 1];

    if (weekStart.month == weekEnd.month) {
      return '$startMonthStr ${weekStart.day} - ${weekEnd.day}';
    } else {
      return '$startMonthStr ${weekStart.day} - $endMonthStr ${weekEnd.day}';
    }
  }

  /// Format duration in seconds to MM:SS or HH:MM.
  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    final hrs = mins ~/ 60;
    if (hrs > 0) {
      final remMins = mins % 60;
      return '${hrs.toString().padLeft(2, '0')}:${remMins.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Format timestamp to e.g. "Oct 5, 9:05 AM"
  String _formatTimestamp(DateTime dt) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final monthStr = monthNames[dt.month - 1];
    final hourInt = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minStr = dt.minute.toString().padLeft(2, '0');
    return '$monthStr ${dt.day}, $hourInt:$minStr $period';
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(workoutHistoryProvider);
    final userProfile = ref.watch(userProfileProvider);
    final scaffoldBg = context.scaffoldBg;
    final cardBg = context.cardBg;
    final border = context.cardBorder;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Week start & end for selected week summary
    final weekStart = _getStartOfWeek(_selectedDate, userProfile.firstDayOfWeek);
    final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59));

    // Sessions for the current week
    final weekSessions = historyState.sessions.where((s) {
      return s.date.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
          s.date.isBefore(weekEnd);
    }).toList();

    final weekTotalSeconds = weekSessions.fold(0, (sum, s) => sum + s.durationSeconds);
    final weekTotalCalories = weekSessions.fold(0, (sum, s) => sum + s.caloriesBurned);

    // Sessions for selected date (if any) or month
    final selectedDateSessions = historyState.sessions.where((s) {
      return s.date.year == _selectedDate.year &&
          s.date.month == _selectedDate.month &&
          s.date.day == _selectedDate.day;
    }).toList();

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          'History',
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // Month Selector Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: primaryColor),
                onPressed: _previousMonth,
              ),
              const SizedBox(width: 8),
              Text(
                '${_selectedMonth.year}/${_selectedMonth.month.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: context.primaryText,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: primaryColor),
                onPressed: _nextMonth,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Calendar Grid Widget
          _buildCalendarGrid(
            sessions: historyState.sessions,
            firstDayOfWeek: userProfile.firstDayOfWeek,
            cardBg: cardBg,
            border: border,
            primaryColor: primaryColor,
          ),

          const SizedBox(height: 28),

          // Weekly Summary Section Header
          Text(
            'Weekly Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: context.primaryText,
            ),
          ),

          const SizedBox(height: 14),

          // Weekly Summary Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatWeekRange(weekStart),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${weekSessions.length} Workout${weekSessions.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.secondaryText,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    HugeIcon(icon: HugeIcons.strokeRoundedTimer01, size: 16, color: primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(weekTotalSeconds),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.primaryText,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const HugeIcon(icon: HugeIcons.strokeRoundedFire, size: 16, color: Colors.deepOrange),
                    const SizedBox(width: 4),
                    Text(
                      '${weekTotalCalories.toStringAsFixed(1)} Kcal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.primaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Logged Workouts Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Workouts on ${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.primaryText,
                ),
              ),
              if (selectedDateSessions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedDateSessions.length} completed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Workout Log List for Selected Date ONLY
          if (selectedDateSessions.isNotEmpty) ...[
            ...selectedDateSessions.map((sess) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildSessionTile(
                  context,
                  session: sess,
                  cardBg: cardBg,
                  border: border,
                  primaryColor: primaryColor,
                ),
              );
            }),
          ] else ...[
            // Clean state for selected date with no workouts recorded
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
              ),
              child: Column(
                children: [
                  HugeIcon(icon: HugeIcons.strokeRoundedCalendar01, size: 36, color: context.secondaryText),
                  const SizedBox(height: 10),
                  Text(
                    'No Workouts Logged on ${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: context.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Start a workout from Home to record your exercises for this day.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: context.secondaryText),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 110),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid({
    required List<WorkoutSessionLog> sessions,
    required String firstDayOfWeek,
    required Color cardBg,
    required Color border,
    required Color primaryColor,
  }) {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);

    // Compute first day offset respecting user's firstDayOfWeek preference
    final firstOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    int targetStartWeekday = DateTime.monday;
    final fdw = firstDayOfWeek.trim().toLowerCase();
    if (fdw == 'sunday') {
      targetStartWeekday = DateTime.sunday;
    } else if (fdw == 'saturday') {
      targetStartWeekday = DateTime.saturday;
    }

    int firstDayOffset = firstOfMonth.weekday - targetStartWeekday;
    if (firstDayOffset < 0) firstDayOffset += 7;

    // Collect dates that have completed workouts
    final completedDays = <int>{};
    for (var s in sessions) {
      if (s.date.year == _selectedMonth.year && s.date.month == _selectedMonth.month) {
        completedDays.add(s.date.day);
      }
    }

    final dayHeaders = _getDayHeaders(firstDayOfWeek);

    return Column(
      children: [
        // Day of week headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayHeaders.map((h) {
            return SizedBox(
              width: 36,
              child: Text(
                h,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.secondaryText,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 10),

        // Grid of dates
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: daysInMonth + firstDayOffset,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            if (index < firstDayOffset) {
              return const SizedBox.shrink();
            }

            final dayNumber = index - firstDayOffset + 1;
            final isCompleted = completedDays.contains(dayNumber);
            final isToday = now.year == _selectedMonth.year &&
                now.month == _selectedMonth.month &&
                now.day == dayNumber;
            final isSelectedDate = _selectedDate.year == _selectedMonth.year &&
                _selectedDate.month == _selectedMonth.month &&
                _selectedDate.day == dayNumber;

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedDate = DateTime(_selectedMonth.year, _selectedMonth.month, dayNumber);
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? primaryColor
                      : isSelectedDate
                          ? primaryColor.withAlpha(50)
                          : isToday
                              ? (context.isDarkMode ? AppColors.raisinBlack : AppColors.cottonSeedLight)
                              : Colors.transparent,
                  border: Border.all(
                    color: isSelectedDate
                        ? primaryColor
                        : isCompleted
                            ? primaryColor
                            : isToday
                                ? primaryColor.withAlpha(120)
                                : Colors.transparent,
                    width: isSelectedDate ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontWeight: isCompleted || isSelectedDate || isToday ? FontWeight.w900 : FontWeight.normal,
                      fontSize: 14,
                      color: isCompleted
                          ? AppColors.black
                          : isSelectedDate
                              ? primaryColor
                              : context.primaryText,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSessionTile(
    BuildContext context, {
    required WorkoutSessionLog session,
    required Color cardBg,
    required Color border,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedDumbbell01,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTimestamp(session.date),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      session.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lime400.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lime400.withAlpha(100)),
                ),
                child: Text(
                  '${session.caloriesBurned} kcal',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lime400,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Session Meta Row (Duration & Exercise Count)
          Row(
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedTimer01, size: 14, color: primaryColor),
              const SizedBox(width: 4),
              Text(
                _formatDuration(session.durationSeconds),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.primaryText,
                ),
              ),
              const SizedBox(width: 14),
              HugeIcon(icon: HugeIcons.strokeRoundedMenu01, size: 14, color: context.secondaryText),
              const SizedBox(width: 4),
              Text(
                '${session.exerciseCount} Exercises',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.primaryText,
                ),
              ),
              const Spacer(),
              Text(
                'Rating: ${session.rating}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.secondaryText,
                ),
              ),
            ],
          ),

          // Exercises List with Images
          if (session.exercises.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(height: 1, color: border),
            const SizedBox(height: 12),
            ...session.exercises.map((ex) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 42,
                        height: 42,
                        color: context.secondaryText.withAlpha(20),
                        child: Image.asset(
                          ex.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const HugeIcon(
                            icon: HugeIcons.strokeRoundedDumbbell01,
                            size: 20,
                            color: AppColors.lime400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ex.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: context.primaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (ex.bodyPart.isNotEmpty)
                            Text(
                              ex.bodyPart.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: context.secondaryText,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${ex.durationSeconds}s',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.secondaryText,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
