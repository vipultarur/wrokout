import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/user_profile_provider.dart';

/// Step 7: Body metrics input with double theme support.
class BodyMetricsStep extends ConsumerStatefulWidget {
  const BodyMetricsStep({super.key});

  @override
  ConsumerState<BodyMetricsStep> createState() => _BodyMetricsStepState();
}

class _BodyMetricsStepState extends ConsumerState<BodyMetricsStep> {
  late double _weightKg;
  late double _heightCm;
  bool _useLbs = true;
  bool _useFt = true;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _weightKg = profile.weightKg ?? 75.0;
    _heightCm = profile.heightCm ?? 175.0;
  }

  void _saveMetrics() {
    ref.read(userProfileProvider.notifier).updateBodyMetrics(
          weightKg: _weightKg,
          heightCm: _heightCm,
        );
  }

  @override
  Widget build(BuildContext context) {
    final displayWeightLbs = _weightKg * 2.20462;
    final totalInches = _heightCm / 2.54;
    final feet = totalInches ~/ 12;
    final inches = (totalInches % 12).round();
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Text(
            'Let us know you better',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: context.primaryText,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Let us know you better to help boost your\nworkout results',
            style: TextStyle(
              fontSize: 13,
              color: context.secondaryText,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── 1. WEIGHT SECTION ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Weight',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: context.primaryText,
                        ),
                      ),
                      _buildUnitTogglePill(
                        context,
                        leftLabel: 'kg',
                        rightLabel: 'lbs',
                        isRightSelected: _useLbs,
                        onLeftTap: () => setState(() => _useLbs = false),
                        onRightTap: () => setState(() => _useLbs = true),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: _useLbs
                        ? RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: displayWeightLbs.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: ' lbs',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: context.primaryText,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: _weightKg.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: ' kg',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: context.primaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 12),

                  _useLbs
                      ? _RulerScalePicker(
                          key: const ValueKey('weight_lbs'),
                          minValue: 60.0,
                          maxValue: 400.0,
                          step: 0.1,
                          initialValue: displayWeightLbs,
                          majorStepCount: 10,
                          onValueChanged: (val) {
                            setState(() {
                              _weightKg = val / 2.20462;
                            });
                            _saveMetrics();
                          },
                        )
                      : _RulerScalePicker(
                          key: const ValueKey('weight_kg'),
                          minValue: 30.0,
                          maxValue: 180.0,
                          step: 0.1,
                          initialValue: _weightKg,
                          majorStepCount: 10,
                          onValueChanged: (val) {
                            setState(() {
                              _weightKg = val;
                            });
                            _saveMetrics();
                          },
                        ),

                  const SizedBox(height: 32),

                  // ─── 2. HEIGHT SECTION ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Height',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: context.primaryText,
                        ),
                      ),
                      _buildUnitTogglePill(
                        context,
                        leftLabel: 'cm',
                        rightLabel: 'ft',
                        isRightSelected: _useFt,
                        onLeftTap: () => setState(() => _useFt = false),
                        onRightTap: () => setState(() => _useFt = true),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: _useFt
                        ? RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$feet',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ft ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: context.primaryText,
                                  ),
                                ),
                                TextSpan(
                                  text: '$inches',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: ' in',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: context.primaryText,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: _heightCm.round().toString(),
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: ' cm',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: context.primaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 12),

                  _useFt
                      ? _RulerScalePicker(
                          key: const ValueKey('height_ft'),
                          minValue: 36.0,
                          maxValue: 96.0,
                          step: 1.0,
                          initialValue: totalInches,
                          majorStepCount: 12,
                          isFeetInchesMode: true,
                          onValueChanged: (val) {
                            setState(() {
                              _heightCm = val * 2.54;
                            });
                            _saveMetrics();
                          },
                        )
                      : _RulerScalePicker(
                          key: const ValueKey('height_cm'),
                          minValue: 100.0,
                          maxValue: 230.0,
                          step: 1.0,
                          initialValue: _heightCm,
                          majorStepCount: 10,
                          onValueChanged: (val) {
                            setState(() {
                              _heightCm = val;
                            });
                            _saveMetrics();
                          },
                        ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitTogglePill(
    BuildContext context, {
    required String leftLabel,
    required String rightLabel,
    required bool isRightSelected,
    required VoidCallback onLeftTap,
    required VoidCallback onRightTap,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onLeftTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: !isRightSelected ? primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                leftLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: !isRightSelected
                      ? AppColors.raisinBlack
                      : context.secondaryText,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onRightTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isRightSelected ? primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                rightLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isRightSelected
                      ? AppColors.raisinBlack
                      : context.secondaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RulerScalePicker extends StatefulWidget {
  final double minValue;
  final double maxValue;
  final double step;
  final double initialValue;
  final int majorStepCount;
  final bool isFeetInchesMode;
  final ValueChanged<double> onValueChanged;

  const _RulerScalePicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.step,
    required this.initialValue,
    required this.majorStepCount,
    this.isFeetInchesMode = false,
    required this.onValueChanged,
  });

  @override
  State<_RulerScalePicker> createState() => _RulerScalePickerState();
}

class _RulerScalePickerState extends State<_RulerScalePicker> {
  late ScrollController _scrollController;
  static const double _tickWidth = 10.0;

  @override
  void initState() {
    super.initState();
    final clampedInitial =
        widget.initialValue.clamp(widget.minValue, widget.maxValue);
    final initialStepIndex =
        (clampedInitial - widget.minValue) / widget.step;
    final initialOffset = initialStepIndex * _tickWidth;

    _scrollController = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalSteps =
        ((widget.maxValue - widget.minValue) / widget.step).round() + 1;
    final screenWidth = MediaQuery.of(context).size.width;
    final padSide = screenWidth / 2 - _tickWidth / 2;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo is ScrollUpdateNotification ||
                  scrollInfo is ScrollEndNotification) {
                final offset = _scrollController.offset;
                final stepIndex = (offset / _tickWidth).round();
                final calculatedValue = (widget.minValue + stepIndex * widget.step)
                    .clamp(widget.minValue, widget.maxValue);
                widget.onValueChanged(calculatedValue);
              }
              return true;
            },
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: padSide),
              itemCount: totalSteps,
              itemBuilder: (context, index) {
                final isMajor = index % widget.majorStepCount == 0;
                final currentValue = widget.minValue + index * widget.step;

                String? label;
                if (isMajor) {
                  if (widget.isFeetInchesMode) {
                    label = '${(currentValue / 12).floor()}';
                  } else {
                    label = currentValue.round().toString();
                  }
                }

                return SizedBox(
                  width: _tickWidth,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 24,
                        child: label != null
                            ? Center(
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: context.secondaryText,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: isMajor ? 2.0 : 1.0,
                        height: isMajor ? 32 : 18,
                        color: isMajor
                            ? context.primaryText.withAlpha(150)
                            : context.cardBorder,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: 34,
            child: Container(
              width: 2.5,
              height: 42,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withAlpha(100),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
