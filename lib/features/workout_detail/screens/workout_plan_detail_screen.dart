import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/common/widgets/muscle_part_svg_icon.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/data/providers/exercise_provider.dart';
import 'package:workout/data/providers/user_profile_provider.dart';
import 'package:workout/features/challenge/services/challenge_plan_generator.dart';
import 'package:workout/features/workout_detail/widgets/edit_plan_sheet.dart';
import 'package:workout/features/workout_detail/widgets/replace_exercise_sheet.dart';

/// Full Routine / Day Plan Details Screen with rich level support, GIF previews,
/// collapsible intro, "You May Like" section, and horizontal swipe navigation.
class WorkoutPlanDetailScreen extends ConsumerStatefulWidget {
  final String dayTitle;
  final String challengeTitle;
  final String workoutCategory;
  final String targetArea;
  final String level;
  final int dayNumber;

  const WorkoutPlanDetailScreen({
    super.key,
    this.dayTitle = 'DAY 1',
    this.challengeTitle = '',
    this.workoutCategory = 'Full Body',
    this.targetArea = '',
    this.level = 'Beginner',
    this.dayNumber = 1,
  });

  @override
  ConsumerState<WorkoutPlanDetailScreen> createState() => _WorkoutPlanDetailScreenState();
}

class _WorkoutPlanDetailScreenState extends ConsumerState<WorkoutPlanDetailScreen> {
  List<EditableExerciseItem> _planItems = [];
  bool _isInitialized = false;
  bool _isIntroExpanded = true;
  late String _currentLevel;
  late String _currentTitle;

