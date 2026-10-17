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
  armScissors,
  altVUp,
  armCirclesClockwise,
  alternatingHooks,
  armCurlsCrunchLeft,
  armCurlsCrunchRight,
  anteriorShoulderStretch,
  arnoldDumbbellPress,
  alternatingDumbbellPress,
  alternateHammerCurl,
  armSwingsLateralSteps,
  bicycleCrunches,
  birdDog,
  bridge,
  burpees,
  backwardLungeKickRight,
  backwardLungeKickLeft,
  buttBridge,
  boxPushUps,
  bulgarianSplitSquatLeft,
  bottomLegLiftRight,
  bottomLegLiftLeft,
  bulgarianSplitSquatRight,
  backwardLunge,
  backwardArmSwings,
  buttKicks,
  bentLegTwist,
  birdDogLeft,
  birdDogRight,
  bentOverRow,
  backBowPulls,
  backwardLungeTimed,
  buttBridgeTimed,
  bowPose,
  bentOverDumbbellRowsLeft,
  bentOverDumbbellRowsRight,
  backArches,
}

enum ExerciseArea {
  chest('Chest'),
  arms('Arms & shoulders'),
  abs('Abs'),
  legs('Legs'),
  fullBody('Full body');

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
  ExerciseDefinition(
    id: 'arm_scissors',
    name: 'Arm Scissors',
    motion: ExerciseMotion.armScissors,
    area: ExerciseArea.arms,
    timed: true,
    target: 20,
    description: 'Open the arms and cross them in front of the chest.',
  ),
  ExerciseDefinition(
    id: 'alt_v_up',
    name: 'Alt V-up',
    motion: ExerciseMotion.altVUp,
    area: ExerciseArea.abs,
    timed: false,
    target: 10,
    description: 'Lift the torso and reach toward alternating raised legs.',
  ),
  ExerciseDefinition(
    id: 'arm_circles_clockwise',
    name: 'Arm Circles Clockwise',
    motion: ExerciseMotion.armCirclesClockwise,
    area: ExerciseArea.arms,
    timed: true,
    target: 20,
    description: 'Trace small clockwise circles with extended arms.',
  ),
  ExerciseDefinition(
    id: 'alternating_hooks',
    name: 'Alternating Hooks',
    motion: ExerciseMotion.alternatingHooks,
    area: ExerciseArea.arms,
    timed: true,
    target: 20,
    description: 'Alternate bent-arm hooks across the body.',
  ),
  ExerciseDefinition(
    id: 'arm_curls_crunch_left',
    name: 'Arm Curls Crunch Left',
    motion: ExerciseMotion.armCurlsCrunchLeft,
    area: ExerciseArea.abs,
    timed: false,
    target: 10,
    description:
        'Curl the upper body toward the left hip from a side-lying position.',
  ),
  ExerciseDefinition(
    id: 'arm_curls_crunch_right',
    name: 'Arm Curls Crunch Right',
    motion: ExerciseMotion.armCurlsCrunchRight,
    area: ExerciseArea.abs,
    timed: false,
    target: 10,
    description:
        'Curl the upper body toward the right hip from a side-lying position.',
  ),
  ExerciseDefinition(
    id: 'anterior_shoulder_stretch',
    name: 'Anterior Shoulder Stretch',
    motion: ExerciseMotion.anteriorShoulderStretch,
    area: ExerciseArea.arms,
    timed: true,
    target: 20,
    description:
        'Sit with bent knees and hands behind the body to gently open the shoulders.',
  ),
  ExerciseDefinition(
    id: 'arnold_dumbbell_press',
    name: 'Arnold Dumbbell Press',
    motion: ExerciseMotion.arnoldDumbbellPress,
    area: ExerciseArea.arms,
    timed: false,
    target: 10,
    description:
        'Rotate the forearms outward and press both dumbbells overhead. Requires dumbbells.',
  ),
  ExerciseDefinition(
    id: 'alternating_dumbbell_shoulder_press',
    name: 'Alternating Dumbbell Shoulder Press',
    motion: ExerciseMotion.alternatingDumbbellPress,
    area: ExerciseArea.arms,
    timed: false,
    target: 10,
    description: 'Press one dumbbell overhead at a time. Requires dumbbells.',
  ),
  ExerciseDefinition(
    id: 'alternate_hammer_curl',
    name: 'Alternate Hammer Curl',
    motion: ExerciseMotion.alternateHammerCurl,
    area: ExerciseArea.arms,
    timed: false,
    target: 10,
    description:
        'Alternate neutral-grip curls with elbows beside the torso. Requires dumbbells.',
  ),
  ExerciseDefinition(
    id: 'arm_swings_lateral_steps',
    name: 'Arm Swings with Lateral Steps',
    motion: ExerciseMotion.armSwingsLateralSteps,
    area: ExerciseArea.fullBody,
    timed: true,
    target: 20,
    description: 'Step sideways while opening and crossing the arms.',
  ),
  ExerciseDefinition(
    id: 'bicycle_crunches',
    name: 'Bicycle Crunches',
    motion: ExerciseMotion.bicycleCrunches,
    area: ExerciseArea.abs,
    timed: false,
    target: 10,
    description:
        'Alternate bent and extended legs while curling the opposite shoulder toward the raised knee.',
  ),
  ExerciseDefinition(
    id: 'bird_dog',
    name: 'Bird Dog',
    motion: ExerciseMotion.birdDog,
    area: ExerciseArea.fullBody,
    timed: false,
    target: 10,
    description:
        'From hands and knees, extend the opposite arm and leg, return, and alternate.',
  ),
  ExerciseDefinition(
    id: 'bridge',
    name: 'Bridge',
    motion: ExerciseMotion.bridge,
    area: ExerciseArea.legs,
    timed: true,
    target: 20,
    description:
        'Lift and lower the hips with shoulders and feet supported on the floor.',
  ),
  ExerciseDefinition(
    id: 'burpees',
    name: 'Burpees',
    motion: ExerciseMotion.burpees,
    area: ExerciseArea.fullBody,
    timed: false,
    target: 10,
    description: 'Squat, extend into a plank, return to a squat, and jump.',
  ),
  ExerciseDefinition(
    id: 'backward_lunge_front_kick_right',
    name: 'Backward Lunge with Front Kick Right',
    motion: ExerciseMotion.backwardLungeKickRight,
    area: ExerciseArea.legs,
    timed: false,
    target: 10,
    description:
        'Step the right leg back into a lunge, return, and kick the right foot forward.',
  ),
  ExerciseDefinition(
    id: 'backward_lunge_front_kick_left',
    name: 'Backward Lunge with Front Kick Left',
    motion: ExerciseMotion.backwardLungeKickLeft,
    area: ExerciseArea.legs,
    timed: false,
    target: 10,
    description:
        'Step the left leg back into a lunge, return, and kick forward.',
  ),
  ExerciseDefinition(
    id: 'butt_bridge',
    name: 'Butt Bridge',
    motion: ExerciseMotion.buttBridge,
    area: ExerciseArea.legs,
    timed: false,
    target: 10,
    description:
        'Raise and lower the hips with shoulders and feet supported on the floor.',
  ),
  ExerciseDefinition(
    id: 'box_push_ups',
    name: 'Box Push-ups',
    motion: ExerciseMotion.boxPushUps,
    area: ExerciseArea.chest,
    timed: false,
    target: 10,
    description:
        'From hands and knees, bend and straighten the elbows while keeping the hips over the knees.',
  ),
  ExerciseDefinition(
    id: 'bulgarian_split_squat_left',
    name: 'Bulgarian Split Squat Left',
    motion: ExerciseMotion.bulgarianSplitSquatLeft,
    area: ExerciseArea.legs,
    timed: false,
    target: 10,
    description:
        'With the rear foot on a stable bench, bend and straighten the left supporting leg. Requires a bench.',
  ),
  ExerciseDefinition(
    id: 'bottom_leg_lift_right',
    name: 'Bottom Leg Lift Right',
    motion: ExerciseMotion.bottomLegLiftRight,
    area: ExerciseArea.legs,
    timed: false,
    target: 10,
    description:
        'Lie on the side and raise the straight bottom right leg while the upper foot supports the body.',
  ),
  ExerciseDefinition(
    id: 'bottom_leg_lift_left',
    name: 'Bottom Leg Lift Left',
    motion: ExerciseMotion.bottomLegLiftLeft,
    area: ExerciseArea.legs,
    timed: false,
    target: 10,
    description:
        'Lie on the side and raise the straight bottom left leg while the upper foot supports the body.',
  ),
  ExerciseDefinition(
    id: 'bulgarian_split_squat_right',
    name: 'Bulgarian Split Squat Right',
    motion: ExerciseMotion.bulgarianSplitSquatRight,
    area: ExerciseArea.legs,
    timed: false,
    target: 10,
    description:
        'With the rear foot on a stable bench, bend and straighten the right supporting leg. Requires a bench.',
  ),
  ExerciseDefinition(
    id: 'backward_lunge',
    name: 'Backward Lunge',
    motion: ExerciseMotion.backwardLunge,
    area: ExerciseArea.legs,
    timed: false,
    target: 10,
    description:
        'Alternate stepping backward, lowering into a lunge, and returning to standing.',
  ),
  ExerciseDefinition(
    id: 'backward_arm_swings',
    name: 'Backward Arm Swings',
    motion: ExerciseMotion.backwardArmSwings,
    area: ExerciseArea.arms,
    timed: true,
    target: 20,
    description: 'Circle both arms backward from the shoulders.',
  ),
  ExerciseDefinition(
    id: 'butt_kicks',
    name: 'Butt Kicks',
    motion: ExerciseMotion.buttKicks,
    area: ExerciseArea.legs,
    timed: true,
    target: 20,
    description: 'Alternate lifting the heels toward the back of the hips.',
  ),
  ExerciseDefinition(
    id: 'bent_leg_twist',
    name: 'Bent Leg Twist',
    motion: ExerciseMotion.bentLegTwist,
    area: ExerciseArea.abs,
    timed: false,
    target: 10,
    description:
        'Lie on the back with arms open and gently rotate bent knees from side to side.',
  ),
  ExerciseDefinition(
    id: 'bird_dog_left',
    name: 'Bird Dog Left',
    motion: ExerciseMotion.birdDogLeft,
    area: ExerciseArea.fullBody,
    timed: false,
    target: 10,
    description:
        'From hands and knees, extend the left leg and right arm, then draw them back in.',
  ),
  ExerciseDefinition(
    id: 'bird_dog_right',
    name: 'Bird Dog Right',
    motion: ExerciseMotion.birdDogRight,
    area: ExerciseArea.fullBody,
    timed: false,
    target: 10,
    description:
        'From hands and knees, extend the right leg and left arm, then draw them back in.',
  ),
  ExerciseDefinition(
    id: 'bent_over_row',
    name: 'Bent Over Row',
    motion: ExerciseMotion.bentOverRow,
    area: ExerciseArea.arms,
    timed: false,
    target: 10,
    description:
        'Hinge at the hips and pull both dumbbells toward the waist. Requires dumbbells.',
  ),
  ExerciseDefinition(
    id: 'back_bow_pulls',
    name: 'Back Bow Pulls',
    motion: ExerciseMotion.backBowPulls,
    area: ExerciseArea.fullBody,
    timed: false,
    target: 10,
    description:
        'Lie face down, lift the chest slightly, and draw bent elbows back toward the ribs.',
  ),
  ExerciseDefinition(
    id: 'backward_lunge_timed',
    name: 'Backward Lunge (Timed)',
    motion: ExerciseMotion.backwardLungeTimed,
    area: ExerciseArea.legs,
    timed: true,
    target: 20,
    description: 'A timed version of alternating backward lunges.',
  ),
  ExerciseDefinition(
    id: 'butt_bridge_timed',
    name: 'Butt Bridge (Timed)',
    motion: ExerciseMotion.buttBridgeTimed,
    area: ExerciseArea.legs,
    timed: true,
    target: 20,
    description: 'A timed version of the floor-supported hip bridge.',
  ),
  ExerciseDefinition(
    id: 'bow_pose',
    name: 'Bow Pose',
    motion: ExerciseMotion.bowPose,
    area: ExerciseArea.fullBody,
    timed: true,
    target: 20,
    description:
        'Lie face down and reach back toward bent ankles while lifting the chest and thighs gently.',
  ),
  ExerciseDefinition(
    id: 'bent_over_dumbbell_rows_left',
    name: 'Bent Over Dumbbell Rows Left',
    motion: ExerciseMotion.bentOverDumbbellRowsLeft,
    area: ExerciseArea.arms,
    timed: false,
    target: 10,
    description:
        'Support the right hand and knee on a stable bench and row the left dumbbell toward the hip. Requires a bench and dumbbell.',
  ),
  ExerciseDefinition(
    id: 'bent_over_dumbbell_rows_right',
    name: 'Bent Over Dumbbell Rows Right',
    motion: ExerciseMotion.bentOverDumbbellRowsRight,
    area: ExerciseArea.arms,
    timed: false,
    target: 10,
    description:
        'Support the left hand and knee on a stable bench and row the right dumbbell toward the hip. Requires a bench and dumbbell.',
  ),
  ExerciseDefinition(
    id: 'back_arches',
    name: 'Back Arches',
    motion: ExerciseMotion.backArches,
    area: ExerciseArea.fullBody,
    timed: true,
    target: 20,
    description:
        'While seated on a stable chair, gently arch the upper back and return upright. Requires a chair.',
  ),
];

ExerciseDefinition exerciseById(String id) => exerciseCatalog.firstWhere(
  (exercise) => exercise.id == id,
  orElse: () => throw FormatException('Unknown exercise: $id'),
);
