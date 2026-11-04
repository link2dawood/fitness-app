import 'training_workout.dart';

/// Screenshot-ordered Beginner collection; repeated screenshots share one row.
const beginnerWorkoutIds = [
  'abs_beginner',
  'arm_beginner',
  'chest_beginner',
  'leg_beginner',
  'shoulder_back_beginner',
  '3_exercises_lose_belly_fat',
  '10_min_abs_workout',
  '10_min_butt_workout',
  '12_min_classic',
  '7_min_hiit_fat_burning',
  '10_min_leg_workout',
  '10_min_shredded_arms',
  '7_min_strong_arms',
  'abs_workout_no_crunch',
  'back_stretching',
  'band_workout_at_home',
  'before_workout_warm_up',
  'beginner_abs_shred',
  'beginner_back_builder',
  'beginner_chest_workout',
  'beginner_core_workout',
  'beginner_push_up',
  'belly_fat_burner_hiit_beginner',
  'bigger_strong_quads_leg_workout',
  'build_wider_shoulders',
  'butt_lift_rounder_booty',
  'easy_arm_workout_with_dumbbells',
  'full_body_stretching',
  'beginner_arm_routine',
  'build_strong_triceps',
  'man_boobs_hiit_beginner',
  'immunity_booster_at_home',
  'killer_core_hiit_beginner',
  'knee_pain_relief',
  'leg_workout_no_jumping',
  'lower_back_pain_relief',
  'lower_body_stretching',
  'morning_warm_up',
  'neck_shoulder_tension_relief',
  'only_4_moves_for_abs',
  'ripped_v_cut_abs_beginner',
  'shape_and_tighten_butt',
  'shoulder_tension_relief',
  'sleepy_time_stretching',
  'strong_legs_routine',
  'upper_body_stretching',
];

List<TrainingWorkout> get beginnerWorkouts => [
  for (final id in beginnerWorkoutIds)
    _beginnerPresentation(
      trainingWorkouts.singleWhere((workout) => workout.id == id),
    ),
];

// Presentation changes keep the canonical ID, targets and progress version.
TrainingWorkout _beginnerPresentation(TrainingWorkout workout) =>
    TrainingWorkout(
      id: workout.id,
      title: workout.id == 'build_wider_shoulders'
          ? 'Build Wider Shoulders - beginner'
          : workout.title,
      difficulty: workout.difficulty,
      type: workout.type,
      image: 'assets/images/workouts/beginner_${workout.id}.png',
      exerciseIds: workout.exerciseIds,
      targets: workout.targets,
      restSeconds: workout.restSeconds,
      planVersion: workout.planVersion,
    );

Map<String, String> get beginnerArtwork => {
  for (final id in beginnerWorkoutIds)
    id: 'assets/images/workouts/beginner_$id.png',
};
