import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout/data/providers/user_profile_provider.dart';
import 'package:workout/features/body_area_selector/data/body_area.dart';
import 'package:workout/features/body_area_selector/state/body_area_notifier.dart';
import 'package:workout/features/body_area_selector/ui/body_area_selector_screen.dart';

/// Step 6: Interactive Body Area Selector step matching reference design.
class FocusAreaStep extends ConsumerWidget {
  const FocusAreaStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Synchronize body area selection state to userProfileProvider
    ref.listen<Set<BodyArea>>(bodyAreaSelectionProvider, (previous, next) {
      final labels = next.map((a) => a.label).toList();
      ref.read(userProfileProvider.notifier).updateFocusAreas(labels);
    });

    return const BodyAreaSelectorScreen(showNextButton: false);
  }
}
