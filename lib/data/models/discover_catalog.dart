import 'exercise.dart';
import 'training_workout.dart';

class DiscoverWorkoutCard {
  const DiscoverWorkoutCard(this.workoutId, this.image);
  final String workoutId, image;
  TrainingWorkout get workout => DiscoverCatalog.workout(workoutId);
}

class DiscoverCollection {
  const DiscoverCollection(
    this.id,
    this.title, {
    this.workoutIds,
    this.focus,
    this.equipmentOnly = false,
  });
  final String id, title;
  final List<String>? workoutIds;
  final Set<ExerciseFocus>? focus;
  final bool equipmentOnly;
  List<TrainingWorkout> get workouts => workoutIds != null
      ? workoutIds!.map(DiscoverCatalog.workout).toList()
      : trainingWorkouts
            .where(
              (w) =>
                  (!equipmentOnly ||
                      w.equipment.any(
                        (e) =>
                            e != ExerciseEquipment.none &&
                            e != ExerciseEquipment.mat,
                      )) &&
                  (focus == null || w.focus.any(focus!.contains)),
            )
            .toList();
}

class DiscoverCatalog {
  static const heroWorkoutId = 'beginner_chest_workout';
  static TrainingWorkout workout(String id) => trainingWorkouts.firstWhere(
    (w) => w.id == id,
    orElse: () =>
        throw ArgumentError.value(id, 'id', 'Unknown Discover workout'),
  );
  static const collections = <DiscoverCollection>[
    DiscoverCollection(
      'stay_active',
      'Stay active, stay in shape',
      workoutIds: [
        'morning_warm_up',
        'before_workout_warm_up',
        'full_body_stretching',
        'back_stretching',
        'sleepy_time_stretching',
      ],
    ),
    DiscoverCollection('with_equipment', 'With Equipment', equipmentOnly: true),
    DiscoverCollection('focus_chest', 'Chest', focus: {ExerciseFocus.chest}),
    DiscoverCollection(
      'focus_arm_shoulder',
      'Arm & Shoulder',
      focus: {ExerciseFocus.arm, ExerciseFocus.shoulder},
    ),
    DiscoverCollection(
      'focus_glutes_leg',
      'Butt & Leg',
      focus: {ExerciseFocus.glutes, ExerciseFocus.leg},
    ),
    DiscoverCollection('focus_abs', 'Six pack', focus: {ExerciseFocus.abs}),
  ];
  static DiscoverCollection collection(String id) => collections.firstWhere(
    (c) => c.id == id,
    orElse: () =>
        throw ArgumentError.value(id, 'id', 'Unknown Discover collection'),
  );

