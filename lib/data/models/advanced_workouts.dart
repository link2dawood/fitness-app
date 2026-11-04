import 'training_workout.dart';

/// Screenshot order, with independent workout IDs and per-workout cover images.
const advancedWorkoutIds = [
  'abs_advanced',
  'arm_advanced',
  'chest_advanced',
  'leg_advanced',
  'shoulder_back_advanced',
  'body_calorie_burner',
  'belly_fat_burner_hiit_advanced',
  'booty_shaping_butt_lifting',
  'brutal_ladder_hiit',
  'build_wider_shoulders_advanced',
  'man_boobs_hiit_advanced',
  'intense_leg_transformation',
  'killer_chest_workout',
  'killer_core_hiit_advanced',
  'ripped_v_cut_abs_advanced',
];

Map<String, String> get advancedArtwork => {
  for (final id in advancedWorkoutIds)
    id: 'assets/images/workouts/advanced_$id.png',
};

List<TrainingWorkout> get advancedWorkouts => [
  for (final id in advancedWorkoutIds)
    _advancedPresentation(trainingWorkouts.singleWhere((w) => w.id == id)),
];

TrainingWorkout _advancedPresentation(TrainingWorkout workout) =>
    TrainingWorkout(
      id: workout.id,
      title: workout.title,
      difficulty: workout.difficulty,
      type: workout.type,
      image: 'assets/images/workouts/advanced_${workout.id}.png',
      exerciseIds: workout.exerciseIds,
      targets: workout.targets,
      restSeconds: workout.restSeconds,
      planVersion: workout.planVersion,
    );
