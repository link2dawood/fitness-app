import 'training_workout.dart';

/// Ordered Search > Arm collection, including forearm routines.
const armWorkoutIds = [
  'arm_beginner',
  'arm_intermediate',
  'arm_advanced',
  'arm_workout_no_push_ups',
  '10_min_shredded_arms',
  'easy_arm_workout_with_dumbbells',
  'defined_arms_with_dumbbells',
  'sculpted_arms_workout',
  'build_strong_triceps',
  'beginner_arm_routine',
  'arm_building_circuit',
  '7_min_strong_arms',
  'forearm_mastery',
  'forearm_builder',
  'forearm_beginner',
  'forearm_advanced',
  'forearm_intermediate',
  'forearm_foundation',
];

List<TrainingWorkout> get armWorkouts => [
  for (final id in armWorkoutIds)
    trainingWorkouts.singleWhere((workout) => workout.id == id),
];
