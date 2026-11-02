import 'training_workout.dart';

/// Ordered Search > Full Body collection, sharing playable workout metadata.
const fullBodyWorkoutIds = [
  'lose_weight_for_men',
  'lose_weight_for_women',
  'full_body_challenge',
  'massive_body_challenge',
  'fat_burning_hiit',
  '7_min_hiit_fat_burning',
];

List<TrainingWorkout> get fullBodyWorkouts => [
  for (final id in fullBodyWorkoutIds)
    trainingWorkouts.singleWhere((workout) => workout.id == id),
];
