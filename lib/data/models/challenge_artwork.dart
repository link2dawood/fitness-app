import 'training_workout.dart';
import 'user_profile.dart';

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
