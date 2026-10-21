import 'package:flutter/material.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/features/body_area_selector/data/svg_body_parser.dart';

String _getSvgFilename(String focusArea) {
  final lower = focusArea.toLowerCase();
  if (lower.contains('full body') || lower.contains('full')) {
    return 'icon_abs.svg';
  }
  if (lower.contains('abs') || lower.contains('waist') || lower.contains('core') || lower.contains('belly') || lower.contains('six pack')) {
    return 'icon_abs.svg';
  }
  if (lower.contains('arm') || lower.contains('bat wings') || lower.contains('biceps') || lower.contains('triceps') || lower.contains('forearm')) {
    return 'icon_arm.svg';
  }
  if (lower.contains('chest') || lower.contains('pectoral')) {
    return 'icon_chest.svg';
  }
  if (lower.contains('leg') || lower.contains('thigh') || lower.contains('calves')) {
    return 'icon_leg.svg';
  }
  if (lower.contains('glute') || lower.contains('butt') || lower.contains('booty') || lower.contains('hip')) {
    return 'icon_glutes.svg';
  }
  if (lower.contains('shoulder')) {
    return 'icon_shoulder.svg';
  }
  if (lower.contains('back') || lower.contains('spine')) {
    return 'icon_back.svg';
  }
  return 'icon_abs.svg';
}

/// Gender-aware SVG muscle part icon widget styled according to application double-theme.
class MusclePartSvgIcon extends StatefulWidget {
  final String focusArea;
  final bool isFemale;
  final double size;
  final bool isSelected;

  const MusclePartSvgIcon({
    super.key,
    required this.focusArea,
    this.isFemale = false,
    this.size = 40.0,
    this.isSelected = false,
  });

  @override
  State<MusclePartSvgIcon> createState() => _MusclePartSvgIconState();
}

class _MusclePartSvgIconState extends State<MusclePartSvgIcon> {
  BodyFigureModel? _model;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSvgModel();
  }

  @override
  void didUpdateWidget(covariant MusclePartSvgIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusArea != widget.focusArea || oldWidget.isFemale != widget.isFemale) {
      _loadSvgModel();
    }
  }

  Future<void> _loadSvgModel() async {
    final filename = _getSvgFilename(widget.focusArea);
    final dir = widget.isFemale ? 'female_parts' : 'male_parts';
    final assetPath = 'assets/svg/$dir/$filename';

    try {
      final model = await BodyFigureModel.loadFromAsset(assetPath);
      if (mounted) {
        setState(() {
          _model = model;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _model == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Icon(
          Icons.fitness_center_rounded,
          size: widget.size * 0.6,
          color: widget.isSelected ? AppColors.lime400 : context.secondaryText,
        ),
      );
    }

    final isDark = context.isDarkMode;
    final inactiveColor = widget.isSelected
        ? (isDark ? const Color(0xFF4A4A3E) : const Color(0xFFB0B0A4))
        : (isDark ? const Color(0xFF2E2E28) : const Color(0xFFD4D4CC));
    final secondaryColor = AppColors.lime300;
    final primaryColor = AppColors.lime400;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _MusclePartPainter(
          model: _model!,
          inactiveColor: inactiveColor,
          secondaryColor: secondaryColor,
          primaryColor: primaryColor,
        ),
      ),
    );
  }
}

class _MusclePartPainter extends CustomPainter {
  final BodyFigureModel model;
  final Color inactiveColor;
  final Color secondaryColor;
  final Color primaryColor;

  _MusclePartPainter({
    required this.model,
    required this.inactiveColor,
    required this.secondaryColor,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final vb = model.viewBoxRect;
    if (size.width <= 0 || size.height <= 0 || vb.width <= 0 || vb.height <= 0) return;

    final scale = (size.width / vb.width) < (size.height / vb.height)
        ? (size.width / vb.width)
        : (size.height / vb.height);

    final dx = (size.width - vb.width * scale) / 2 - vb.left * scale;
    final dy = (size.height - vb.height * scale) / 2 - vb.top * scale;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final paint = Paint()..style = PaintingStyle.fill;

    for (final shape in model.shapes) {
      if (shape.id == 'muscle_primary') {
        paint.color = primaryColor;
      } else if (shape.id == 'muscle_secondary') {
        paint.color = secondaryColor;
      } else {
        paint.color = inactiveColor;
      }

      canvas.drawPath(shape.path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MusclePartPainter oldDelegate) {
    return oldDelegate.model != model ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.primaryColor != primaryColor;
  }
}
