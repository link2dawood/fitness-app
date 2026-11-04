import 'training_workout.dart';

/// Reference order, deduplicated across overlapping screenshots.
const extendedDurationWorkoutIds = [
  'ultimate_full_body_builder',
  'arm_advanced',
  'intense_leg_transformation',
  'leg_intermediate',
  'elite_dumbbell_arms',
  'killer_core_hiit_intermediate',
  'leg_advanced',
  'killer_core_hiit_advanced',
];

const extendedDurationArtwork = <String, String>{
  'ultimate_full_body_builder':
      'assets/images/workouts/intermediate_lower_body_strength.png',
  'arm_advanced': 'assets/images/workouts/advanced_arm_advanced.png',
  'intense_leg_transformation':
      'assets/images/workouts/advanced_intense_leg_transformation.png',
  'leg_intermediate': 'assets/images/workouts/beginner_leg_beginner.png',
  'elite_dumbbell_arms':
      'assets/images/workouts/intermediate_dumbbell_workout_at_home.png',
  'killer_core_hiit_intermediate':
      'assets/images/workouts/beginner_10_min_abs_workout.png',
  'leg_advanced': 'assets/images/workouts/advanced_leg_advanced.png',
  'killer_core_hiit_advanced':
      'assets/images/workouts/advanced_killer_core_hiit_advanced.png',
};

List<TrainingWorkout> get extendedDurationWorkouts => [
  for (final id in extendedDurationWorkoutIds)
    for (final workout in trainingWorkouts.where((w) => w.id == id))
      TrainingWorkout(
        id: workout.id,
        title: workout.title,
        difficulty: workout.difficulty,
        type: workout.type,
        image: extendedDurationArtwork[id]!,
        exerciseIds: workout.exerciseIds,
        targets: workout.targets,
        restSeconds: workout.restSeconds,
        planVersion: workout.planVersion,
      ),
];
