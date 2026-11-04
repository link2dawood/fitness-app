import 'training_workout.dart';

/// Reference order for Search > <=10 Mins. Durations use actual routine data.
const shortWorkoutIds = [
  'before_workout_warm_up',
  '6_min_tabata',
  '7_min_strong_arms',
  'beginner_chest_workout',
  'build_strong_triceps',
  '7_min_hiit_fat_burning',
  'beginner_arm_routine',
  '3_exercises_lose_belly_fat',
  '10_min_abs_workout',
  'butt_lift_rounder_booty',
  'chest_beginner',
  'killer_chest_routine',
  'morning_warm_up',
  'sculpted_arms_workout',
  '10_min_butt_workout',
  '10_min_leg_workout',
];

const shortWorkoutArtwork = <String, String>{
  'before_workout_warm_up':
      'assets/images/workouts/beginner_before_workout_warm_up.png',
  '6_min_tabata':
      'assets/images/workouts/beginner_belly_fat_burner_hiit_beginner.png',
  '7_min_strong_arms': 'assets/images/workouts/beginner_7_min_strong_arms.png',
  'beginner_chest_workout':
      'assets/images/workouts/beginner_beginner_chest_workout.png',
  'build_strong_triceps':
      'assets/images/workouts/beginner_build_strong_triceps.png',
  '7_min_hiit_fat_burning':
      'assets/images/workouts/beginner_7_min_hiit_fat_burning.png',
  'beginner_arm_routine':
      'assets/images/workouts/beginner_beginner_arm_routine.png',
  '3_exercises_lose_belly_fat':
      'assets/images/workouts/beginner_3_exercises_lose_belly_fat.png',
  '10_min_abs_workout':
      'assets/images/workouts/beginner_10_min_abs_workout.png',
  'butt_lift_rounder_booty':
      'assets/images/workouts/beginner_butt_lift_rounder_booty.png',
  'chest_beginner': 'assets/images/workouts/beginner_chest_beginner.png',
  'killer_chest_routine':
      'assets/images/workouts/beginner_beginner_push_up.png',
  'morning_warm_up': 'assets/images/workouts/beginner_morning_warm_up.png',
  'sculpted_arms_workout':
      'assets/images/workouts/beginner_full_body_stretching.png',
  '10_min_butt_workout':
      'assets/images/workouts/beginner_10_min_butt_workout.png',
  '10_min_leg_workout':
      'assets/images/workouts/beginner_10_min_leg_workout.png',
};

List<TrainingWorkout> get shortWorkouts => [
  for (final id in shortWorkoutIds)
    _shortPresentation(trainingWorkouts.singleWhere((w) => w.id == id)),
];

TrainingWorkout _shortPresentation(TrainingWorkout workout) => TrainingWorkout(
  id: workout.id,
  title: workout.title,
  difficulty: workout.difficulty,
  type: workout.type,
  image: shortWorkoutArtwork[workout.id]!,
  exerciseIds: workout.exerciseIds,
  targets: workout.targets,
  restSeconds: workout.restSeconds,
  planVersion: workout.planVersion,
);
