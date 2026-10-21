import 'dart:math';
import 'package:flutter/material.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/features/body_area_selector/data/body_area.dart';
import 'package:workout/features/body_area_selector/data/svg_body_parser.dart';

/// Single interactive body figure (front or back view) rendered on custom canvas.
class BodyFigureWidget extends StatefulWidget {
  final BodyFigureModel figure;
  final Set<BodyArea> selectedAreas;
  final ValueChanged<String> onMuscleTap;

  const BodyFigureWidget({
    super.key,
    required this.figure,
    required this.selectedAreas,
    required this.onMuscleTap,
  });

  @override
  State<BodyFigureWidget> createState() => _BodyFigureWidgetState();
}

class _BodyFigureWidgetState extends State<BodyFigureWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Set<BodyArea> _prevSelectedAreas = {};
  Set<BodyArea> _currSelectedAreas = {};

  @override
  void initState() {
    super.initState();
    _currSelectedAreas = Set.from(widget.selectedAreas);
    _prevSelectedAreas = Set.from(widget.selectedAreas);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didUpdateWidget(covariant BodyFigureWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedAreas != widget.selectedAreas) {
      _prevSelectedAreas = Set.from(_currSelectedAreas);
      _currSelectedAreas = Set.from(widget.selectedAreas);
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTap(TapUpDetails details, Size widgetSize) {
    final vb = widget.figure.viewBoxRect;
    if (widgetSize.width <= 0 || widgetSize.height <= 0 || vb.width <= 0 || vb.height <= 0) return;

    final scale = min(widgetSize.width / vb.width, widgetSize.height / vb.height);
    final dx = (widgetSize.width - vb.width * scale) / 2 - vb.left * scale;
    final dy = (widgetSize.height - vb.height * scale) / 2 - vb.top * scale;

    final svgX = (details.localPosition.dx - dx) / scale;
    final svgY = (details.localPosition.dy - dy) / scale;
    final touchPoint = Offset(svgX, svgY);

    // 1. Direct path contains test
    for (final shape in widget.figure.shapes) {
      if (shape.path.contains(touchPoint)) {
        if (shape.id.startsWith('static_')) {
          return;
        }
        widget.onMuscleTap(shape.id);
        return;
      }
    }

    // 2. Static shape proximity check
    for (final shape in widget.figure.shapes) {
      if (shape.id.startsWith('static_')) {
        final bounds = shape.path.getBounds();
        if (bounds.inflate(4).contains(touchPoint)) {
          return;
        }
      }
    }

    // 3. Precision distance fallback
    String? hitId;
    double minDistance = double.infinity;
    for (final shape in widget.figure.shapes) {
      if (shape.id.startsWith('static_')) continue;
      final bounds = shape.path.getBounds();
      if (bounds.inflate(4).contains(touchPoint)) {
        final center = bounds.center;
        final dist = (center - touchPoint).distance;
        if (dist < minDistance) {
          minDistance = dist;
          hitId = shape.id;
        }
      }
    }

    if (hitId != null) {
      widget.onMuscleTap(hitId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final unselectedColor = isDark ? const Color(0xFF2E2E26) : const Color(0xFFD8D8CC);
    final selectedColor = AppColors.lime400;
    final staticColor = isDark ? const Color(0xFF48483E) : const Color(0xFFC2C2B6);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => _handleTap(details, size),
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return RepaintBoundary(
                child: CustomPaint(
                  size: size,
                  painter: _BodyFigurePainter(
                    figure: widget.figure,
                    prevSelected: _prevSelectedAreas,
                    currSelected: _currSelectedAreas,
                    progress: _animController.value,
                    unselectedColor: unselectedColor,
                    selectedColor: selectedColor,
                    staticColor: staticColor,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _BodyFigurePainter extends CustomPainter {
  final BodyFigureModel figure;
  final Set<BodyArea> prevSelected;
  final Set<BodyArea> currSelected;
  final double progress;
  final Color unselectedColor;
  final Color selectedColor;
  final Color staticColor;

  _BodyFigurePainter({
    required this.figure,
    required this.prevSelected,
    required this.currSelected,
    required this.progress,
    required this.unselectedColor,
    required this.selectedColor,
    required this.staticColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final vb = figure.viewBoxRect;
    if (size.width <= 0 || size.height <= 0 || vb.width <= 0 || vb.height <= 0) return;

    final scale = min(size.width / vb.width, size.height / vb.height);
    final dx = (size.width - vb.width * scale) / 2 - vb.left * scale;
    final dy = (size.height - vb.height * scale) / 2 - vb.top * scale;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final paint = Paint()..style = PaintingStyle.fill;

    for (final shape in figure.shapes) {
      if (shape.id.startsWith('static_')) {
        paint.color = staticColor;
      } else {
        final area = BodyArea.fromMuscleId(shape.id);
        final wasSelected = area != null && prevSelected.contains(area);
        final isSelected = area != null && currSelected.contains(area);

        final fromColor = wasSelected ? selectedColor : unselectedColor;
        final toColor = isSelected ? selectedColor : unselectedColor;

        paint.color = Color.lerp(fromColor, toColor, progress) ?? toColor;
      }

      canvas.drawPath(shape.path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BodyFigurePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.currSelected != currSelected ||
        oldDelegate.prevSelected != prevSelected ||
        oldDelegate.selectedColor != selectedColor;
  }
}
