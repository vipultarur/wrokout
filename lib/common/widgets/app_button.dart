import 'package:flutter/material.dart';
import 'package:workout/common/widgets/app_icon.dart';
import 'package:workout/core/constants/app_decorations.dart';
import 'package:workout/core/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outlined, danger, icon }

/// Standardized high-performance action button supporting multiple variants.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final dynamic icon;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final bool isLoading;
  final bool isDisabled;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.height = 56.0,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w700,
    this.letterSpacing = 1.0,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color getBgColor() {
      if (isDisabled) return theme.disabledColor;
      switch (variant) {
        case AppButtonVariant.primary:
          return theme.colorScheme.primary;
        case AppButtonVariant.secondary:
          return theme.colorScheme.secondary;
        case AppButtonVariant.outlined:
          return Colors.transparent;
        case AppButtonVariant.danger:
          return theme.colorScheme.error;
        case AppButtonVariant.icon:
          return theme.colorScheme.surface;
      }
    }

    Color getFgColor() {
      if (isDisabled) return theme.colorScheme.onSurface.withAlpha(100);
      switch (variant) {
        case AppButtonVariant.primary:
          return AppColors.black;
        case AppButtonVariant.secondary:
          return AppColors.black;
        case AppButtonVariant.outlined:
          return context.isDarkMode ? AppColors.lime400 : AppColors.black;
        case AppButtonVariant.danger:
          return theme.colorScheme.onError;
        case AppButtonVariant.icon:
          return theme.colorScheme.onSurface;
      }
    }

    final effectiveOnPressed = (isLoading || isDisabled) ? null : onPressed;

    Widget buttonContent = isLoading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(getFgColor()),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                AppIcon(icon: icon, size: 20, color: getFgColor()),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  letterSpacing: letterSpacing,
                  color: getFgColor(),
                ),
              ),
            ],
          );

    if (variant == AppButtonVariant.outlined) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: getFgColor(), width: 1.5),
            shape: const RoundedRectangleBorder(
              borderRadius: AppDecorations.borderRadiusLg,
            ),
          ),
          child: buttonContent,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: getBgColor(),
          foregroundColor: getFgColor(),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDecorations.borderRadiusLg,
          ),
        ),
        child: buttonContent,
      ),
    );
  }
}
