import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:workout/core/theme/app_colors.dart';

enum AppLoaderVariant { fullScreen, inline, shimmer }

/// Standardized loading indicators (FullScreen, Inline, Shimmer).
class AppLoader extends StatelessWidget {
  final AppLoaderVariant variant;
  final double size;
  final Color? color;

  const AppLoader({
    super.key,
    this.variant = AppLoaderVariant.inline,
    this.size = 32.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    switch (variant) {
      case AppLoaderVariant.fullScreen:
        return Scaffold(
          backgroundColor: context.scaffoldBg,
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
            ),
          ),
        );
      case AppLoaderVariant.inline:
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
            ),
          ),
        );
      case AppLoaderVariant.shimmer:
        return Shimmer.fromColors(
          baseColor: context.isDarkMode ? AppColors.outerSpace : Colors.grey[300]!,
          highlightColor: context.isDarkMode ? AppColors.midGrey : Colors.grey[100]!,
          child: Container(
            width: double.infinity,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
    }
  }
}
