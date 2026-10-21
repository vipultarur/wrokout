import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/common/widgets/app_button.dart';
import 'package:workout/common/widgets/app_icon.dart';
import 'package:workout/core/theme/app_colors.dart';

/// Standardized empty state display widget matching Step 5 specification.
class AppEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final dynamic icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = HugeIcons.strokeRoundedFolder01,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: AppIcon(icon: icon, size: 56, color: primaryColor),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.secondaryText,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  height: 48,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