  static const List<List<DiscoverWorkoutCard>> picks = [
    [
      DiscoverWorkoutCard(
        'beginner_chest_workout',
        'assets/images/workouts/hiit_fat_burning.jpg',
      ),
      DiscoverWorkoutCard('abs_beginner', 'assets/images/workouts/abs.jpg'),
    ],
    [
      DiscoverWorkoutCard(
        'build_wider_shoulders',
        'assets/images/workouts/shoulder_tension_relief.jpg',
      ),
      DiscoverWorkoutCard(
        'belly_fat_burner_hiit_intermediate',
        'assets/images/workouts/squat.jpg',
      ),
    ],
    [
      DiscoverWorkoutCard(
        'full_body_muscle_growth',
        'assets/images/workouts/full_body_muscle_growth.jpg',
      ),
      DiscoverWorkoutCard(
        'abs_intermediate',
        'assets/images/workouts/dumbbell_abs_shaper.jpg',
      ),
    ],
    [
      DiscoverWorkoutCard(
        'fat_burning_hiit',
        'assets/images/workouts/belly_fat_burn.jpg',
      ),
    ],
  ];
  static const List<DiscoverWorkoutCard> beginners = [
    DiscoverWorkoutCard(
      'beginner_arm_routine',
      'assets/images/workouts/discover_arm_workout.jpg',
    ),
    DiscoverWorkoutCard(
      'beginner_abs_shred',
      'assets/images/workouts/discover_abs_outdoor.jpg',
    ),
    DiscoverWorkoutCard(
      'build_wider_shoulders',
      'assets/images/workouts/shoulder_tension_relief.jpg',
    ),
    DiscoverWorkoutCard(
      'lose_fat_no_jumping',
      'assets/images/workouts/lower_body.jpg',
    ),
    DiscoverWorkoutCard(
      'beginner_back_builder',
      'assets/images/workouts/beginner_back_builder.jpg',
    ),
    DiscoverWorkoutCard(
      'beginner_chest_workout',
      'assets/images/workouts/beginner_chest_workout.jpg',
    ),
    DiscoverWorkoutCard(
      'beginner_chest_sculpt',
      'assets/images/workouts/shredded_arms.jpg',
    ),
    DiscoverWorkoutCard(
      'abs_beginner',
      'assets/images/workouts/discover_12min_classic.jpg',
    ),
  ];
  static const List<List<DiscoverWorkoutCard>> fast = [
    [
      DiscoverWorkoutCard(
        'before_workout_warm_up',
        'assets/images/workouts/discover_warmup_lunge.jpg',
      ),
      DiscoverWorkoutCard(
        'full_body_shred',
        'assets/images/workouts/discover_12min_classic.jpg',
      ),
    ],
    [
      DiscoverWorkoutCard('6_min_tabata', 'assets/images/workouts/squat.jpg'),
      DiscoverWorkoutCard(
        '3_exercises_lose_belly_fat',
        'assets/images/workouts/belly_fat_burn.jpg',
      ),
    ],
    [
      DiscoverWorkoutCard(
        '7_min_hiit_fat_burning',
        'assets/images/workouts/hiit_fat_burning.jpg',
      ),
      DiscoverWorkoutCard('abs_intermediate', 'assets/images/workouts/abs.jpg'),
    ],
    [
      DiscoverWorkoutCard(
        '7_min_hiit_fat_burning',
        'assets/images/workouts/hiit_fat_burning.jpg',
      ),
      DiscoverWorkoutCard('abs_beginner', 'assets/images/workouts/abs.jpg'),
    ],
    [
      DiscoverWorkoutCard(
        'full_body_muscle_growth',
        'assets/images/workouts/full_body_muscle_growth.jpg',
      ),
    ],
  ];
  static const List<DiscoverWorkoutCard> challenges = [
    DiscoverWorkoutCard(
      'abs_advanced',
      'assets/images/workouts/discover_killer_core.jpg',
    ),
    DiscoverWorkoutCard(
      'full_body_challenge',
      'assets/images/workouts/discover_brutal_hiit.jpg',
    ),
    DiscoverWorkoutCard(
      'build_wider_shoulders',
      'assets/images/workouts/shoulder_tension_relief.jpg',
    ),
    DiscoverWorkoutCard('six_pack_challenge', 'assets/images/workouts/abs.jpg'),
    DiscoverWorkoutCard(
      'killer_chest_routine',
      'assets/images/workouts/beginner_chest_workout.jpg',
    ),
    DiscoverWorkoutCard(
      'massive_body_challenge',
      'assets/images/workouts/massive_body.jpg',
    ),
    DiscoverWorkoutCard(
      '10_min_shredded_arms',
      'assets/images/workouts/discover_arm_workout.jpg',
    ),
    DiscoverWorkoutCard(
      'belly_fat_burner_hiit_advanced',
      'assets/images/workouts/belly_fat_burn.jpg',
    ),
    DiscoverWorkoutCard(
      'full_body_shred',
      'assets/images/workouts/full_body_muscle_growth.jpg',
    ),
    DiscoverWorkoutCard(
      'fat_burning_hiit',
      'assets/images/workouts/discover_brutal_hiit.jpg',
    ),
  ];
  static const List<List<DiscoverWorkoutCard>> stretch = [
    [
      DiscoverWorkoutCard(
        'neck_shoulder_tension_relief',
        'assets/images/workouts/neck_shoulder_tension_relief.jpg',
      ),
      DiscoverWorkoutCard(
        'lower_body_stretching',
        'assets/images/workouts/knee_pain_relief.jpg',
      ),
    ],
    [
      DiscoverWorkoutCard(
        'upper_body_stretching',
        'assets/images/workouts/upper_body_stretching.jpg',
      ),
      DiscoverWorkoutCard(
        'back_stretching',
        'assets/images/workouts/stretch_sleepy.jpg',
      ),
    ],
    [
      DiscoverWorkoutCard(
        'lower_body_stretching',
        'assets/images/workouts/lower_body.jpg',
      ),
      DiscoverWorkoutCard(
        'back_stretching',
        'assets/images/workouts/back_builder.jpg',
      ),
    ],
    [
      DiscoverWorkoutCard(
        'full_body_stretching',
        'assets/images/workouts/stretch_shoulder.jpg',
      ),
      DiscoverWorkoutCard(
        'shoulder_tension_relief',
        'assets/images/workouts/shoulder_tension_relief.jpg',
      ),
    ],
    [
      DiscoverWorkoutCard(
        'morning_warm_up',
        'assets/images/workouts/stretch_warmup.jpg',
      ),
      DiscoverWorkoutCard(
        'sleepy_time_stretching',
        'assets/images/workouts/back_sb.jpg',
      ),
    ],
  ];
  static List<DiscoverWorkoutCard> get workoutCards => [
    const DiscoverWorkoutCard(
      heroWorkoutId,
      'assets/images/workouts/hiit_fat_burning.jpg',
    ),
    ...picks.expand((g) => g),
    ...beginners,
    ...fast.expand((g) => g),
    ...challenges,
    ...stretch.expand((g) => g),
  ];
}
