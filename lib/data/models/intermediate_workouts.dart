import 'training_workout.dart';

/// Explicit reference order; stable IDs retain progress across collections.
const intermediateWorkoutIds = [
  'abs_intermediate',
  'arm_intermediate',
  'chest_intermediate',
  'leg_intermediate',
  'shoulder_back_intermediate',
  '6_min_tabata',
  'arm_building_circuit',
  'arm_workout_no_push_ups',
  'athletes_choice_at_home',
  'belly_fat_burner_hiit_intermediate',
  'bubble_butt_workout',
  'build_wider_shoulders_intermediate',
  'burn_100_calories',
  'shred_your_quads',
  'butt_blaster_challenge',
  'defined_arms_with_dumbbells',
  'dumbbell_abs_shaper',
  'dumbbell_workout_at_home',
  'fat_burning_hiit',
  'man_boobs_hiit_intermediate',
  'hiit_intermediate',
  'intense_leg_power_challenge',
  'killer_chest_routine',
  'killer_core_hiit_intermediate',
  'last_longer_in_bed',
  'lower_body_strength',
  'lose_fat_no_jumping',
  'plank_challenge',
  'quick_bigger_chest_building',
  'ripped_v_cut_abs_intermediate',
  'rounder_booty_shaping',
  'sculpted_arms_workout',
];

const intermediateArtwork = <String, String>{
  'abs_intermediate': 'assets/images/workouts/beginner_abs_beginner.png',
  'arm_intermediate': 'assets/images/workouts/beginner_arm_beginner.png',
  'chest_intermediate': 'assets/images/workouts/beginner_chest_beginner.png',
  'leg_intermediate': 'assets/images/workouts/beginner_leg_beginner.png',
  'shoulder_back_intermediate':
      'assets/images/workouts/beginner_shoulder_back_beginner.png',
  '6_min_tabata':
      'assets/images/workouts/beginner_belly_fat_burner_hiit_beginner.png',
  'arm_building_circuit':
      'assets/images/workouts/beginner_beginner_arm_routine.png',
  'arm_workout_no_push_ups':
      'assets/images/workouts/beginner_7_min_strong_arms.png',
  'athletes_choice_at_home':
      'assets/images/workouts/intermediate_athletes_choice_at_home.png',
  'belly_fat_burner_hiit_intermediate':
      'assets/images/workouts/beginner_killer_core_hiit_beginner.png',
  'bubble_butt_workout':
      'assets/images/workouts/beginner_shape_and_tighten_butt.png',
  'build_wider_shoulders_intermediate':
      'assets/images/workouts/beginner_build_wider_shoulders.png',
  'burn_100_calories':
      'assets/images/workouts/beginner_immunity_booster_at_home.png',
  'shred_your_quads':
      'assets/images/workouts/beginner_bigger_strong_quads_leg_workout.png',
  'butt_blaster_challenge':
      'assets/images/workouts/intermediate_butt_blaster_challenge.png',
  'defined_arms_with_dumbbells':
      'assets/images/workouts/beginner_easy_arm_workout_with_dumbbells.png',
  'dumbbell_abs_shaper': 'assets/images/workouts/dumbbell_abs_shaper.jpg',
  'dumbbell_workout_at_home':
      'assets/images/workouts/intermediate_dumbbell_workout_at_home.png',
  'fat_burning_hiit':
      'assets/images/workouts/beginner_7_min_hiit_fat_burning.png',
  'man_boobs_hiit_intermediate':
      'assets/images/workouts/beginner_man_boobs_hiit_beginner.png',
  'hiit_intermediate':
      'assets/images/workouts/beginner_before_workout_warm_up.png',
  'intense_leg_power_challenge':
      'assets/images/workouts/intermediate_intense_leg_power_challenge.png',
  'killer_chest_routine':
      'assets/images/workouts/beginner_beginner_push_up.png',
  'killer_core_hiit_intermediate':
      'assets/images/workouts/beginner_10_min_abs_workout.png',
  'last_longer_in_bed':
      'assets/images/workouts/intermediate_last_longer_in_bed.png',
  'lower_body_strength':
      'assets/images/workouts/intermediate_lower_body_strength.png',
  'lose_fat_no_jumping':
      'assets/images/workouts/beginner_abs_workout_no_crunch.png',
  'plank_challenge': 'assets/images/workouts/beginner_12_min_classic.png',
  'quick_bigger_chest_building':
      'assets/images/workouts/beginner_beginner_chest_workout.png',
  'ripped_v_cut_abs_intermediate':
      'assets/images/workouts/beginner_ripped_v_cut_abs_beginner.png',
  'rounder_booty_shaping':
      'assets/images/workouts/beginner_butt_lift_rounder_booty.png',
  'sculpted_arms_workout':
      'assets/images/workouts/beginner_morning_warm_up.png',
};

List<TrainingWorkout> get intermediateWorkouts => [
  for (final id in intermediateWorkoutIds)
    _intermediatePresentation(trainingWorkouts.singleWhere((w) => w.id == id)),
];

TrainingWorkout _intermediatePresentation(TrainingWorkout workout) =>
    TrainingWorkout(
      id: workout.id,
      title: workout.title,
      difficulty: workout.difficulty,
      type: workout.type,
      image: intermediateArtwork[workout.id]!,
      exerciseIds: workout.exerciseIds,
      targets: workout.targets,
      restSeconds: workout.restSeconds,
      planVersion: workout.planVersion,
    );
