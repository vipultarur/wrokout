import 'package:flutter/material.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/features/body_area_selector/data/body_area.dart';

/// Pill chips selector widget arranged in centered rows with animated color changes.
class BodyChipsSelector extends StatelessWidget {
  final Set<BodyArea> selectedAreas;
  final ValueChanged<BodyArea> onAreaToggle;

  const BodyChipsSelector({
    super.key,
    required this.selectedAreas,
    required this.onAreaToggle,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: BodyArea.values.map((area) {
        final isSelected = selectedAreas.contains(area);
        final bgColor = isSelected
            ? primaryColor
            : (context.isDarkMode ? AppColors.outerSpace : Colors.white);
        final textColor = isSelected
            ? AppColors.raisinBlack
            : context.primaryText;

        return GestureDetector(
          onTap: () => onAreaToggle(area),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? primaryColor : context.cardBorder,
              ),
            ),
            child: Text(
              area.label,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
