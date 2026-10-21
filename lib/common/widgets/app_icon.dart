import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Helper widget to render HugeIcons seamlessly across the application.
class AppIcon extends StatelessWidget {
  final dynamic icon;
  final Color? color;
  final double? size;

  const AppIcon({
    super.key,
    required this.icon,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (icon == null) return const SizedBox.shrink();

    final effectiveColor = color ?? IconTheme.of(context).color ?? Colors.black;
    final effectiveSize = size ?? IconTheme.of(context).size ?? 24.0;

    if (icon is List<List<dynamic>>) {
      return HugeIcon(
        icon: icon as List<List<dynamic>>,
        color: effectiveColor,
        size: effectiveSize,
      );
    } else if (icon is IconData) {
      return Icon(
        icon as IconData,
        color: effectiveColor,
        size: effectiveSize,
      );
    } else if (icon is Widget) {
      return icon as Widget;
    }

    return const SizedBox.shrink();
  }
}
