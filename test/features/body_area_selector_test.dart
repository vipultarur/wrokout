import 'package:flutter_test/flutter_test.dart';
import 'package:workout/features/body_area_selector/data/body_area.dart';
import 'package:workout/features/body_area_selector/state/body_area_notifier.dart';

void main() {
  group('BodyArea model tests', () {
    test('Area to muscle mapping contains correct IDs', () {
      expect(BodyArea.chest.muscleIds, containsAll(['chest_left', 'chest_right']));
      expect(
          BodyArea.abs.muscleIds,
          containsAll([
            'abs_1',
            'abs_2',
            'abs_3',
            'abs_4',
            'abs_5',
            'abs_6',
            'oblique_left',
            'oblique_right',
          ]));
      expect(BodyArea.butt.muscleIds, containsAll(['glute_left', 'glute_right']));
    });

    test('Reverse lookup converts muscle ID to BodyArea', () {
      expect(BodyArea.fromMuscleId('abs_3'), equals(BodyArea.abs));
      expect(BodyArea.fromMuscleId('chest_left'), equals(BodyArea.chest));
      expect(BodyArea.fromMuscleId('glute_right'), equals(BodyArea.butt));
      expect(BodyArea.fromMuscleId('static_head'), isNull);
      expect(BodyArea.fromMuscleId('static_feet_left'), isNull);
    });
  });

  group('BodyAreaNotifier behavior rules tests', () {
    test('Rule 1 & 2: Toggling chip or muscle updates selected areas', () {
      final notifier = BodyAreaNotifier({});
      notifier.toggleArea(BodyArea.chest);
      expect(notifier.state, contains(BodyArea.chest));

      notifier.toggleMuscle('abs_1');
      expect(notifier.state, containsAll([BodyArea.chest, BodyArea.abs]));
    });

    test('Rule 4: Full Body selects all areas, and tapping again clears everything', () {
      final notifier = BodyAreaNotifier({});
      notifier.toggleArea(BodyArea.fullBody);

      expect(notifier.state.length, equals(BodyArea.values.length));
      expect(notifier.state, containsAll(BodyArea.values));

      notifier.toggleArea(BodyArea.fullBody);
      expect(notifier.state, isEmpty);
    });

    test('Rule 5: Turning off any single area turns off Full Body automatically', () {
      final notifier = BodyAreaNotifier({});
      notifier.toggleArea(BodyArea.fullBody);
      expect(notifier.state, contains(BodyArea.fullBody));

      notifier.toggleArea(BodyArea.chest);
      expect(notifier.state, isNot(contains(BodyArea.chest)));
      expect(notifier.state, isNot(contains(BodyArea.fullBody)));
      expect(notifier.state.length, equals(6)); // 6 remaining individual areas
    });

    test('Rule 6: Manually selecting every individual area turns on Full Body automatically', () {
      final notifier = BodyAreaNotifier({});

      for (final area in BodyArea.individualAreas) {
        expect(notifier.state, isNot(contains(BodyArea.fullBody)));
        notifier.toggleArea(area);
      }

      expect(notifier.state, contains(BodyArea.fullBody));
      expect(notifier.state.length, equals(BodyArea.values.length));
    });

    test('Rule 8: Static shapes are not selectable', () {
      final notifier = BodyAreaNotifier({});
      notifier.toggleMuscle('static_head');
      expect(notifier.state, isEmpty);
    });
  });
}
