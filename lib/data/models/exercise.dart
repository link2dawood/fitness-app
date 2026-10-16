enum ExerciseMotion {
  wallPushUp,
  punches,
  sideArmRaise,
  forwardArmSwings,
  elbowsBack,
  crunch9090,
  abdominalCrunch,
  armCircles,
  armRaises,
  adductorStretch,
  armCirclesReverse,
}

enum ExerciseArea {
  chest('Chest'),
  arms('Arms & shoulders'),
  abs('Abs'),
  legs('Legs');

  const ExerciseArea(this.label);
  final String label;
}

class ExerciseDefinition {
  const ExerciseDefinition({
    required this.id,
    required this.name,
    required this.motion,
    required this.area,
    required this.timed,
    required this.target,
    required this.description,
    this.recommended = false,
  });
  final String id;
  final String name;
  final ExerciseMotion motion;
  final ExerciseArea area;
  final bool timed;
  final int target;
  final bool recommended;
  final String description;
  String targetLabel([int? value]) {
    final amount = value ?? target;
    return timed
        ? '${(amount ~/ 60).toString().padLeft(2, '0')}:${(amount % 60).toString().padLeft(2, '0')}'
        : 'x$amount';
  }
}

const exerciseCatalog = <ExerciseDefinition>[
  ExerciseDefinition(
    id: 'wall_push_ups',
    name: 'Wall Push-ups',
    motion: ExerciseMotion.wallPushUp,
    area: ExerciseArea.chest,
    timed: false,
    target: 10,
    recommended: true,
    description:
        'A standing wall-supported pushing movement. The avatar bends and straightens its elbows while keeping its hands against the wall.',
  ),
  ExerciseDefinition(
    id: 'punches',
    name: 'Punches',
    motion: ExerciseMotion.punches,
    area: ExerciseArea.arms,
    timed: true,
    target: 20,
    recommended: true,
    description: 'Alternating forward punches from a standing stance.',
  ),
  ExerciseDefinition(
    id: 'side_arm_raise',
    name: 'Side Arm Raise',
    motion: ExerciseMotion.sideArmRaise,
    area: ExerciseArea.arms,
    timed: true,
    target: 20,
    recommended: true,
    description: 'Both arms lift out to the sides and return to the body.',
  ),
  ExerciseDefinition(
    id: 'forward_arm_swings',
    name: 'Forward Arm Swings',
    motion: ExerciseMotion.forwardArmSwings,
    area: ExerciseArea.arms,
    timed: true,
    target: 20,
    recommended: true,
    description:
        'A side-view demonstration of the arms swinging forward and back.',
  ),
  ExerciseDefinition(
    id: 'elbows_back',
    name: 'Elbows Back',
    motion: ExerciseMotion.elbowsBack,
    area: ExerciseArea.arms,
    timed: true,
    target: 20,
    recommended: true,
    description:
        'With elbows bent, the arms draw back and return in a side-view loop.',
  ),
  ExerciseDefinition(
    id: '90_90_crunch',
    name: '90/90 Crunch',
    motion: ExerciseMotion.crunch9090,
    area: ExerciseArea.abs,
    timed: false,
    target: 10,
    description:
        'The upper body curls toward raised legs, with knees bent in a tabletop position.',
  ),
  ExerciseDefinition(
    id: 'abdominal_crunches',
    name: 'Abdominal Crunches',
    motion: ExerciseMotion.abdominalCrunch,
    area: ExerciseArea.abs,
    timed: false,
    target: 10,
    description:
        'A floor-based upper-body curl with knees bent and feet resting on the floor.',
  ),
  ExerciseDefinition(
    id: 'arm_circles',
    name: 'Arm Circles',
    motion: ExerciseMotion.armCircles,
    area: ExerciseArea.arms,
    timed: false,
    target: 10,
    description:
        'Arms extend to the sides while the hands trace small circles.',
  ),
  ExerciseDefinition(
    id: 'arm_raises',
    name: 'Arm Raises',
    motion: ExerciseMotion.armRaises,
    area: ExerciseArea.arms,
    timed: true,
    target: 20,
    description: 'Both arms lift overhead and lower back toward the sides.',
  ),
  ExerciseDefinition(
    id: 'adductor_stretch_standing',
    name: 'Adductor Stretch in Standing',
    motion: ExerciseMotion.adductorStretch,
    area: ExerciseArea.legs,
    timed: false,
    target: 10,
    description:
        'A wide standing stance shifts from side to side, bending one knee while the other leg stays straighter.',
  ),
  ExerciseDefinition(
    id: 'arm_circles_counterclockwise',
    name: 'Arm Circles Counterclockwise',
    motion: ExerciseMotion.armCirclesReverse,
    area: ExerciseArea.arms,
    timed: true,
    target: 20,
    description: 'The arm-circle demonstration runs in the opposite direction.',
  ),
];

ExerciseDefinition exerciseById(String id) => exerciseCatalog.firstWhere(
  (exercise) => exercise.id == id,
  orElse: () => throw FormatException('Unknown exercise: $id'),
);
