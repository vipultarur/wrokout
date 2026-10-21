import 'package:flutter/material.dart';
import 'package:workout/core/theme/app_colors.dart';

enum AppImageVariant { asset, avatar }

/// Standardized image loader widget handling assets and avatars with error fallbacks.
class AppImage extends StatelessWidget {
  final String path;
  final AppImageVariant variant;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const AppImage({
    super.key,
    required this.path,
    this.variant = AppImageVariant.asset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (variant == AppImageVariant.avatar) {
      return Container(
        width: width ?? 48,
        height: height ?? 48,
        decoration: BoxDecoration(
          color: primaryColor.withAlpha(40),
          shape: BoxShape.circle,
          border: Border.all(color: primaryColor, width: 1.5),
        ),
        child: ClipOval(
          child: Image.asset(
            path,
            width: width ?? 48,
            height: height ?? 48,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Icon(Icons.person_rounded, color: primaryColor, size: (width ?? 48) * 0.5),
            ),
          ),
        ),
      );
    }

    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return placeholder ??
            Container(
              width: width,
              height: height,
              color: context.cardBg,
              child: Center(
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: primaryColor,
                  size: (height ?? 48) * 0.4,
                ),
              ),
            );
      },
    );
  }
}
