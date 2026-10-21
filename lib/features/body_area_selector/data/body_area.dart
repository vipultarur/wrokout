/// Body areas available for selection in the workout app.
enum BodyArea {
  back('Back'),
  shoulder('Shoulder'),
  arm('Arm'),
  chest('Chest'),
  abs('Abs'),
  butt('Butt'),
  leg('Leg'),
  fullBody('Full Body');

  final String label;
  const BodyArea(this.label);

  /// All individual focusable target body areas (excluding Full Body).
  static List<BodyArea> get individualAreas => const [
        BodyArea.back,
        BodyArea.shoulder,
        BodyArea.arm,
        BodyArea.chest,
        BodyArea.abs,
        BodyArea.butt,
        BodyArea.leg,
      ];

  /// List of muscle shape IDs mapped to this area.
  List<String> get muscleIds {
    switch (this) {
      case BodyArea.back:
        return const ['traps_back', 'lats_left', 'lats_right', 'lower_back'];
      case BodyArea.shoulder:
        return const [
          'shoulder_left',
          'shoulder_right',
          'rear_delt_left',
          'rear_delt_right',
        ];
      case BodyArea.arm:
        return const [
          'biceps_left',
          'biceps_right',
          'triceps_left',
          'triceps_right',
          'forearm_front_left',
          'forearm_front_right',
          'forearm_back_left',
          'forearm_back_right',
        ];
      case BodyArea.chest:
        return const ['chest_left', 'chest_right'];
      case BodyArea.abs:
        return const [
          'abs_1',
          'abs_2',
          'abs_3',
          'abs_4',
          'abs_5',
          'abs_6',
          'oblique_left',
          'oblique_right',
        ];
      case BodyArea.butt:
        return const ['glute_left', 'glute_right'];
      case BodyArea.leg:
        return const [
          'quad_left',
          'quad_right',
          'hamstring_left',
          'hamstring_right',
          'calf_front_left',
          'calf_front_right',
          'calf_back_left',
          'calf_back_right',
        ];
      case BodyArea.fullBody:
        return const [];
    }
  }

  /// Reverse lookup from muscleId to BodyArea.
  static BodyArea? fromMuscleId(String muscleId) {
    if (muscleId.startsWith('static_')) return null;
    for (final area in individualAreas) {
      if (area.muscleIds.contains(muscleId)) {
        return area;
      }
    }
    return null;
  }
}
