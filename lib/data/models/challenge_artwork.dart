import 'training_workout.dart';
import 'user_profile.dart';
import 'beginner_workouts.dart';
import 'intermediate_workouts.dart';
import 'advanced_workouts.dart';

/// Prefer the exercise-specific photos already bundled for search collections.
String customizedChallengeArtwork(TrainingWorkout workout, Gender? gender) {
  if (gender == Gender.female) return challengeArtwork(workout, gender);
  return advancedArtwork[workout.id] ??
      beginnerArtwork[workout.id] ??
      intermediateArtwork[workout.id] ??
      challengeArtwork(workout, gender);
}

/// Male variants for challenge artwork whose default demonstrator is female.
const maleChallengeArtworkIds = {
  'lose_weight_for_women',
  'full_body_challenge',
  'get_ripped_with_dumbbell',
  'beginner_abs_shred',
};

String challengeArtwork(TrainingWorkout workout, Gender? gender) =>
    gender == Gender.male && maleChallengeArtworkIds.contains(workout.id)
    ? 'assets/images/workouts/challenge_${workout.id}_male.png'
    : workout.image;
