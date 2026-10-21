import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/features/workout_detail/widgets/replace_exercise_sheet.dart';

/// Item wrapper for editing workout plan exercises.
class EditableExerciseItem {
  Exercise exercise;
  int durationSeconds;
  final int originalDurationSeconds;
  final String category; // Warm Up, Training, Cool Down
  int repsCount;

  EditableExerciseItem({
    required this.exercise,
    required this.durationSeconds,
    required this.originalDurationSeconds,
    required this.category,
    this.repsCount = 0,
  });

  bool get isModified => durationSeconds != originalDurationSeconds;

  String get formattedSubtitle {
    if (repsCount > 0) {
      return 'x$repsCount';
    }
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

/// Edit plan bottom sheet with working ReorderableListView matching KREW theme.
class EditPlanSheet extends StatefulWidget {
  final List<EditableExerciseItem> items;
  final ValueChanged<List<EditableExerciseItem>> onSave;

  const EditPlanSheet({
    super.key,
    required this.items,
    required this.onSave,
  });

  static Future<List<EditableExerciseItem>?> show(
    BuildContext context, {
    required List<EditableExerciseItem> initialItems,
  }) {
    return showModalBottomSheet<List<EditableExerciseItem>>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditPlanSheet(
        items: initialItems,
        onSave: (saved) => Navigator.of(context).pop(saved),
      ),
    );
  }

  @override
  State<EditPlanSheet> createState() => _EditPlanSheetState();
}

class _EditPlanSheetState extends State<EditPlanSheet> {
  late List<EditableExerciseItem> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.items
        .map((i) => EditableExerciseItem(
              exercise: i.exercise,
              durationSeconds: i.durationSeconds,
              originalDurationSeconds: i.originalDurationSeconds,
              category: i.category,
            ))
        .toList();
  }

  void _reset() {
    setState(() {
      for (var item in _items) {
        item.durationSeconds = item.originalDurationSeconds;
      }
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  String _formatDuration(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _replaceItem(int index) async {
    final newExercise = await ReplaceExerciseSheet.show(
      context,
      currentExercise: _items[index].exercise,
    );
    if (newExercise != null && mounted) {
      setState(() {
        _items[index].exercise = newExercise;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sheetBg = context.scaffoldBg;
    final cardBg = context.cardBg;
    final border = context.cardBorder;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.96,
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
              // Header bar (No back button & No horizontal divider as requested)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: Row(
                  children: [
                    Text(
                      'Edit plan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: context.primaryText,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _reset,
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.lime400,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Reorderable ListView for smooth drag-and-drop position reordering
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.transparent,
                  ),
                  child: ReorderableListView.builder(
                    scrollController: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    buildDefaultDragHandles: false,
                    itemCount: _items.length,
                    onReorder: _onReorder,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Container(
                        key: ValueKey('${item.exercise.id}_${item.category}_$index'),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          children: [
                            // Interactive Drag Handle
                            ReorderableDragStartListener(
                              index: index,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedMenu01,
                                  color: context.secondaryText,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 54,
                                height: 54,
                                color: context.secondaryText.withAlpha(20),
                                child: Image.asset(
                                  item.exercise.assetImagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const HugeIcon(
                                    icon: HugeIcons.strokeRoundedDumbbell01,
                                    color: AppColors.lime400,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Title & Stepper
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.exercise.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: context.primaryText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (item.durationSeconds > 5) {
                                            setState(() => item.durationSeconds -= 5);
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(6),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: context.secondaryText.withAlpha(20),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: HugeIcon(
                                            icon: HugeIcons.strokeRoundedRemove01,
                                            size: 14,
                                            color: context.primaryText,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          _formatDuration(item.durationSeconds),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: item.isModified
                                                ? AppColors.lime400
                                                : context.primaryText,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() => item.durationSeconds += 5);
                                        },
                                        borderRadius: BorderRadius.circular(6),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: context.secondaryText.withAlpha(20),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: HugeIcon(
                                            icon: HugeIcons.strokeRoundedAdd01,
                                            size: 14,
                                            color: context.primaryText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Swap Button
                            IconButton(
                              icon: const HugeIcon(
                                icon: HugeIcons.strokeRoundedExchange01,
                                color: AppColors.lime400,
                              ),
                              onPressed: () => _replaceItem(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bottom Cancel & Save bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: sheetBg,
                  border: Border(top: BorderSide(color: border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.primaryText,
                            side: BorderSide(color: border, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lime400,
                            foregroundColor: AppColors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          onPressed: () => widget.onSave(_items),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
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
      },
    );
  }
}
