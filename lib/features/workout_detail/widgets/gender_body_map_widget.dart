import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/user_profile_provider.dart';
import 'package:workout/features/body_area_selector/data/svg_body_parser.dart';

/// Gender-aware body SVG highlight widget matching KREW application theme.
class GenderBodyMapWidget extends ConsumerStatefulWidget {
  final List<String> targetMuscleIds;
  final bool isFullBody;
  final double height;

  const GenderBodyMapWidget({
    super.key,
    required this.targetMuscleIds,
    this.isFullBody = false,
    this.height = 240.0,
  });

  @override
  ConsumerState<GenderBodyMapWidget> createState() => _GenderBodyMapWidgetState();
}

class _GenderBodyMapWidgetState extends ConsumerState<GenderBodyMapWidget> {
  BodyFigureModel? _frontModel;
  BodyFigureModel? _backModel;
  bool _isLoading = true;
  String? _loadedGender;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = ref.watch(userProfileProvider);
    final gender = (profile.gender ?? 'male').toLowerCase();
    if (_loadedGender != gender) {
      _loadModels();
    }
  }

  Future<void> _loadModels() async {
    final profile = ref.read(userProfileProvider);
    final gender = (profile.gender ?? 'male').toLowerCase();
    _loadedGender = gender;
    setState(() => _isLoading = true);

    try {
      final isFemale = gender == 'female';
      final frontPath = isFemale
          ? 'assets/svg/body_front_female.svg'
          : 'assets/svg/body_front.svg';
      final backPath = isFemale
          ? 'assets/svg/body_back_female.svg'
          : 'assets/svg/body_back.svg';

      final front = await BodyFigureModel.loadFromAsset(frontPath);
      final back = await BodyFigureModel.loadFromAsset(backPath);

      if (mounted) {
        setState(() {
          _frontModel = front;
          _backModel = back;
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
    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    if (_frontModel == null || _backModel == null) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: HugeIcon(icon: HugeIcons.strokeRoundedUser, size: 48, color: context.secondaryText),
        ),
      );
    }

    final isDark = context.isDarkMode;
    final unselectedColor = isDark ? const Color(0xFF2E2E26) : const Color(0xFFD8D8CC);
    final highlightColor = AppColors.lime400; // Application Electric Lime Brand Color
    final staticColor = isDark ? const Color(0xFF48483E) : const Color(0xFFC2C2B6);

    final highlightedSet = widget.targetMuscleIds.toSet();

    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Anterior (Front) View
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _BodyMapPainter(
                model: _frontModel!,
                highlightedMuscles: highlightedSet,
                isFullBody: widget.isFullBody,
                unselectedColor: unselectedColor,
                highlightColor: highlightColor,
                staticColor: staticColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Posterior (Back) View
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _BodyMapPainter(
                model: _backModel!,
                highlightedMuscles: highlightedSet,
                isFullBody: widget.isFullBody,
                unselectedColor: unselectedColor,
                highlightColor: highlightColor,
                staticColor: staticColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyMapPainter extends CustomPainter {
  final BodyFigureModel model;
  final Set<String> highlightedMuscles;
  final bool isFullBody;
  final Color unselectedColor;
  final Color highlightColor;
  final Color staticColor;

  _BodyMapPainter({
    required this.model,
    required this.highlightedMuscles,
    required this.isFullBody,
    required this.unselectedColor,
    required this.highlightColor,
    required this.staticColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final vb = model.viewBoxRect;
    if (size.width <= 0 || size.height <= 0 || vb.width <= 0 || vb.height <= 0) return;

    final scale = min(size.width / vb.width, size.height / vb.height);
    final dx = (size.width - vb.width * scale) / 2 - vb.left * scale;
    final dy = (size.height - vb.height * scale) / 2 - vb.top * scale;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final paint = Paint()..style = PaintingStyle.fill;

    for (final shape in model.shapes) {
      if (shape.id.startsWith('static_')) {
        paint.color = staticColor;
      } else {
        final isTarget = isFullBody || highlightedMuscles.contains(shape.id);
        paint.color = isTarget ? highlightColor : unselectedColor;
      }

      canvas.drawPath(shape.path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BodyMapPainter oldDelegate) {
    return oldDelegate.model != model ||
        oldDelegate.highlightedMuscles != highlightedMuscles ||
        oldDelegate.isFullBody != isFullBody ||
        oldDelegate.highlightColor != highlightColor;
  }
}
