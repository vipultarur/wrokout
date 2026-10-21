import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/common/widgets/app_icon.dart';
import 'package:workout/common/widgets/app_search_bar.dart';
import 'package:workout/common/widgets/muscle_part_svg_icon.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/data/providers/exercise_provider.dart';
import 'package:workout/features/workout_detail/widgets/exercise_detail_sheet.dart';

/// Full Search Screen with common AppSearchBar, SVG muscle body focus icons, and dynamic exercise filtering.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  String _selectedBodyFocus = 'All';
  String _selectedWorkoutType = 'All';
  String _selectedLevel = 'All';
  String _selectedDuration = 'All';

  final List<Map<String, String>> _bodyFocusList = const [
    {'title': 'Full Body', 'value': 'Full Body', 'focusArea': 'Full Body'},
    {'title': 'Abs', 'value': 'Abs', 'focusArea': 'Abs'},
    {'title': 'Arm', 'value': 'Arm', 'focusArea': 'Arm'},
    {'title': 'Butt & Leg', 'value': 'Leg', 'focusArea': 'Leg'},
    {'title': 'Chest', 'value': 'Chest', 'focusArea': 'Chest'},
    {'title': 'Shoulder', 'value': 'Shoulder', 'focusArea': 'Shoulder'},
    {'title': 'Back', 'value': 'Back', 'focusArea': 'Back'},
  ];

  final List<Map<String, dynamic>> _workoutTypeList = const [
    {'title': 'Fat Burning', 'value': 'Fat Burning', 'icon': HugeIcons.strokeRoundedFire},
    {'title': 'Build Muscle', 'value': 'Build Muscle', 'icon': HugeIcons.strokeRoundedDumbbell01},
    {'title': 'HIIT', 'value': 'HIIT', 'icon': HugeIcons.strokeRoundedEnergy},
    {'title': 'Warm-Up', 'value': 'Warm-Up', 'icon': HugeIcons.strokeRoundedUser},
    {'title': 'With Equipment', 'value': 'With Equipment', 'icon': HugeIcons.strokeRoundedWeightScale},
    {'title': 'Strength', 'value': 'Strength', 'icon': HugeIcons.strokeRoundedFlash},
  ];

  final List<Map<String, dynamic>> _levelList = const [
    {'title': 'Beginner', 'color': Color(0xFF3B82F6)},
    {'title': 'Intermediate', 'color': Color(0xFFF59E0B)},
    {'title': 'Advanced', 'color': Color(0xFFEF4444)},
  ];

  final List<Map<String, String>> _durationList = const [
    {'title': '≤10 mins', 'value': '10'},
    {'title': '11-20 mins', 'value': '20'},
    {'title': '21-30 mins', 'value': '30'},
    {'title': '30+ mins', 'value': '60'},
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        ref.read(exerciseSearchQueryProvider.notifier).state = query;
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(exerciseSearchQueryProvider.notifier).state = '';
  }

  void _resetAllFilters() {
    _clearSearch();
    setState(() {
      _selectedBodyFocus = 'All';
      _selectedWorkoutType = 'All';
      _selectedLevel = 'All';
      _selectedDuration = 'All';
    });
    ref.read(exerciseBodyPartFilterProvider.notifier).state = 'all';
    ref.read(exerciseEquipmentFilterProvider.notifier).state = 'all';
  }

  List<Exercise> _getFilteredResults(List<Exercise> allExercises) {
    final query = _searchController.text.trim().toLowerCase();

    return allExercises.where((ex) {
      // 1. Text Query Filter
      if (query.isNotEmpty) {
        final matchName = ex.name.toLowerCase().contains(query);
        final matchTarget = ex.target.toLowerCase().contains(query);
        final matchBodyPart = ex.bodyPart.toLowerCase().contains(query);
        final matchEquipment = ex.equipment.toLowerCase().contains(query);
        if (!matchName && !matchTarget && !matchBodyPart && !matchEquipment) {
          return false;
        }
      }

      // 2. Body Focus Filter
      if (_selectedBodyFocus != 'All') {
        final focusMap = focusAreaToBodyPartMap[_selectedBodyFocus] ?? [_selectedBodyFocus.toLowerCase()];
        bool matchesFocus = false;
        for (final targetPart in focusMap) {
          if (ex.bodyPart.toLowerCase().contains(targetPart.toLowerCase())) {
            matchesFocus = true;
            break;
          }
        }
        if (!matchesFocus) return false;
      }

      // 3. Workout Type Filter
      if (_selectedWorkoutType != 'All') {
        if (_selectedWorkoutType == 'With Equipment') {
          if (ex.equipment.toLowerCase() == 'body weight' || ex.equipment.toLowerCase() == 'none') {
            return false;
          }
        } else if (_selectedWorkoutType == 'Fat Burning' || _selectedWorkoutType == 'HIIT') {
          final isCardio = ex.bodyPart.toLowerCase().contains('cardio') ||
              ex.target.toLowerCase().contains('cardio') ||
              ex.equipment.toLowerCase().contains('mat') ||
              ex.equipment.toLowerCase() == 'body weight';
          if (!isCardio) return false;
        } else if (_selectedWorkoutType == 'Strength' || _selectedWorkoutType == 'Build Muscle') {
          // Strength exercises typically use equipment
          if (ex.equipment.toLowerCase() == 'body weight') return false;
        }
      }

      // 4. Level / Difficulty Filter
      if (_selectedLevel != 'All') {
        if (ex.difficulty.toLowerCase() != _selectedLevel.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final asyncExercises = ref.watch(allExercisesProvider);
    final allExercises = asyncExercises.value ?? [];
    final filteredExercises = _getFilteredResults(allExercises);

    final bool isFilterActive = _selectedBodyFocus != 'All' ||
        _selectedWorkoutType != 'All' ||
        _selectedLevel != 'All' ||
        _selectedDuration != 'All' ||
        _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // ─── Header Search Bar ───
            Container(
              color: context.scaffoldBg,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: AppSearchBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onClear: _clearSearch,
                      autofocus: true,
                      hintText: 'Search workouts, plans...',
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {
                      if (_searchController.text.isNotEmpty || isFilterActive) {
                        _resetAllFilters();
                      } else {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.home);
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Scrollable Main Content ───
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // ─── 1. Body Focus Section with SVG Muscle Icons ───
                  _buildSectionTitle('Body Focus'),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 104,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _bodyFocusList.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final item = _bodyFocusList[index];
                        final isSelected = _selectedBodyFocus == item['value'];
                        final focusArea = item['focusArea']!;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedBodyFocus = _selectedBodyFocus == item['value'] ? 'All' : item['value']!;
                            });
                          },
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? primaryColor.withAlpha(50)
                                      : context.cardBg,
                                  border: Border.all(
                                    color: isSelected ? primaryColor : context.cardBorder,
                                    width: isSelected ? 2.5 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: primaryColor.withAlpha(60),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: MusclePartSvgIcon(
                                      focusArea: focusArea,
                                      isSelected: isSelected,
                                      size: 44,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['title']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? primaryColor : context.primaryText,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── 2. Workout Type Section ───
                  _buildSectionTitle('Workout Type'),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _workoutTypeList.length,
                    itemBuilder: (context, index) {
                      final item = _workoutTypeList[index];
                      final isSelected = _selectedWorkoutType == item['value'];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedWorkoutType = _selectedWorkoutType == item['value'] ? 'All' : item['value'] as String;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor.withAlpha(45)
                                : context.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? primaryColor : context.cardBorder,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['title'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? primaryColor : context.primaryText,
                                  ),
                                ),
                              ),
                              AppIcon(
                                icon: item['icon'],
                                color: isSelected ? primaryColor : context.secondaryText,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ─── 3. Level Section ───
                  _buildSectionTitle('Level'),
                  const SizedBox(height: 12),
                  Row(
                    children: _levelList.map((item) {
                      final title = item['title'] as String;
                      final accentColor = item['color'] as Color;
                      final isSelected = _selectedLevel == title;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedLevel = _selectedLevel == title ? 'All' : title;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? accentColor.withAlpha(35)
                                    : context.cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? accentColor : context.cardBorder,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? accentColor : context.primaryText,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ─── 4. Duration Section ───
                  _buildSectionTitle('Duration'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 54,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _durationList.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = _durationList[index];
                        final title = item['title']!;
                        final isSelected = _selectedDuration == title;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDuration = _selectedDuration == title ? 'All' : title;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 100,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withAlpha(45)
                                  : context.cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? primaryColor : context.cardBorder,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? primaryColor : context.primaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  const SizedBox(height: 16),

                  // ─── 6. Live Search Results List ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Matches (${filteredExercises.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.primaryText,
                        ),
                      ),
                      if (isFilterActive)
                        GestureDetector(
                          onTap: _resetAllFilters,
                          child: Text(
                            'Reset All',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (asyncExercises.isLoading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    )
                  else if (filteredExercises.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.cardBorder),
                      ),
                      child: Column(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedSearch01,
                            size: 40,
                            color: context.secondaryText,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No workouts match your filters',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: context.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try selecting different body parts or clearing your search.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredExercises.length > 30 ? 30 : filteredExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = filteredExercises[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SearchResultCardWidget(exercise: exercise),
                        );
                      },
                    ),

                  const SizedBox(height: 110),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: context.primaryText,
      ),
    );
  }
}

class SearchResultCardWidget extends StatelessWidget {
  final Exercise exercise;

  const SearchResultCardWidget({
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
                width: 60,
                height: 60,
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
                        size: 26,
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: context.secondaryText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
