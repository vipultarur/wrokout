import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/theme/app_colors.dart';

enum AppSnackbarType { success, error, warning, info }

/// Standardized snackbar notification helper with type-adaptive styling.
class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    AppSnackbarType type = AppSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color getBgColor() {
      switch (type) {
        case AppSnackbarType.success:
          return AppColors.success;
        case AppSnackbarType.error:
          return AppColors.error;
        case AppSnackbarType.warning:
          return AppColors.warning;
        case AppSnackbarType.info:
          return context.cardBg;
      }
    }

    List<List<dynamic>> getIcon() {
      switch (type) {
        case AppSnackbarType.success:
          return HugeIcons.strokeRoundedCheckmarkCircle01;
        case AppSnackbarType.error:
          return HugeIcons.strokeRoundedAlertCircle;
        case AppSnackbarType.warning:
          return HugeIcons.strokeRoundedAlert01;
        case AppSnackbarType.info:
          return HugeIcons.strokeRoundedInformationCircle;
      }
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            HugeIcon(icon: getIcon(), color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: getBgColor(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: duration,
      ),
    );
  }
}
