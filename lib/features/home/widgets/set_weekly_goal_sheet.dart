import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/user_profile_provider.dart';

/// Modal bottom sheet to update user weekly training days goal and first day of week.
/// Matches the design from Image 3 styled using the application theme.
class SetWeeklyGoalSheet extends ConsumerStatefulWidget {
  const SetWeeklyGoalSheet({super.key});

  /// Static helper to display this sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SetWeeklyGoalSheet(),
    );
  }

  @override
  ConsumerState<SetWeeklyGoalSheet> createState() => _SetWeeklyGoalSheetState();
}

class _SetWeeklyGoalSheetState extends ConsumerState<SetWeeklyGoalSheet> {
  late int _selectedDays;
  late String _selectedFirstDay;

  final List<String> _firstDayOptions = const [
    'SUNDAY',
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _selectedDays = profile.weeklyGoalDays;

    // Normalize case for firstDayOfWeek option matching
    final existingDay = profile.firstDayOfWeek.toUpperCase();
    if (_firstDayOptions.contains(existingDay)) {
      _selectedFirstDay = existingDay;
    } else {
      _selectedFirstDay = 'SUNDAY';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: context.scaffoldBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle & Back/Close Header
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    color: context.primaryText,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.secondaryText.withAlpha(60),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 24), // Balance the back arrow
              ],
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              'Set your weekly goal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: context.primaryText,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'We recommend training at least 3 days weekly for a better result.',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: context.secondaryText,
              ),
            ),

            const SizedBox(height: 28),

            // Weekly training days label
            Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Weekly training days',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.secondaryText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Training days selection grid (1-4 on row 1, 5-7 on row 2)
            Column(
              children: [
                // Row 1: 1, 2, 3, 4
                Row(
                  children: [1, 2, 3, 4].map((day) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildDayChip(day, primaryColor),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // Row 2: 5, 6, 7
                Row(
                  children: [
                    for (int day in [5, 6, 7])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _buildDayChip(day, primaryColor),
                        ),
                      ),
                    const Expanded(child: SizedBox()), // spacer for balance
                  ],
                ),
              ],
            ),

            const SizedBox(height: 28),

            // First day of week label
            Row(
              children: [
                const Text('🗓️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'First day of week',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.secondaryText,
                  ),
                ),
                const Spacer(),
                Text(
                  _selectedFirstDay,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.lime400,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Interactive Up/Down Scroll Wheel Picker UI
            Container(
              height: 120,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.cardBorder),
              ),
              child: CupertinoPicker(
                itemExtent: 38,
                magnification: 1.15,
                useMagnifier: true,
                squeeze: 1.2,
                scrollController: FixedExtentScrollController(
                  initialItem: _firstDayOptions.indexOf(_selectedFirstDay).clamp(0, _firstDayOptions.length - 1),
                ),
                selectionOverlay: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.lime400.withAlpha(35),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lime400.withAlpha(140), width: 1.5),
                  ),
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedFirstDay = _firstDayOptions[index];
                  });
                },
                children: _firstDayOptions.map((day) {
                  final isSelected = day == _selectedFirstDay;
                  return Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                        color: isSelected ? context.primaryText : context.secondaryText.withAlpha(140),
                        letterSpacing: 1.0,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: AppColors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(int day, Color primaryColor) {
    final isSelected = _selectedDays == day;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedDays = day;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : context.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withAlpha(80),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.black : context.primaryText,
            ),
          ),
        ),
      ),
    );
  }

  void _saveGoal() {
    final notifier = ref.read(userProfileProvider.notifier);
    notifier.setWeeklyGoalDays(_selectedDays);
    notifier.setFirstDayOfWeek(_selectedFirstDay);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Weekly goal updated to $_selectedDays days/week!'),
        backgroundColor: context.cardBg,
        duration: const Duration(seconds: 2),
      ),
    );

    context.pop();
  }
}
