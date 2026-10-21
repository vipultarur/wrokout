import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout/common/widgets/app_search_bar.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/data/providers/exercise_provider.dart';
import 'package:workout/features/workout_detail/widgets/exercise_detail_sheet.dart';


import 'package:workout/features/exercises/widgets/exercise_filter_sheet.dart';

/// Full Exercise Browser & Search Screen with full Double Theme support.
class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  final List<Map<String, String>> _categories = const [
    {'id': 'all', 'name': 'All Muscles', 'icon': '🏋️'},
    {'id': 'waist', 'name': 'Abs / Core', 'icon': '⚡'},
    {'id': 'chest', 'name': 'Chest', 'icon': '🛡️'},
    {'id': 'upper arms', 'name': 'Arms', 'icon': '💪'},
    {'id': 'upper legs', 'name': 'Legs', 'icon': '🦵'},
    {'id': 'back', 'name': 'Back', 'icon': '🦅'},
    {'id': 'shoulders', 'name': 'Shoulders', 'icon': '🎯'},
    {'id': 'cardio', 'name': 'Cardio', 'icon': '🔥'},
  ];

  final List<Map<String, String>> _equipments = const [
    {'id': 'all', 'name': 'All Equipment'},
    {'id': 'body weight', 'name': 'Body Weight'},
    {'id': 'dumbbell', 'name': 'Dumbbell'},
    {'id': 'barbell', 'name': 'Barbell'},
    {'id': 'cable', 'name': 'Cable'},
    {'id': 'band', 'name': 'Band'},
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(exerciseSearchQueryProvider);
    final category = ref.watch(exerciseBodyPartFilterProvider);
    final equipment = ref.watch(exerciseEquipmentFilterProvider);
    final exercises = ref.watch(filteredExercisesProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        elevation: 0,
        title: Text(
          'Exercise Library',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.primaryText,
          ),
        ),
      ),
      body: Column(
        children: [
          // ─── Search Bar & Filter Button ───
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: AppSearchBar(
                    controller: _searchController,
                    hintText: 'Search 1,300+ exercises...',
                    onChanged: (val) {
                      _debounceTimer?.cancel();
                      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                        if (mounted) {
                          ref.read(exerciseSearchQueryProvider.notifier).state = val;
                        }
                      });
                    },
                    onClear: () {
                      _searchController.clear();
                      ref.read(exerciseSearchQueryProvider.notifier).state = '';
                    },
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => ExerciseFilterSheet.show(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: primaryColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor),
                    ),
                    child: Icon(Icons.filter_list_rounded, color: primaryColor, size: 22),
                  ),
                ),
              ],
            ),
          ),

          // ─── Category Filter Chips ───
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final id = cat['id']!;
                final isSelected = category == id;

                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cat['icon']!, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(cat['name']!),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    ref.read(exerciseBodyPartFilterProvider.notifier).state =
                        selected ? id : 'all';
                  },
                  selectedColor: primaryColor,
                  backgroundColor: context.cardBg,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppColors.raisinBlack
                        : context.secondaryText,
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

          const SizedBox(height: 8),

          // ─── Equipment Filter Chips ───
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _equipments.length,
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final eq = _equipments[index];
                final id = eq['id']!;
                final isSelected = equipment == id;

                return FilterChip(
                  label: Text(eq['name']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    ref.read(exerciseEquipmentFilterProvider.notifier).state =
                        selected ? id : 'all';
                  },
                  selectedColor: AppColors.paleLime,
                  backgroundColor: context.cardBg,
                  checkmarkColor: AppColors.raisinBlack,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.raisinBlack : context.secondaryText,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? primaryColor : context.cardBorder,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // ─── Results Counter ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${exercises.length} Exercises Found',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.secondaryText,
                  ),
                ),
                if (category != 'all' || equipment != 'all' || search.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      ref.read(exerciseSearchQueryProvider.notifier).state = '';
                      ref.read(exerciseBodyPartFilterProvider.notifier).state = 'all';
                      ref.read(exerciseEquipmentFilterProvider.notifier).state = 'all';
                    },
                    child: Text(
                      'Reset Filters',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ─── Exercise List ───
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 64, color: context.secondaryText),
                        const SizedBox(height: 12),
                        Text(
                          'No exercises match your search',
                          style: TextStyle(
                            fontSize: 16,
                            color: context.primaryText,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ExerciseCardWidget(exercise: exercise),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ExerciseCardWidget extends StatelessWidget {
  final Exercise exercise;

  const ExerciseCardWidget({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => ExerciseDetailSheet.show(context, exercise: exercise),
      child: Container(

        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.cardBorder),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 64,
                height: 64,
                color: Colors.white,
                child: Image.asset(
                  exercise.assetGifPath,
                  cacheWidth: 160,
                  cacheHeight: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: context.isDarkMode ? AppColors.raisinBlack : AppColors.cottonSeedLight,
                      child: Icon(
                        Icons.fitness_center_rounded,
                        color: primaryColor,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.isDarkMode
                              ? AppColors.paleLime.withAlpha(45)
                              : AppColors.paleLime,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          exercise.target.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.raisinBlack,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.isDarkMode ? AppColors.raisinBlack : AppColors.cottonSeedLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          exercise.equipment.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: context.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.secondaryText,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