  late final ScrollController _scrollController;
  final GlobalKey _topStartButtonKey = GlobalKey();
  bool _showBottomStartButton = false;

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.level;
    _currentTitle = widget.dayTitle;
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTopButtonVisibility();
    });
  }

  void _onScroll() {
    _checkTopButtonVisibility();
  }

  void _checkTopButtonVisibility() {
    final ctx = _topStartButtonKey.currentContext;
    if (ctx != null) {
      final renderBox = ctx.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize && renderBox.attached) {
        final position = renderBox.localToGlobal(Offset.zero);
        final topBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
        final buttonBottomY = position.dy + renderBox.size.height;
        // The top inline button is visible if its bottom edge is below the pinned top app bar
        final isTopButtonVisible = buttonBottomY > topBarHeight;
        final shouldShow = !isTopButtonVisible;

        if (shouldShow != _showBottomStartButton) {
          setState(() {
            _showBottomStartButton = shouldShow;
          });
        }
        return;
      }
    }

    // Fallback if renderBox is not yet laid out
    if (_scrollController.hasClients) {
      final shouldShow = _scrollController.offset > 480.0;
      if (shouldShow != _showBottomStartButton) {
        setState(() {
          _showBottomStartButton = shouldShow;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final allExercises = ref.watch(allExercisesProvider).value ?? [];
      if (allExercises.isNotEmpty) {
        _initSamplePlan(allExercises);
        _isInitialized = true;
      }
    }
  }

  int _extractDayNum(String title) {
    final match = RegExp(r'DAY\s*(\d+)', caseSensitive: false).firstMatch(title);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '1') ?? 1;
    }
    return 1;
  }

  void _initSamplePlan(List<Exercise> all) {
    final effectiveDayNum = widget.dayNumber > 0 ? widget.dayNumber : _extractDayNum(_currentTitle);
    final effectiveChallengeTitle = widget.challengeTitle.isNotEmpty
        ? widget.challengeTitle
        : (widget.workoutCategory.isNotEmpty ? widget.workoutCategory : widget.targetArea);

    final generated = ChallengePlanGenerator.generatePlan(
      challengeTitle: effectiveChallengeTitle,
      dayNumber: effectiveDayNum,
      level: _currentLevel,
      allExercises: all,
    );

    setState(() {
      _planItems = generated.items;
    });
  }


  Future<void> _openEditPlan() async {
    final updated = await EditPlanSheet.show(context, initialItems: _planItems);
    if (updated != null && mounted) {
      setState(() {
        _planItems = updated;
      });
    }
  }

  Future<void> _replaceExercise(int index) async {
    final newExercise = await ReplaceExerciseSheet.show(
      context,
      currentExercise: _planItems[index].exercise,
    );
    if (newExercise != null && mounted) {
      setState(() {
        _planItems[index].exercise = newExercise;
      });
    }
  }

  void _startWorkoutSession() {
    context.push(AppRoutes.workoutSession, extra: _currentTitle);
  }

  void _switchLevel(String newLevel) {
    if (newLevel == _currentLevel) return;
    setState(() {
      _currentLevel = newLevel;
      final parts = _currentTitle.split(' ');
      if (parts.length > 1 && (parts.last == 'Beginner' || parts.last == 'Intermediate' || parts.last == 'Advanced')) {
        parts[parts.length - 1] = newLevel;
        _currentTitle = parts.join(' ');
      }
    });
    final allExercises = ref.read(allExercisesProvider).value ?? [];
    if (allExercises.isNotEmpty) {
      _initSamplePlan(allExercises);
    }
  }

  void _onSwipeLeft() {
    if (_currentLevel == 'Beginner') {
      _switchLevel('Intermediate');
    } else if (_currentLevel == 'Intermediate') {
      _switchLevel('Advanced');
    }
  }

  void _onSwipeRight() {
    if (_currentLevel == 'Advanced') {
      _switchLevel('Intermediate');
    } else if (_currentLevel == 'Intermediate') {
      _switchLevel('Beginner');
    }
  }

  String _getIntroText() {
    final lower = _currentTitle.toLowerCase();
    if (lower.contains('bat wings') || lower.contains('arm')) {
      return 'Want to get rid of bat wings? This focused session shapes and tones your triceps, transforming flabby arms into sleek, strong ones.';
    } else if (lower.contains('abs') || lower.contains('six pack') || lower.contains('belly')) {
      return 'Want to sculpt strong, defined abs? This core workout targets your upper, lower, and side abdominal muscles for maximum definition and stability.';
    } else if (lower.contains('leg') || lower.contains('booty') || lower.contains('butt')) {
      return 'Target your lower body with key strength exercises designed to shape your legs, elevate glutes, and build lower-body power.';
    }
    return 'Get ready for an invigorating workout session designed to build strength, boost endurance, and maximize caloric burn efficiently.';
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = context.scaffoldBg;
    final cardBg = context.cardBg;
    final border = context.cardBorder;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final userProfile = ref.watch(userProfileProvider);
    final isFemale = userProfile.gender?.toLowerCase() == 'female';

    // Watch Active Riverpod Filters
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

    final displayedPlanItems = activeFilterCount == 0
        ? _planItems
        : _planItems.where((item) {
            return matchesExerciseFilters(
              item.exercise,
              focusAreas: focusAreas,
              equipments: equipments,
              difficulty: difficulty,
              type: type,
              bodyPart: bodyPartFilter,
            );
          }).toList();

    // Calculate total estimated time & exercise count
    final totalSec = displayedPlanItems.fold(0, (sum, item) => sum + item.durationSeconds);
    final totalMins = (totalSec / 60).ceil();
    final exerciseCount = displayedPlanItems.length;

    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < -200) {
              _onSwipeLeft();
            } else if (details.primaryVelocity! > 200) {
              _onSwipeRight();
            }
          }
        },
        child: Stack(
          children: [
            // Scrollable Main Content with NotificationListener
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                _checkTopButtonVisibility();
                return false;
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                // Top Header Image Banner with Overlay
                SliverAppBar(
                  expandedHeight: topInset + 220.0,
                  pinned: true,
                  backgroundColor: scaffoldBg,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withAlpha(140),
                      child: IconButton(
                        icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.white, size: 20),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withAlpha(140),
                        child: IconButton(
                          icon: const HugeIcon(icon: HugeIcons.strokeRoundedFilter, color: AppColors.lime400, size: 20),
                          onPressed: _openEditPlan,
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Container Background
                        Container(color: cardBg),

                        // Gender-aware SVG Muscle Part Graphic (Replacing Static Photo)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: topInset + 16, bottom: 24),
                            child: MusclePartSvgIcon(
                              focusArea: _currentTitle,
                              isFemale: isFemale,
                              size: 180,
                              isSelected: true,
                            ),
                          ),
                        ),

                        // Gradient Overlay for smooth transition to scaffold background
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withAlpha(60),
                                Colors.transparent,
                                scaffoldBg,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Routine Details Body Container
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Routine Title Header
                        Text(
                          _currentTitle,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: context.primaryText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 12),

                        // Badges Row: Level, Time, Exercises Count (Matching Screenshots)
                        Row(
                          children: [
                            _buildBadge(
                              context,
                              icon: HugeIcons.strokeRoundedLayers01,
                              label: _currentLevel,
                            ),
                            const SizedBox(width: 14),
                            _buildBadge(
                              context,
                              icon: HugeIcons.strokeRoundedTimer01,
                              label: '${totalMins == 0 ? 15 : totalMins} mins',
                            ),
                            const SizedBox(width: 14),
                            _buildBadge(
                              context,
                              icon: HugeIcons.strokeRoundedFire,
                              label: '$exerciseCount Exercises',
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Collapsible Introduction Section (Matching Screenshot 1)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _isIntroExpanded = !_isIntroExpanded),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Introduction',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: context.primaryText,
                                      ),
                                    ),
                                    Icon(
                                      _isIntroExpanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      color: primaryColor,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                              if (_isIntroExpanded) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _getIntroText(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.45,
                                    color: context.secondaryText,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Top Primary Brand "Start" Button (Matching Application Theme)
                        SizedBox(
                          key: _topStartButtonKey,
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lime400,
                              foregroundColor: AppColors.black,
                              elevation: 2,
                              shadowColor: AppColors.lime400.withAlpha(100),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            onPressed: _startWorkoutSession,
                            child: const Text(
                              'Start',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Exercises Section Header with Edit Button
                        Row(
                          children: [
                            Text(
                              'Exercises',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: context.primaryText,
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: _openEditPlan,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Text(
                                  'Edit >',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.lime400,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Exercises List with GIF / Image previews & drag reorder handles
                        Theme(
                          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
                          child: ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            buildDefaultDragHandles: false,
                            itemCount: displayedPlanItems.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) {
                                  newIndex -= 1;
                                }
                                final item = displayedPlanItems[oldIndex];
                                _planItems.remove(item);
                                if (newIndex < displayedPlanItems.length) {
                                  final targetItem = displayedPlanItems[newIndex];
                                  final targetIdx = _planItems.indexOf(targetItem);
                                  if (targetIdx != -1) {
                                    _planItems.insert(targetIdx, item);
                                  } else {
                                    _planItems.add(item);
                                  }
                                } else {
                                  _planItems.add(item);
                                }
                              });
                            },
                            itemBuilder: (context, index) {
                              final item = displayedPlanItems[index];
                              return _buildExerciseRow(item, index, displayedPlanItems, cardBg, border);
                            },
                          ),
                        ),

                        const SizedBox(height: 28),

                        // "You may like" Recommendation Section (Matching Screenshot 1)
                        Text(
                          'You may like',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.primaryText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildYouMayLikeSection(context, cardBg, border, isFemale),

                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Persistent Floating Bottom "Start" Action Bar (Only visible when top Start button scrolls off screen)
          AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              left: 0,
              right: 0,
              bottom: _showBottomStartButton ? 0 : -90,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showBottomStartButton ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: scaffoldBg,
                    border: Border(top: BorderSide(color: border)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lime400,
                          foregroundColor: AppColors.black,
                          elevation: 4,
                          shadowColor: AppColors.lime400.withAlpha(120),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        onPressed: _showBottomStartButton ? _startWorkoutSession : null,
                        child: const Text(
                          'Start',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, {required dynamic icon, required String label}) {
    return Row(
      children: [
        if (icon is IconData)
          Icon(icon, size: 16, color: context.secondaryText)
        else
          HugeIcon(icon: icon, size: 16, color: context.secondaryText),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseRow(EditableExerciseItem item, int idx, List<EditableExerciseItem> currentList, Color cardBg, Color border) {
    return Container(
      key: ValueKey('ex_row_${item.exercise.id}_$idx'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: idx,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: HugeIcon(icon: HugeIcons.strokeRoundedMenu01, color: context.secondaryText, size: 22),
            ),
          ),
          const SizedBox(width: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 56,
              height: 56,
              color: context.secondaryText.withAlpha(20),
              child: Image.asset(
                item.exercise.assetGifPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  item.exercise.assetImagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.fitness_center, color: AppColors.lime400),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.exercise.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: context.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.formattedSubtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.lime400, size: 22),
            onPressed: () => _replaceExercise(idx),
          ),
        ],
      ),
    );
  }

  Widget _buildYouMayLikeSection(BuildContext context, Color cardBg, Color border, bool isFemale) {
    final recommendations = [
      {'title': 'Get Rid of Armpit Fat', 'mins': 8, 'level': 'Beginner', 'focus': 'Chest'},
      {'title': '10 Min Lose Arm Fat', 'mins': 11, 'level': 'Beginner', 'focus': 'Arm'},
      {'title': 'Slim Legs Workout', 'mins': 13, 'level': 'Beginner', 'focus': 'Leg'},
      {'title': '3 Exercises Lose Belly Fat', 'mins': 9, 'level': 'Beginner', 'focus': 'Abs'},
    ];

    return Column(
      children: recommendations.map((rec) {
        final title = rec['title'] as String;
        final mins = rec['mins'] as int;
        final level = rec['level'] as String;
        final focus = rec['focus'] as String;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () {
              context.push(
                AppRoutes.workoutPlanDetail,
                extra: {
                  'title': title,
                  'category': focus,
                  'targetArea': focus,
                  'level': level,
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.lime400.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: MusclePartSvgIcon(
                        focusArea: focus,
                        isFemale: isFemale,
                        size: 40,
                        isSelected: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: context.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${mins}mins',
                              style: TextStyle(fontSize: 12, color: context.secondaryText),
                            ),
                            Text(' · ', style: TextStyle(fontSize: 12, color: context.secondaryText)),
                            Text(
                              level,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lime400,
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
          ),
        );
      }).toList(),
    );
  }
}
