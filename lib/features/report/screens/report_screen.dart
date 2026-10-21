import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/user_profile_provider.dart';
import 'package:workout/data/providers/workout_history_provider.dart';
import 'package:workout/features/body_area_selector/data/body_area.dart';
import 'package:workout/features/body_area_selector/data/svg_body_parser.dart';

/// Comprehensive Report, Analytics & Progress Screen displaying real application data.
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  String _selectedFrequencyTimeframe = 'This Week';

  BodyFigureModel? _frontModel;
  BodyFigureModel? _backModel;
  bool _isLoadingBodyArtwork = true;

  @override
  void initState() {
    super.initState();
    _loadBodyArtwork();
  }

  Future<void> _loadBodyArtwork() async {
    final gender = ref.read(userProfileProvider).gender ?? 'male';
    final isFemale = gender.toLowerCase() == 'female';
    final frontAsset = isFemale
        ? 'assets/svg/body_front_female.svg'
        : 'assets/svg/body_front.svg';
    final backAsset = isFemale
        ? 'assets/svg/body_back_female.svg'
        : 'assets/svg/body_back.svg';

    try {
      final front = await BodyFigureModel.loadFromAsset(frontAsset);
      final back = await BodyFigureModel.loadFromAsset(backAsset);
      if (mounted) {
        setState(() {
          _frontModel = front;
          _backModel = back;
          _isLoadingBodyArtwork = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingBodyArtwork = false);
      }
    }
  }

  void _showLogWeightDialog(BuildContext context, WidgetRef ref) {
    final weightController = TextEditingController();
    final primaryColor = Theme.of(context).colorScheme.primary;
    final profile = ref.read(userProfileProvider);
    final usesMetric = profile.usesMetric;
    final unitLabel = usesMetric ? 'kg' : 'lbs';
    final hintText = usesMetric ? 'e.g. 72.5' : 'e.g. 159.8';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Today\'s Weight',
          style: TextStyle(color: context.primaryText, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your current weight in $unitLabel:',
              style: TextStyle(fontSize: 13, color: context.secondaryText),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: TextStyle(color: context.primaryText, fontSize: 16),
              decoration: InputDecoration(
                hintText: hintText,
                suffixText: unitLabel,
                suffixStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                hintStyle: TextStyle(color: context.secondaryText),
                filled: true,
                fillColor: context.scaffoldBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: context.cardBorder),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(weightController.text.trim());
              if (val != null && val > 0) {
                // Convert to kg for storage if user entered lbs
                final weightKg = usesMetric ? val : val / 2.20462;
                ref.read(userProfileProvider.notifier).setWeight(weightKg);
                ref.read(workoutHistoryProvider.notifier).addWeightEntry(weightKg);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Weight logged: ${val.toStringAsFixed(1)} $unitLabel'),
                    backgroundColor: context.cardBg,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final history = ref.watch(workoutHistoryProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'REPORT',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: context.primaryText,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedClock01,
              color: primaryColor,
            ),
            tooltip: 'Workout History',
            onPressed: () => context.push(AppRoutes.workoutHistory),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. TOTAL SECTION ───
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricCol(
                        context,
                        label: 'Workouts',
                        value: '${history.totalWorkouts}',
                        valueColor: primaryColor,
                      ),
                      _buildMetricCol(
                        context,
                        label: 'Time(min)',
                        value: '${history.totalMinutes}',
                        valueColor: primaryColor,
                      ),
                      _buildMetricCol(
                        context,
                        label: 'Kcal',
                        value: '${history.totalCalories}',
                        valueColor: primaryColor,
                      ),
                      _buildMetricCol(
                        context,
                        label: 'Total(min)',
                        value: '${history.totalVolumeKg}',
                        valueColor: primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Workout times per week',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ─── Weekly Bar Chart ───
                  SizedBox(
                    height: 140,
                    child: _buildWeeklyBarChart(context, history, primaryColor),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── 2. THIS WEEK SECTION ───
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Week',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Days of the week row
                  _buildThisWeekCalendarRow(context, primaryColor),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricCol(
                        context,
                        label: 'Today(min)',
                        value: '${history.todayMinutes}',
                        valueColor: primaryColor,
                      ),
                      _buildMetricCol(
                        context,
                        label: 'Weekly average(min)',
                        value: history.weeklyAvgMinutes.toStringAsFixed(1),
                        valueColor: primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── 3. TRAINING FREQUENCY SECTION ───
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Training Frequency',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.primaryText,
                        ),
                      ),
                      DropdownButton<String>(
                        value: _selectedFrequencyTimeframe,
                        dropdownColor: context.cardBg,
                        underline: const SizedBox.shrink(),
                        icon: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: context.secondaryText,
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.primaryText,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'This Week',
                            child: Text('This Week'),
                          ),
                          DropdownMenuItem(
                            value: 'This Month',
                            child: Text('This Month'),
                          ),
                          DropdownMenuItem(
                            value: 'All Time',
                            child: Text('All Time'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedFrequencyTimeframe = val);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Body Muscle Front/Back Heatmap
                  SizedBox(
                    height: 220,
                    child: _isLoadingBodyArtwork
                        ? Center(child: CircularProgressIndicator(color: primaryColor))
                        : Row(
                            children: [
                              Expanded(
                                child: _buildBodyHeatmapWidget(
                                  _frontModel,
                                  history.getMuscleFrequencies(_selectedFrequencyTimeframe),
                                  primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildBodyHeatmapWidget(
                                  _backModel,
                                  history.getMuscleFrequencies(_selectedFrequencyTimeframe),
                                  primaryColor,
                                ),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 16),

                  // High / Low Legend Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'High',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.secondaryText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 80,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withAlpha(50),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Low',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── 4. HISTORY SECTION ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: context.primaryText,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.workoutHistory),
                  child: Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (history.sessions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.cardBorder),
                ),
                child: Column(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedClock01,
                      size: 36,
                      color: context.secondaryText,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No Workout History Yet',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: context.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complete your first workout to see your progress logs here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: context.secondaryText),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.sessions.length > 5 ? 5 : history.sessions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final session = history.sessions[index];
                  final mins = (session.durationSeconds / 60).round();
                  final timeStr = DateFormat('hh:mm a').format(session.date);
                  final dateStr = DateFormat('MMM d').format(session.date);
                  final volumeStr = session.exerciseCount > 0
                      ? '${session.exerciseCount * session.durationSeconds * 4}'
                      : '${session.caloriesBurned * 12}';

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: context.primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$timeStr • $dateStr',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${mins.toString().padLeft(2, '0')}:${(session.durationSeconds % 60).toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: context.primaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Duration',
                              style: TextStyle(
                                fontSize: 10,
                                color: context.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              volumeStr,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Volume',
                              style: TextStyle(
                                fontSize: 10,
                                color: context.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 28),

            // ─── 5. MY WEIGHT SECTION ───
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Weight',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.primaryText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current(kg)',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.displayWeight,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: primaryColor.withAlpha(40),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'BMI: ${_calculateBMI(profile.weightKg, profile.heightCm)} (${_getBMICategory(profile.weightKg, profile.heightCm)})',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => _showLogWeightDialog(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'LOG',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Weight Line Chart Visual
                  SizedBox(
                    height: 120,
                    child: _buildWeightLineChart(context, history, profile.weightKg ?? 70.0, primaryColor),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }

  String _calculateBMI(double? weightKg, double? heightCm) {
    final w = weightKg ?? 70.0;
    final h = (heightCm ?? 175.0) / 100.0;
    if (h <= 0) return '22.5';
    final bmi = w / (h * h);
    return bmi.toStringAsFixed(1);
  }

  String _getBMICategory(double? weightKg, double? heightCm) {
    final w = weightKg ?? 70.0;
    final h = (heightCm ?? 175.0) / 100.0;
    if (h <= 0) return 'Normal';
    final bmi = w / (h * h);
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';    // WHO: ≥25 = Overweight
    if (bmi < 30.0) return 'Overweight'; // WHO: ≥30 = Obese
    return 'Obese';
  }

  Widget _buildMetricCol(
    BuildContext context, {
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: context.secondaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyBarChart(
    BuildContext context,
    WorkoutHistoryState history,
    Color primaryColor,
  ) {
    final weeklyCounts = history.getWeeklyWorkoutCounts();
    int maxCount = 1;
    for (var w in weeklyCounts) {
      if ((w['count'] as int) > maxCount) maxCount = w['count'] as int;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: weeklyCounts.map((item) {
        final count = item['count'] as int;
        final label = item['label'] as String;
        final heightFactor = (count / maxCount).clamp(0.1, 1.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (count > 0)
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 14,
              height: 80 * heightFactor,
              decoration: BoxDecoration(
                color: count > 0 ? primaryColor : context.cardBorder,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: context.secondaryText,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildThisWeekCalendarRow(BuildContext context, Color primaryColor) {
    final now = DateTime.now();
    // Calculate start of current week (Sunday)
    final sunday = now.subtract(Duration(days: now.weekday % 7));
    final daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final dayDate = sunday.add(Duration(days: index));
        final isToday = dayDate.year == now.year &&
            dayDate.month == now.month &&
            dayDate.day == now.day;

        return Column(
          children: [
            Text(
              daysOfWeek[index],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: context.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isToday ? primaryColor : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  '${dayDate.day}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isToday ? AppColors.black : context.primaryText,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBodyHeatmapWidget(
    BodyFigureModel? model,
    Map<String, int> frequencies,
    Color primaryColor,
  ) {
    if (model == null) {
      return const SizedBox.shrink();
    }

    return SizedBox.expand(
      child: CustomPaint(
        painter: _BodyHeatmapPainter(
          model: model,
          frequencies: frequencies,
          primaryColor: primaryColor,
          inactiveColor: const Color(0xFF2B2D31),
        ),
      ),
    );
  }

  Widget _buildWeightLineChart(
    BuildContext context,
    WorkoutHistoryState history,
    double currentWeight,
    Color primaryColor,
  ) {
    final now = DateTime.now();
    final dates = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    final weightLogs = history.weightLogs;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Stack(
            children: [
              // Dashed reference line for current weight
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: double.infinity,
                  height: 1,
                  color: context.cardBorder,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: dates.map((dt) {
                  final matches = weightLogs.where((w) =>
                      w.date.year == dt.year &&
                      w.date.month == dt.month &&
                      w.date.day == dt.day);

                  final hasLog = matches.isNotEmpty;
                  final logWeight = hasLog ? matches.last.weightKg : currentWeight;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasLog || dt.day == now.day)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            logWeight.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      const SizedBox(height: 6),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                          border: Border.all(color: context.cardBg, width: 2),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: dates.map((dt) {
            return Text(
              DateFormat('dd').format(dt),
              style: TextStyle(
                fontSize: 10,
                color: context.secondaryText,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BodyHeatmapPainter extends CustomPainter {
  final BodyFigureModel model;
  final Map<String, int> frequencies;
  final Color primaryColor;
  final Color inactiveColor;

  _BodyHeatmapPainter({
    required this.model,
    required this.frequencies,
    required this.primaryColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final vb = model.viewBoxRect;
    if (size.width <= 0 || size.height <= 0 || vb.width <= 0 || vb.height <= 0) return;

    final scale = (size.width / vb.width) < (size.height / vb.height)
        ? (size.width / vb.width)
        : (size.height / vb.height);

    final dx = (size.width - vb.width * scale) / 2 - vb.left * scale;
    final dy = (size.height - vb.height * scale) / 2 - vb.top * scale;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final paint = Paint()..style = PaintingStyle.fill;

    for (final shape in model.shapes) {
      if (shape.id.startsWith('static_')) {
        paint.color = inactiveColor;
      } else {
        final area = BodyArea.fromMuscleId(shape.id);
        final muscleName = area?.name.toLowerCase() ?? shape.id.toLowerCase();

        int freq = 0;
        frequencies.forEach((key, val) {
          if (muscleName.contains(key) || key.contains(muscleName)) {
            freq += val;
          }
        });

        if (freq > 0) {
          final intensity = (freq / 5.0).clamp(0.3, 1.0);
          paint.color = primaryColor.withAlpha((255 * intensity).round());
        } else {
          paint.color = inactiveColor;
        }
      }

      canvas.drawPath(shape.path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BodyHeatmapPainter oldDelegate) {
    return oldDelegate.model != model ||
        oldDelegate.frequencies != frequencies ||
        oldDelegate.primaryColor != primaryColor;
  }
}
