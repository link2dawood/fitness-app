import 'training_workout.dart';
import 'beginner_workouts.dart';
import 'intermediate_workouts.dart';
import 'advanced_workouts.dart';

/// Reference order, deduplicated across overlapping screenshots.
const mediumDurationWorkoutIds = [
  '10_min_shredded_arms',
  'abs_workout_no_crunch',
  'bigger_strong_quads_leg_workout',
  'full_body_stretching',
  'immunity_booster_at_home',
  'only_4_moves_for_abs',
  'quick_bigger_chest_building',
  '12_min_classic',
  'strong_legs_routine',
  'upper_body_stretching',
  'back_stretching',
  'fat_burning_hiit',
  'knee_pain_relief',
  'shape_and_tighten_butt',
  'butt_beginner',
  'build_wider_shoulders',
  'lower_back_pain_relief',
  'lower_body_stretching',
  'shoulder_back_beginner',
  'grow_taller_foundation',
  'height_starter',
  'forearm_beginner',
  'abs_beginner',
  'beginner_back_builder',
  'dumbbell_workout_at_home',
  'neck_shoulder_tension_relief',
  'ripped_v_cut_abs_beginner',
  'band_workout_at_home',
  'beginner_abs_shred',
  'build_wider_shoulders_intermediate',
  'easy_arm_workout_with_dumbbells',
  'man_boobs_hiit_beginner',
  'arm_beginner',
  'chest_advanced',
  'man_boobs_hiit_intermediate',
  'explosive_height_gains',
  '360_height_boost',
  'butt_intermediate',
  'arm_workout_no_push_ups',
  'shred_your_quads',
  'hiit_intermediate',
  'shoulder_back_intermediate',
  'forearm_foundation',
  'forearm_intermediate',
  'belly_fat_burner_hiit_beginner',
  'killer_core_hiit_beginner',
  'lose_fat_no_jumping',
  'rounder_booty_shaping',
  'stay_in_shape_at_home',
];

Map<String, String> get mediumDurationArtwork {
  final images = {
    ...beginnerArtwork,
    ...intermediateArtwork,
    ...advancedArtwork,
    'butt_beginner': 'assets/images/workouts/beginner_10_min_butt_workout.png',
    'butt_intermediate':
        'assets/images/workouts/advanced_booty_shaping_butt_lifting.png',
    'forearm_beginner': 'assets/images/workouts/dumbbell_abs_shaper.jpg',
    'forearm_intermediate':
        'assets/images/workouts/challenge_get_ripped_with_dumbbell_male.png',
    'forearm_foundation': 'assets/images/workouts/advanced_arm_advanced.png',
    'shred_your_quads': 'assets/images/workouts/advanced_leg_advanced.png',
    'build_wider_shoulders_intermediate':
        'assets/images/workouts/advanced_build_wider_shoulders_advanced.png',
    'shoulder_back_intermediate':
        'assets/images/workouts/advanced_shoulder_back_advanced.png',
    'lose_fat_no_jumping':
        'assets/images/workouts/advanced_belly_fat_burner_hiit_advanced.png',
    'man_boobs_hiit_intermediate':
        'assets/images/workouts/advanced_man_boobs_hiit_advanced.png',
    'stay_in_shape_at_home':
        'assets/images/workouts/intermediate_athletes_choice_at_home.png',
    'grow_taller_foundation':
        'assets/images/workouts/duration_grow_taller_foundation.png',
    'height_starter': 'assets/images/workouts/duration_height_starter.png',
    'explosive_height_gains':
        'assets/images/workouts/duration_explosive_height_gains.png',
    '360_height_boost': 'assets/images/workouts/duration_360_height_boost.png',
  };
  return {for (final id in mediumDurationWorkoutIds) id: images[id]!};
}

List<TrainingWorkout> get mediumDurationWorkouts => [
  for (final id in mediumDurationWorkoutIds)
    _durationPresentation(
      trainingWorkouts.singleWhere((workout) => workout.id == id),
    ),
];

TrainingWorkout _durationPresentation(TrainingWorkout workout) =>
    TrainingWorkout(
      id: workout.id,
      title: workout.id == 'build_wider_shoulders'
          ? 'Build Wider Shoulders - beginner'
          : workout.title,
      difficulty: workout.difficulty,
      type: workout.type,
      image: mediumDurationArtwork[workout.id]!,
      exerciseIds: workout.exerciseIds,
      targets: workout.targets,
      restSeconds: workout.restSeconds,
      planVersion: workout.planVersion,
    );
