import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/common/widgets/app_search_bar.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/data/providers/exercise_provider.dart';
import 'package:workout/features/exercises/widgets/exercise_filter_sheet.dart';

/// Replace exercise bottom sheet matching KREW application theme.
class ReplaceExerciseSheet extends ConsumerStatefulWidget {
  final Exercise currentExercise;
  final ValueChanged<Exercise> onSelected;

  const ReplaceExerciseSheet({
    super.key,
    required this.currentExercise,
    required this.onSelected,
  });

  static Future<Exercise?> show(
    BuildContext context, {
    required Exercise currentExercise,
  }) {
    return showModalBottomSheet<Exercise>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReplaceExerciseSheet(
        currentExercise: currentExercise,
        onSelected: (selected) => Navigator.of(context).pop(selected),
      ),
    );
  }

  @override
  ConsumerState<ReplaceExerciseSheet> createState() => _ReplaceExerciseSheetState();
}

class _ReplaceExerciseSheetState extends ConsumerState<ReplaceExerciseSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    _selectedCategoryFilter = widget.currentExercise.displayBodyPart;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(allExercisesProvider);
    final focusAreas = ref.watch(selectedFocusAreasProvider);
    final equipments = ref.watch(selectedEquipmentSetProvider);
    final sheetBg = context.scaffoldBg;
    final cardBg = context.cardBg;
    final border = context.cardBorder;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: border, width: 0.8),
          ),
          child: Column(
            children: [
              // Top Drag Handle & Close Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.secondaryText.withAlpha(80),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    IconButton(
                      icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: context.primaryText),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Title Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current: ${widget.currentExercise.name}',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Replace it with...',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: context.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Filter pill & clear row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => ExerciseFilterSheet.show(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.lime400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const HugeIcon(icon: HugeIcons.strokeRoundedFilter, color: AppColors.black, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Filtered (${_getFilteredCount(allAsync.value ?? [], focusAreas: focusAreas, equipments: equipments)})',
                              style: const TextStyle(
                                color: AppColors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_selectedCategoryFilter != null || _query.isNotEmpty || focusAreas.isNotEmpty || equipments.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategoryFilter = null;
                            _query = '';
                            _searchController.clear();
                            ref.read(selectedFocusAreasProvider.notifier).state = {};
                            ref.read(selectedEquipmentSetProvider.notifier).state = {};
                            ref.read(selectedDifficultyProvider.notifier).state = null;
                            ref.read(selectedTypeProvider.notifier).state = null;
                          });
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            color: AppColors.lime400,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Category Chip Tag
              if (_selectedCategoryFilter != null) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InputChip(
                      label: Text(_selectedCategoryFilter!),
                      onDeleted: () {
                        setState(() => _selectedCategoryFilter = null);
                      },
                      deleteIcon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01, size: 16),
                      backgroundColor: cardBg,
                      side: BorderSide(color: border),
                      labelStyle: TextStyle(
                        color: context.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Search Bar
              AppSearchBar(
                controller: _searchController,
                hintText: 'Search exercises',
                padding: const EdgeInsets.symmetric(horizontal: 20),
                onChanged: (val) => setState(() => _query = val.trim().toLowerCase()),
                onClear: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),

              const SizedBox(height: 16),

              // Exercises List
              Expanded(
                child: allAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                  error: (err, _) => Center(child: Text('Failed to load exercises: $err')),
                  data: (allExercises) {
                    final filtered = _filterList(
                      allExercises,
                      focusAreas: focusAreas,
                      equipments: equipments,
                    );

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'No matching exercises found.',
                          style: TextStyle(color: context.secondaryText),
                        ),
                      );
                    }

                    final currentBodyPart = widget.currentExercise.bodyPart;
                    final recommended = filtered
                        .where((e) => e.bodyPart == currentBodyPart && e.id != widget.currentExercise.id)
                        .take(4)
                        .toList();

                    final remaining = filtered
                        .where((e) => !recommended.contains(e) && e.id != widget.currentExercise.id)
                        .toList();

                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      children: [
                        if (recommended.isNotEmpty) ...[
                          const Text(
                            'Recommended',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lime400,
                            ),
                          ),

                          const SizedBox(height: 8),
                          ...recommended.map((ex) {
                            String tag = 'Similar';
                            if (ex.equipment == 'body weight' && widget.currentExercise.equipment != 'body weight') {
                              tag = 'Easier';
                            } else if (ex.equipment != 'body weight' && widget.currentExercise.equipment == 'body weight') {
                              tag = 'Harder';
                            }
                            return _buildExerciseTile(context, ex, tagBadge: tag);
                          }),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          'All Exercises',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...remaining.map((ex) => _buildExerciseTile(context, ex)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _getFilteredCount(
    List<Exercise> all, {
    required Set<String> focusAreas,
    required Set<String> equipments,
  }) {
    return _filterList(all, focusAreas: focusAreas, equipments: equipments).length;
  }

  List<Exercise> _filterList(
    List<Exercise> all, {
    required Set<String> focusAreas,
    required Set<String> equipments,
  }) {
    const focusAreaMap = <String, List<String>>{
      'Abs': ['waist'],
      'Chest': ['chest'],
      'Back': ['back'],
      'Arm': ['upper arms', 'lower arms'],
      'Leg': ['upper legs', 'lower legs'],
      'Glutes': ['glutes', 'upper legs'],
      'Shoulder': ['shoulders'],
    };

    const equipmentMap = <String, String>{
      'No equipment': 'body weight',
      'Dumbbell': 'dumbbell',
      'Band': 'band',
      'Chair': 'chair',
      'Bench': 'bench',
      'Mat': 'mat',
    };

    return all.where((e) {
      if (_selectedCategoryFilter != null &&
          e.displayBodyPart.toLowerCase() != _selectedCategoryFilter!.toLowerCase()) {
        return false;
      }
      if (_query.isNotEmpty) {
        final matchName = e.name.toLowerCase().contains(_query);
        final matchTarget = e.target.toLowerCase().contains(_query);
        final matchPart = e.bodyPart.toLowerCase().contains(_query);
        if (!matchName && !matchTarget && !matchPart) return false;
      }
      if (focusAreas.isNotEmpty) {
        final matches = focusAreas.any((area) {
          final mappedParts = focusAreaMap[area] ?? [];
          return mappedParts.contains(e.bodyPart.toLowerCase());
        });
        if (!matches) return false;
      }
      if (equipments.isNotEmpty) {
        final matches = equipments.any((eq) {
          final mappedEq = equipmentMap[eq] ?? eq.toLowerCase();
          return e.equipment.toLowerCase().contains(mappedEq) ||
              (mappedEq == 'body weight' && e.equipment.toLowerCase() == 'body weight');
        });
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  Widget _buildExerciseTile(BuildContext context, Exercise exercise, {String? tagBadge}) {
    final cardColor = context.cardBg;
    final border = context.cardBorder;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 56,
            height: 56,
            color: context.secondaryText.withAlpha(20),
            child: Image.asset(
              exercise.assetImagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const HugeIcon(icon: HugeIcons.strokeRoundedDumbbell01, color: AppColors.lime400),

            ),
          ),
        ),
        title: Text(
          exercise.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.primaryText),
        ),
        subtitle: tagBadge != null
            ? Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.lime400.withAlpha(40),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tagBadge,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lime400,
                    ),
                  ),
                ),
              )
            : Text(
                exercise.displayBodyPart,
                style: TextStyle(fontSize: 12, color: context.secondaryText),
              ),
        trailing: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 2),
          ),
        ),
        onTap: () => widget.onSelected(exercise),
      ),
    );
  }
}
