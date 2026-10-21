import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/constants/app_decorations.dart';
import 'package:workout/core/constants/app_spacing.dart';
import 'package:workout/core/theme/app_colors.dart';

/// Standardized selectable card widget with smooth selection animations and theme support.
class AppSelectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? iconEmoji;
  final Widget? customLeading;
  final bool isSelected;
  final VoidCallback onTap;
  final EdgeInsets padding;

  const AppSelectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.iconEmoji,
    this.customLeading,
    required this.isSelected,
    required this.onTap,
    this.padding = AppSpacing.paddingAllLg,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withAlpha(38) : context.cardBg,
          borderRadius: AppDecorations.borderRadiusLg,
          border: Border.all(
            color: isSelected ? primaryColor : context.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (iconEmoji != null) ...[
              Text(
                iconEmoji!,
                style: const TextStyle(fontSize: 28),
              ),
              AppSpacing.w16,
            ] else if (customLeading != null) ...[
              customLeading!,
              AppSpacing.w16,
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.primaryText,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    AppSpacing.h4,
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.secondaryText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AppSpacing.w12,
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : context.cardBorder,
                  width: 2,
                ),
                color: isSelected ? primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? const HugeIcon(
                      icon: HugeIcons.strokeRoundedTick01,
                      size: 16,
                      color: AppColors.raisinBlack,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
