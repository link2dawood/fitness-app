import 'training_workout.dart';

/// Reference order, deduplicated across overlapping screenshots.
const longDurationWorkoutIds = [
  'maximum_height_growth',
  'extreme_height_growth',
  'butt_advanced',
  'arm_building_circuit',
  'butt_blaster_challenge',
  'defined_arms_with_dumbbells',
  'intense_leg_power_challenge',
  'plank_challenge',
  'shoulder_back_advanced',
  'strong_arms_basics',
  'forearm_advanced',
  'dumbbell_abs_shaper',
  'man_boobs_hiit_advanced',
  'lower_body_strength',
  'ripped_v_cut_abs_intermediate',
  'glutes_legs_strength_starter',
  'build_wider_shoulders_strength',
  'abs_intermediate',
  'athletes_choice_at_home',
  'forearm_mastery',
  'full_body_muscle_growth',
  'beginner_chest_sculpt',
  'belly_fat_burner_hiit_intermediate',
  'build_wider_shoulders_advanced',
  'lower_body_muscle_gain',
  'brutal_ladder_hiit',
  'ripped_v_cut_abs_advanced',
  'bigger_arms_challenge',
  'full_body_power_progression',
  'peak_full_body_strength',
  'bigger_chest_builder',
  'elite_abs_builder',
  'body_calorie_burner',
  'abs_advanced',
  'ultimate_lower_body_pump',
  'belly_fat_burner_hiit_advanced',
  'killer_chest_workout',
  'intense_v_taper_challenge',
  'booty_shaping_butt_lifting',
];

const longDurationArtwork = <String, String>{
  'maximum_height_growth': 'assets/images/workouts/duration_height_starter.png',
  'extreme_height_growth':
      'assets/images/workouts/duration_explosive_height_gains.png',
  'butt_advanced': 'assets/images/workouts/beginner_10_min_butt_workout.png',
  'arm_building_circuit':
      'assets/images/workouts/beginner_beginner_arm_routine.png',
  'butt_blaster_challenge':
      'assets/images/workouts/intermediate_butt_blaster_challenge.png',
  'defined_arms_with_dumbbells':
      'assets/images/workouts/beginner_easy_arm_workout_with_dumbbells.png',
  'intense_leg_power_challenge':
      'assets/images/workouts/intermediate_intense_leg_power_challenge.png',
  'plank_challenge': 'assets/images/workouts/beginner_12_min_classic.png',
  'shoulder_back_advanced':
      'assets/images/workouts/advanced_shoulder_back_advanced.png',
  'strong_arms_basics':
      'assets/images/workouts/intermediate_dumbbell_workout_at_home.png',
  'forearm_advanced':
      'assets/images/workouts/challenge_get_ripped_with_dumbbell_male.png',
  'dumbbell_abs_shaper': 'assets/images/workouts/dumbbell_abs_shaper.jpg',
  'man_boobs_hiit_advanced':
      'assets/images/workouts/advanced_man_boobs_hiit_advanced.png',
  'lower_body_strength':
      'assets/images/workouts/intermediate_lower_body_strength.png',
  'ripped_v_cut_abs_intermediate':
      'assets/images/workouts/beginner_ripped_v_cut_abs_beginner.png',
  'glutes_legs_strength_starter':
      'assets/images/workouts/beginner_leg_beginner.png',
  'build_wider_shoulders_strength':
      'assets/images/workouts/beginner_build_wider_shoulders.png',
  'abs_intermediate': 'assets/images/workouts/beginner_beginner_abs_shred.png',
  'athletes_choice_at_home':
      'assets/images/workouts/intermediate_athletes_choice_at_home.png',
  'forearm_mastery': 'assets/images/workouts/advanced_arm_advanced.png',
  'full_body_muscle_growth':
      'assets/images/workouts/full_body_muscle_growth.jpg',
  'beginner_chest_sculpt': 'assets/images/workouts/advanced_chest_advanced.png',
  'belly_fat_burner_hiit_intermediate':
      'assets/images/workouts/beginner_killer_core_hiit_beginner.png',
  'build_wider_shoulders_advanced':
      'assets/images/workouts/advanced_build_wider_shoulders_advanced.png',
  'lower_body_muscle_gain':
      'assets/images/workouts/beginner_bigger_strong_quads_leg_workout.png',
  'brutal_ladder_hiit':
      'assets/images/workouts/advanced_brutal_ladder_hiit.png',
  'ripped_v_cut_abs_advanced':
      'assets/images/workouts/advanced_ripped_v_cut_abs_advanced.png',
  'bigger_arms_challenge': 'assets/images/workouts/beginner_arm_beginner.png',
  'full_body_power_progression':
      'assets/images/workouts/beginner_abs_workout_no_crunch.png',
  'peak_full_body_strength':
      'assets/images/workouts/beginner_band_workout_at_home.png',
  'bigger_chest_builder':
      'assets/images/workouts/beginner_beginner_chest_workout.png',
  'elite_abs_builder': 'assets/images/workouts/beginner_abs_beginner.png',
  'body_calorie_burner':
      'assets/images/workouts/advanced_body_calorie_burner.png',
  'abs_advanced': 'assets/images/workouts/advanced_abs_advanced.png',
  'ultimate_lower_body_pump':
      'assets/images/workouts/beginner_leg_workout_no_jumping.png',
  'belly_fat_burner_hiit_advanced':
      'assets/images/workouts/advanced_belly_fat_burner_hiit_advanced.png',
  'killer_chest_workout':
      'assets/images/workouts/advanced_killer_chest_workout.png',
  'intense_v_taper_challenge':
      'assets/images/workouts/beginner_beginner_back_builder.png',
  'booty_shaping_butt_lifting':
      'assets/images/workouts/advanced_booty_shaping_butt_lifting.png',
};

List<TrainingWorkout> get longDurationWorkouts => [
  for (final id in longDurationWorkoutIds)
    for (final workout in trainingWorkouts.where((w) => w.id == id))
      TrainingWorkout(
        id: workout.id,
        title: workout.title,
        difficulty: workout.difficulty,
        type: workout.type,
        image: longDurationArtwork[id]!,
        exerciseIds: workout.exerciseIds,
        targets: workout.targets,
        restSeconds: workout.restSeconds,
        planVersion: workout.planVersion,
      ),
];
