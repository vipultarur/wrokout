import 'package:flutter/material.dart';
import 'package:workout/core/constants/app_decorations.dart';
import 'package:workout/core/theme/app_colors.dart';

/// Reusable linear progress indicator with rounded borders and dynamic theme colors.
class AppProgressBar extends StatelessWidget {
  final double value;
  final double minHeight;

  const AppProgressBar({
    super.key,
    required this.value,
    this.minHeight = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return ClipRRect(
      borderRadius: AppDecorations.borderRadiusSm,
      child: LinearProgressIndicator(
        value: value,
        minHeight: minHeight,
        backgroundColor: context.cardBorder,
        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
      ),
    );
  }
}
