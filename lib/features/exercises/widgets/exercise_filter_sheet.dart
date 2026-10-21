import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/common/widgets/muscle_part_svg_icon.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/exercise_provider.dart';
import 'package:workout/data/providers/user_profile_provider.dart';

/// Exercise Filter Sheet matching Image 2 with double theme support.
class ExerciseFilterSheet extends ConsumerStatefulWidget {
  const ExerciseFilterSheet({super.key});

  /// Static helper to display this sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ExerciseFilterSheet(),
    );
  }

  @override
  ConsumerState<ExerciseFilterSheet> createState() => _ExerciseFilterSheetState();
}

class _ExerciseFilterSheetState extends ConsumerState<ExerciseFilterSheet> {
  late Set<String> _focusAreas;
  late String? _difficulty;
  late String? _type;
  late Set<String> _equipments;

  final List<Map<String, String>> _focusAreaOptions = const [
    {'label': 'Abs', 'icon': '🏋️'},
    {'label': 'Chest', 'icon': '🛡️'},
    {'label': 'Back', 'icon': '🦅'},
    {'label': 'Arm', 'icon': '💪'},
    {'label': 'Leg', 'icon': '🦵'},
    {'label': 'Glutes', 'icon': '🍑'},
    {'label': 'Shoulder', 'icon': '🎯'},
  ];

  final List<String> _difficultyOptions = const ['Easy', 'Medium', 'Hard'];
  final List<String> _typeOptions = const ['Warm up', 'Stretch', 'Training'];
  final List<String> _equipmentOptions = const [
    'No equipment',
    'Dumbbell',
    'Band',
    'Chair',
    'Bench',
    'Mat',
  ];

  @override
  void initState() {
    super.initState();
    _focusAreas = Set.from(ref.read(selectedFocusAreasProvider));
    _difficulty = ref.read(selectedDifficultyProvider);
    _type = ref.read(selectedTypeProvider);
    _equipments = Set.from(ref.read(selectedEquipmentSetProvider));
  }

  void _clearAllFilters() {
    setState(() {
      _focusAreas.clear();
      _difficulty = null;
      _type = null;
      _equipments.clear();
    });
  }

  int _calculateFilteredCount() {
    final allExercises = ref.read(allExercisesProvider).value ?? [];
    return allExercises.where((e) {
      return matchesExerciseFilters(
        e,
        focusAreas: _focusAreas,
        equipments: _equipments,
        difficulty: _difficulty,
        type: _type,
      );
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final filteredCount = _calculateFilteredCount();
    final profile = ref.watch(userProfileProvider);
    final isFemale = (profile.gender ?? 'male').toLowerCase() == 'female';

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: context.scaffoldBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.secondaryText.withAlpha(60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header: "Filtered [trashcan]" & "[162 exercises]"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Filtered',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: context.primaryText,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _clearAllFilters,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: context.secondaryText,
                    size: 22,
                  ),
                  tooltip: 'Clear all filters',
                ),
                const Spacer(),
                Text(
                  '$filteredCount exercises',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Active filter chips bar
          if (_focusAreas.isNotEmpty || _difficulty != null || _type != null || _equipments.isNotEmpty)
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ..._focusAreas.map((area) => _buildActiveChip(area, () {
                        setState(() => _focusAreas.remove(area));
                      })),
                  if (_difficulty != null)
                    _buildActiveChip(_difficulty!, () {
                      setState(() => _difficulty = null);
                    }),
                  if (_type != null)
                    _buildActiveChip(_type!, () {
                      setState(() => _type = null);
                    }),
                  ..._equipments.map((eq) => _buildActiveChip(eq, () {
                        setState(() => _equipments.remove(eq));
                      })),
                ],
              ),
            ),

          const Divider(height: 20),

          // Main Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // ─── 1. Focus Area Section ───
                Text(
                  'Focus Area',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.primaryText,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _focusAreaOptions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.5,
                  ),
                  itemBuilder: (context, index) {
                    final item = _focusAreaOptions[index];
                    final label = item['label']!;
                    final isSelected = _focusAreas.contains(label);

                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _focusAreas.remove(label);
                          } else {
                            _focusAreas.add(label);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor.withAlpha(40) : context.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? primaryColor : context.cardBorder,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            MusclePartSvgIcon(
                              focusArea: label,
                              isFemale: isFemale,
                              isSelected: isSelected,
                              size: 40.0,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? primaryColor : context.primaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ─── 2. Difficulty Section ───
                Text(
                  'Difficulty',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.primaryText,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  children: _difficultyOptions.map((diff) {
                    final isSelected = _difficulty == diff;
                    return ChoiceChip(
                      label: Text(diff),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _difficulty = selected ? diff : null;
                        });
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
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // ─── 3. Type Section ───
                Text(
                  'Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.primaryText,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  children: _typeOptions.map((t) {
                    final isSelected = _type == t;
                    return ChoiceChip(
                      label: Text(t),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _type = selected ? t : null;
                        });
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
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // ─── 4. Equipment Section ───
                Text(
                  'Equipment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.primaryText,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _equipmentOptions.map((eq) {
                    final isSelected = _equipments.contains(eq);
                    return FilterChip(
                      label: Text(eq),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _equipments.add(eq);
                          } else {
                            _equipments.remove(eq);
                          }
                        });
                      },
                      selectedColor: primaryColor,
                      backgroundColor: context.cardBg,
                      checkmarkColor: AppColors.black,
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
                  }).toList(),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // Bottom Action Buttons: [ Cancel ] [ Save ]
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: context.scaffoldBg,
              border: Border(top: BorderSide(color: context.cardBorder)),
            ),
            child: Row(
              children: [
                // Cancel Button
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.primaryText,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Save Button
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: AppColors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: context.primaryText,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: context.secondaryText),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    ref.read(selectedFocusAreasProvider.notifier).state = _focusAreas;
    ref.read(selectedDifficultyProvider.notifier).state = _difficulty;
    ref.read(selectedTypeProvider.notifier).state = _type;
    ref.read(selectedEquipmentSetProvider.notifier).state = _equipments;

    // Sync primary bodyPart filter if single focus area selected
    if (_focusAreas.isNotEmpty) {
      final firstArea = _focusAreas.first;
      final mapped = focusAreaToBodyPartMap[firstArea]?.first ?? 'all';
      ref.read(exerciseBodyPartFilterProvider.notifier).state = mapped;
    } else {
      ref.read(exerciseBodyPartFilterProvider.notifier).state = 'all';
    }

    context.pop();
  }
}
