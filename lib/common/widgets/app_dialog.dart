import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/theme/app_colors.dart';

enum AppDialogType { confirm, info, error }

/// Standardized dialogs with static show helper method matching Step 5 specification.
class AppDialog {
  AppDialog._();

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    AppDialogType type = AppDialogType.confirm,
    String confirmLabel = 'OK',
    String cancelLabel = 'CANCEL',
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    Color getIconColor() {
      switch (type) {
        case AppDialogType.confirm:
          return primaryColor;
        case AppDialogType.info:
          return AppColors.info;
        case AppDialogType.error:
          return AppColors.error;
      }
    }

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: context.cardBorder),
        ),
        title: Row(
          children: [
            HugeIcon(
              icon: type == AppDialogType.error
                  ? HugeIcons.strokeRoundedAlertCircle
                  : type == AppDialogType.info
                      ? HugeIcons.strokeRoundedInformationCircle
                      : HugeIcons.strokeRoundedHelpCircle,
              color: type == AppDialogType.confirm
                  ? (context.isDarkMode ? AppColors.lime400 : AppColors.black)
                  : getIconColor(),
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.primaryText,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: context.secondaryText,
          ),
        ),
        actions: [
          if (type == AppDialogType.confirm)
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                cancelLabel,
                style: TextStyle(color: context.secondaryText),
              ),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: getIconColor(),
              foregroundColor: type == AppDialogType.confirm
                  ? AppColors.black
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              confirmLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
