import 'training_workout.dart';

/// Ordered Search > Abs collection. Metadata comes from the playable routines.
const absWorkoutIds = [
  'intense_belly_fat_burn',
  'six_pack_challenge',
  'abs_beginner',
  'abs_intermediate',
  'abs_advanced',
  'only_4_moves_for_abs',
  '10_min_abs_workout',
  'beginner_abs_shred',
  'dumbbell_abs_shaper',
  'plank_challenge',
  'ripped_v_cut_abs_beginner',
  'ripped_v_cut_abs_intermediate',
  'ripped_v_cut_abs_advanced',
  'belly_fat_burner_hiit_beginner',
  'belly_fat_burner_hiit_intermediate',
  'belly_fat_burner_hiit_advanced',
  'killer_core_hiit_beginner',
  'killer_core_hiit_intermediate',
  'killer_core_hiit_advanced',
];

List<TrainingWorkout> get absWorkouts => [
  for (final id in absWorkoutIds)
    trainingWorkouts.singleWhere((workout) => workout.id == id),
];
