import 'package:flutter/material.dart';
import 'exercise.dart';
import 'training_workout.dart';
import 'user_profile.dart';

const challengePosterIds = {
  'intense_belly_fat_burn',
  'calisthenics_plan',
  'lose_weight_for_men',
  'lose_weight_for_women',
  'full_body_challenge',
  'lower_body_challenge',
  'massive_body_challenge',
  'six_pack_challenge',
  'get_ripped_with_dumbbell',
  'full_body_shred',
  'beginner_abs_shred',
};

/// Female-specific poster artwork for every card shown to a female profile.
/// Keeping the mapping explicit prevents a fallback to a default (male) image.
const femaleChallengePosterAssets = <String, String>{
  'intense_belly_fat_burn':
      'assets/images/workouts/poster_sculpted_body_challenge_female.png',
  'calisthenics_plan':
      'assets/images/workouts/poster_height_increase_challenge_female.png',
  'lose_weight_for_women':
      'assets/images/workouts/poster_lose_weight_for_women_female.png',
  'full_body_challenge':
      'assets/images/workouts/poster_full_body_challenge_female.png',
  'lower_body_challenge':
      'assets/images/workouts/poster_kegel_pelvic_firming_female.png',
  'get_ripped_with_dumbbell':
      'assets/images/workouts/poster_get_ripped_with_dumbbell_female.png',
  'full_body_shred':
      'assets/images/workouts/poster_get_fit_with_dumbbell_female.png',
  'beginner_abs_shred':
      'assets/images/workouts/poster_beginner_abs_shred_female.png',
};

bool hasFemaleChallengePoster(String workoutId) =>
    femaleChallengePosterAssets.containsKey(workoutId);

String challengePosterTitle(TrainingWorkout workout) => switch (workout.id) {
  'calisthenics_plan' => 'CALISTHENICS\nPLAN',
  'lose_weight_for_men' => 'LOSE WEIGHT\nFOR MEN',
  'lose_weight_for_women' => 'LOSE WEIGHT\nFOR WOMEN',
  'full_body_challenge' => 'FULL BODY\nCHALLENGE',
  'lower_body_challenge' => 'LOWER BODY\nCHALLENGE',
  'massive_body_challenge' => 'MASSIVE\nBODY\nCHALLENGE',
  'six_pack_challenge' => 'SIX PACK\nCHALLENGE',
  'get_ripped_with_dumbbell' => 'GET RIPPED\nWITH\nDUMBBELL',
  'full_body_shred' => 'FULL BODY\nSHRED',
  'beginner_abs_shred' => 'BEGINNER\nABS SHRED',
  _ => workout.title,
};

String challengePosterArtwork(TrainingWorkout workout, Gender? gender) {
  if (gender == Gender.female) {
    final femaleArtwork = femaleChallengePosterAssets[workout.id];
    if (femaleArtwork != null) return femaleArtwork;
  }
  if (gender == null) {
    final defaultArtwork = femaleChallengePosterAssets[workout.id];
    if (defaultArtwork != null) return defaultArtwork;
  }
  var id = workout.id;
  if (!challengePosterIds.contains(id)) {
    final focus = workout.focus;
    id = workout.equipment.contains(ExerciseEquipment.dumbbell)
        ? 'get_ripped_with_dumbbell'
        : workout.type == ExerciseType.stretch
        ? 'calisthenics_plan'
        : focus.contains(ExerciseFocus.abs) && focus.length <= 3
        ? 'beginner_abs_shred'
        : focus.contains(ExerciseFocus.leg) ||
              focus.contains(ExerciseFocus.glutes)
        ? 'lower_body_challenge'
        : 'full_body_challenge';
  }
  return 'assets/images/workouts/poster_$id.png';
}

Color challengePosterColor(String id) => switch (id) {
  'intense_belly_fat_burn' => const Color(0xFF806E74),
  'calisthenics_plan' => const Color(0xFF922BC5),
  'lose_weight_for_men' => const Color(0xFFFF7624),
  'lose_weight_for_women' => const Color(0xFFEC5478),
  'lower_body_challenge' => const Color(0xFF00ACED),
  'massive_body_challenge' => const Color(0xFF315E80),
  'six_pack_challenge' => const Color(0xFF49318D),
  'get_ripped_with_dumbbell' => const Color(0xFF00A9B8),
  'full_body_shred' => const Color(0xFF24897F),
  'beginner_abs_shred' => const Color(0xFF596AA8),
  _ => const Color(0xFF0062FF),
};

String challengePosterDescription(TrainingWorkout workout) =>
    switch (workout.id) {
      'intense_belly_fat_burn' =>
        'Train your core with focused bodyweight exercises.',
      'calisthenics_plan' =>
        'Build strength and control with bodyweight exercises.',
      'lose_weight_for_men' => 'Keep moving with squats, core work and cardio.',
      'lose_weight_for_women' =>
        'Move through a mix of core and lower-body exercises.',
      'full_body_challenge' =>
        'Train your legs, upper body and core in one session.',
      'lower_body_challenge' =>
        'Challenge your legs with lunges, squats and kicks.',
      'massive_body_challenge' =>
        'Work your muscles with a bodyweight strength session.',
      'six_pack_challenge' =>
        'Focus on your core with twists, crunches and planks.',
      'get_ripped_with_dumbbell' =>
        'Use dumbbells for a focused full-body strength workout.',
      'full_body_shred' =>
        'Combine lower-body exercises, core work and cardio.',
      'beginner_abs_shred' =>
        'Start with approachable core and abdominal exercises.',
      _ => 'A workout selected for your goals and experience.',
    };
