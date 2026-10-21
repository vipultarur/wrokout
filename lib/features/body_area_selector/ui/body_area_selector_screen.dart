import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout/common/widgets/app_button.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/user_profile_provider.dart';
import 'package:workout/features/body_area_selector/data/body_area.dart';
import 'package:workout/features/body_area_selector/data/svg_body_parser.dart';
import 'package:workout/features/body_area_selector/state/body_area_notifier.dart';
import 'package:workout/features/body_area_selector/ui/widgets/body_chips_selector.dart';
import 'package:workout/features/body_area_selector/ui/widgets/body_figure_painter.dart';

/// Screen for selecting body areas to focus on in workout plan generation with double theme support.
class BodyAreaSelectorScreen extends ConsumerStatefulWidget {
  final ValueChanged<Set<BodyArea>>? onContinue;
  final bool showNextButton;
  final String? gender;

  const BodyAreaSelectorScreen({
    super.key,
    this.onContinue,
    this.showNextButton = true,
    this.gender,
  });

  @override
  ConsumerState<BodyAreaSelectorScreen> createState() =>
      _BodyAreaSelectorScreenState();
}

class _BodyAreaSelectorScreenState
    extends ConsumerState<BodyAreaSelectorScreen> {
  String? _loadedGender;
  Future<List<BodyFigureModel>>? _figuresFuture;

  @override
  void initState() {
    super.initState();
    _checkAndUpdateFigures();
  }

  @override
  void didUpdateWidget(covariant BodyAreaSelectorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gender != widget.gender) {
      _checkAndUpdateFigures();
    }
  }

  void _checkAndUpdateFigures() {
    final currentGender = widget.gender ?? ref.read(userProfileProvider).gender ?? 'male';
    if (_figuresFuture == null || _loadedGender != currentGender) {
      _loadedGender = currentGender;
      _figuresFuture = _loadFigures(currentGender);
    }
  }

  Future<List<BodyFigureModel>> _loadFigures(String gender) async {
    final isFemale = gender.toLowerCase() == 'female';
    final frontAsset = isFemale
        ? 'assets/svg/body_front_female.svg'
        : 'assets/svg/body_front.svg';
    final backAsset = isFemale
        ? 'assets/svg/body_back_female.svg'
        : 'assets/svg/body_back.svg';

    return Future.wait([
      BodyFigureModel.loadFromAsset(frontAsset),
      BodyFigureModel.loadFromAsset(backAsset),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final content = Column(
      children: [
        const SizedBox(height: 20),

        // ─── Title ───
        Text(
          'Select the areas you want\nto focus on',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.primaryText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.25,
          ),
        ),

        const SizedBox(height: 20),

        // ─── Scoped Chips Selector ───
        Consumer(
          builder: (context, ref, _) {
            final selectedAreas = ref.watch(bodyAreaSelectionProvider);
            final notifier = ref.read(bodyAreaSelectionProvider.notifier);
            return BodyChipsSelector(
              selectedAreas: selectedAreas,
              onAreaToggle: (area) => notifier.toggleArea(area),
            );
          },
        ),

        const SizedBox(height: 16),

        // ─── Body Figures Side-by-Side ───
        Expanded(
          child: FutureBuilder<List<BodyFigureModel>>(
            future: _figuresFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Text(
                    'Error loading body artwork',
                    style: TextStyle(color: context.secondaryText),
                  ),
                );
              }

              final frontModel = snapshot.data![0];
              final backModel = snapshot.data![1];

              return Consumer(
                builder: (context, ref, _) {
                  final selectedAreas = ref.watch(bodyAreaSelectionProvider);
                  final notifier = ref.read(bodyAreaSelectionProvider.notifier);
                  return Row(
                    children: [
                      Expanded(
                        child: RepaintBoundary(
                          child: BodyFigureWidget(
                            figure: frontModel,
                            selectedAreas: selectedAreas,
                            onMuscleTap: (id) => notifier.toggleMuscle(id),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RepaintBoundary(
                          child: BodyFigureWidget(
                            figure: backModel,
                            selectedAreas: selectedAreas,
                            onMuscleTap: (id) => notifier.toggleMuscle(id),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),

        // ─── Bottom Next Button ───
        if (widget.showNextButton) ...[
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, _) {
              return AppButton(
                label: 'NEXT',
                onPressed: () {
                  if (widget.onContinue != null) {
                    final selectedAreas = ref.read(bodyAreaSelectionProvider);
                    widget.onContinue!(selectedAreas);
                  }
                },
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ],
    );

    if (!widget.showNextButton) {
      return Container(
        color: context.scaffoldBg,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: content,
        ),
      ),
    );
  }
}
