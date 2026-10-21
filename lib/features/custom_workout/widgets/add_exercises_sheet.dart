import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/data/providers/exercise_provider.dart';
import 'package:workout/features/exercises/widgets/exercise_filter_sheet.dart';

/// Full screen bottom sheet for selecting and adding exercises to a custom workout routine.
/// Matches layout, filter pill, search bar, recommended section, multi-select, and bottom button from Image 2.
class AddExercisesSheet extends ConsumerStatefulWidget {
  final List<String> initialSelectedIds;

  const AddExercisesSheet({
    super.key,
    this.initialSelectedIds = const [],
  });

  static Future<List<Exercise>?> show(
    BuildContext context, {
    List<String> initialSelectedIds = const [],
  }) {
    return showModalBottomSheet<List<Exercise>>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExercisesSheet(initialSelectedIds: initialSelectedIds),
    );
  }

  @override
  ConsumerState<AddExercisesSheet> createState() => _AddExercisesSheetState();
}

class _AddExercisesSheetState extends ConsumerState<AddExercisesSheet> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  final Map<String, Exercise> _selectedExercisesMap = {};
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(widget.initialSelectedIds);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(Exercise exercise) {
    setState(() {
      if (_selectedIds.contains(exercise.id)) {
        _selectedIds.remove(exercise.id);
        _selectedExercisesMap.remove(exercise.id);
      } else {
        _selectedIds.add(exercise.id);
        _selectedExercisesMap[exercise.id] = exercise;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(allExercisesProvider);
    final focusAreas = ref.watch(selectedFocusAreasProvider);
    final equipments = ref.watch(selectedEquipmentSetProvider);
    final difficulty = ref.watch(selectedDifficultyProvider);
    final type = ref.watch(selectedTypeProvider);
    final bodyPartFilter = ref.watch(exerciseBodyPartFilterProvider);

    final activeFilterCount = focusAreas.length +
        equipments.length +
        (difficulty != null ? 1 : 0) +
        (type != null ? 1 : 0) +
        (bodyPartFilter != 'all' ? 1 : 0);

    final primaryColor = Theme.of(context).colorScheme.primary;
    final scaffoldBg = context.scaffoldBg;
    final border = context.cardBorder;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomInset = bottomPadding > 0 ? bottomPadding : 16.0;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.96,
      minChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: scaffoldBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Drag indicator & Header
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.secondaryText.withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // Header with Title & Close button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Exercises',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: context.primaryText,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.isDarkMode
                              ? AppColors.darkCardAlt
                              : const Color(0xFFE5E5EA),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            color: context.secondaryText,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Filter Pill button opening ExerciseFilterSheet (used in days/exercise screen)
              allAsync.when(
                data: (all) {
                  final filteredList = _getFilteredList(
                    all,
                    focusAreas: focusAreas,
                    equipments: equipments,
                    difficulty: difficulty,
                    type: type,
                    bodyPartFilter: bodyPartFilter,
                  );
                  final filteredCount = filteredList.length;
                  final pillLabel = activeFilterCount > 0
                      ? 'Filtered ($activeFilterCount active • $filteredCount)'
                      : 'Filtered ($filteredCount)';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () => ExerciseFilterSheet.show(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: activeFilterCount > 0
                                ? primaryColor.withAlpha(40)
                                : (context.isDarkMode
                                    ? AppColors.darkCardAlt
                                    : const Color(0xFFF2F2ED)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: activeFilterCount > 0 ? primaryColor : border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedFilter,
                                color: activeFilterCount > 0 ? primaryColor : context.primaryText,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                pillLabel,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: activeFilterCount > 0 ? primaryColor : context.primaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (err, st) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 14),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _query = val.trim().toLowerCase()),
                  style: TextStyle(color: context.primaryText, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search exercises',
                    hintStyle: TextStyle(color: context.secondaryText, fontSize: 15),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 10),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01,
                        color: context.secondaryText,
                        size: 20,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 44),
                    filled: true,
                    fillColor: context.isDarkMode
                        ? AppColors.darkCardAlt
                        : const Color(0xFFF2F2ED),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Exercises Content List
              Expanded(
                child: allAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                  error: (err, st) => Center(child: Text('Failed to load exercises: $err')),
                  data: (all) {
                    for (var ex in all) {
                      if (_selectedIds.contains(ex.id)) {
                        _selectedExercisesMap[ex.id] = ex;
                      }
                    }

                    final filteredList = _getFilteredList(
                      all,
                      focusAreas: focusAreas,
                      equipments: equipments,
                      difficulty: difficulty,
                      type: type,
                      bodyPartFilter: bodyPartFilter,
                    );

                    if (filteredList.isEmpty) {
                      return Center(
                        child: Text(
                          'No exercises found matching search.',
                          style: TextStyle(color: context.secondaryText),
                        ),
                      );
                    }

                    final recommended = filteredList.take(6).toList();
                    final remaining = filteredList.skip(6).toList();

                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      children: [
                        if (recommended.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Recommended',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          ...recommended.map((ex) => _buildExerciseTile(context, ex, primaryColor)),
                          const SizedBox(height: 16),
                        ],

                        if (remaining.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'All Exercises',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: context.primaryText,
                              ),
                            ),
                          ),
                          ...remaining.map((ex) => _buildExerciseTile(context, ex, primaryColor)),
                        ],
                      ],
                    );
                  },
                ),
              ),

              // Sticky Bottom Action Bar with Solid Background & Border
              Container(
                padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 8),
                decoration: BoxDecoration(
                  color: scaffoldBg,
                  border: Border(top: BorderSide(color: border, width: 0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(context.isDarkMode ? 80 : 20),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedIds.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: primaryColor.withAlpha(40),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                '${_selectedIds.length} selected',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedIds.clear();
                                  _selectedExercisesMap.clear();
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: Text(
                                  'Clear all',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: context.secondaryText,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final selectedList = _selectedIds
                              .map((id) => _selectedExercisesMap[id])
                              .whereType<Exercise>()
                              .toList();
                          Navigator.of(context).pop(selectedList);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                        icon: Icon(
                          _selectedIds.isNotEmpty ? Icons.add_circle_outline_rounded : Icons.close_rounded,
                          size: 22,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        label: Text(
                          _selectedIds.isNotEmpty
                              ? 'Add ${_selectedIds.length} exercises'
                              : 'Close',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                            letterSpacing: 0.3,
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
      },
    );
  }

  List<Exercise> _getFilteredList(
    List<Exercise> all, {
    required Set<String> focusAreas,
    required Set<String> equipments,
    required String? difficulty,
    required String? type,
    required String bodyPartFilter,
  }) {
    return all.where((e) {
      if (!matchesExerciseFilters(
        e,
        focusAreas: focusAreas,
        equipments: equipments,
        difficulty: difficulty,
        type: type,
        bodyPart: bodyPartFilter,
      )) {
        return false;
      }
      if (_query.isNotEmpty) {
        final matchName = e.name.toLowerCase().contains(_query);
        final matchTarget = e.target.toLowerCase().contains(_query);
        final matchPart = e.bodyPart.toLowerCase().contains(_query);
        if (!matchName && !matchTarget && !matchPart) return false;
      }
      return true;
    }).toList();
  }

  Widget _buildExerciseTile(BuildContext context, Exercise exercise, Color primaryColor) {
    final isSelected = _selectedIds.contains(exercise.id);
    final isTimeBased = exercise.isTimeBased;
    final metricText = isTimeBased
        ? (exercise.durationSeconds > 0 ? '00:${exercise.durationSeconds.toString().padLeft(2, '0')}' : '00:20')
        : 'x${exercise.reps > 0 ? exercise.reps : 10}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _toggleSelection(exercise),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            children: [
              // Exercise Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 60,
                  height: 60,
                  color: context.isDarkMode
                      ? AppColors.darkCardAlt
                      : const Color(0xFFF2F2ED),
                  child: Image.asset(
                    exercise.assetImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedDumbbell01,
                        color: context.secondaryText,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and Reps/Duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: context.primaryText,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metricText,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Selection Circle matching Image 1 with Black checkmark icon from theme
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? primaryColor
                      : (context.isDarkMode ? const Color(0xFF333333) : const Color(0xFFE5E5EA)),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
