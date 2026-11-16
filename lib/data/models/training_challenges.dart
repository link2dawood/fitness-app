import 'exercise.dart';
import 'challenge_poster.dart';
import 'training_workout.dart';
import 'training_recommendations.dart';
import 'user_profile.dart';

/// Challenge membership and goals are explicit, independent of display titles.
class TrainingChallenge {
  const TrainingChallenge(
    this.workoutId,
    this.goals, {
    this.fullBody = false,
    this.calisthenics = false,
    this.referenceDay = false,
    this.customized = false,
  });
  final String workoutId;
  final Set<FitnessGoal> goals;
  final bool fullBody, calisthenics, referenceDay, customized;
  TrainingWorkout get workout => workoutId.startsWith('female_')
      ? TrainingChallenges.femaleWorkouts.firstWhere(
          (workout) => workout.id == workoutId,
        )
      : trainingWorkouts.firstWhere((workout) => workout.id == workoutId);
  bool matches(String filter) => switch (filter) {
    'All' => true,
    'Build Muscle' => goals.contains(FitnessGoal.buildMuscle),
    'Lose Weight' => goals.contains(FitnessGoal.loseWeight),
    'Abs' => workout.focus.contains(ExerciseFocus.abs),
    'Upper Body' => workout.focus.any(
      (focus) => {
        ExerciseFocus.arm,
        ExerciseFocus.chest,
        ExerciseFocus.shoulder,
        ExerciseFocus.back,
      }.contains(focus),
    ),
    'Lower Body' => workout.focus.any(
      (focus) => {ExerciseFocus.leg, ExerciseFocus.glutes}.contains(focus),
    ),
    'Full Body' => fullBody,
    'Calisthenics' => calisthenics,
    'Dumbbell' => workout.equipment.contains(ExerciseEquipment.dumbbell),
    _ => false,
  };
}

class TrainingChallenges {
  static TrainingWorkout _femaleWorkout(
    String id,
    String title,
    String sourceId,
    String image,
  ) {
    final source = trainingWorkouts.firstWhere((item) => item.id == sourceId);
    return TrainingWorkout(
      id: id,
      title: title,
      difficulty: source.difficulty,
      type: source.type,
      image: image,
      exerciseIds: source.exerciseIds,
      targets: source.targets,
      restSeconds: source.restSeconds,
      timedExercises: source.timedExercises,
    );
  }

  static final femaleWorkouts = [
    _femaleWorkout(
      'female_full_body_challenge',
      'Full Body Challenge',
      'full_body_challenge',
      femaleChallengePosterAssets['female_full_body_challenge']!,
    ),
    _femaleWorkout(
      'female_sculpted_body_challenge',
      'Sculpted Body Challenge',
      'massive_body_challenge',
      femaleChallengePosterAssets['female_sculpted_body_challenge']!,
    ),
    _femaleWorkout(
      'female_calisthenics_plan',
      'Calisthenics Plan',
      'calisthenics_plan',
      femaleChallengePosterAssets['female_calisthenics_plan']!,
    ),
    _femaleWorkout(
      'female_get_fit_with_dumbbell',
      'Get Fit With Dumbbell',
      'get_ripped_with_dumbbell',
      femaleChallengePosterAssets['female_get_fit_with_dumbbell']!,
    ),
    _femaleWorkout(
      'female_lose_weight_for_women',
      'Lose Weight For Women',
      'lose_weight_for_women',
      femaleChallengePosterAssets['female_lose_weight_for_women']!,
    ),
    _femaleWorkout(
      'female_lower_body_challenge',
      'Lower Body Challenge',
      'lower_body_challenge',
      femaleChallengePosterAssets['female_lower_body_challenge']!,
    ),
    _femaleWorkout(
      'female_flat_belly_six_pack',
      'Flat Belly & Six Pack',
      'six_pack_challenge',
      femaleChallengePosterAssets['female_flat_belly_six_pack']!,
    ),
    _femaleWorkout(
      'female_kegel_pelvic_firming',
      'Kegel Pelvic Firming',
      'bubble_butt_workout',
      femaleChallengePosterAssets['female_kegel_pelvic_firming']!,
    ),
    _femaleWorkout(
      'female_height_increase_challenge',
      'Height Increase Challenge',
      'full_body_stretching',
      femaleChallengePosterAssets['female_height_increase_challenge']!,
    ),
    _femaleWorkout(
      'female_intense_belly_fat_blast',
      'Intense Belly Fat Blast',
      'intense_belly_fat_burn',
      femaleChallengePosterAssets['female_intense_belly_fat_blast']!,
    ),
  ];

  static const femaleCatalog = [
    TrainingChallenge('female_full_body_challenge', {
      FitnessGoal.buildMuscle,
      FitnessGoal.loseWeight,
    }, fullBody: true),
    TrainingChallenge('female_sculpted_body_challenge', {
      FitnessGoal.buildMuscle,
    }, fullBody: true),
    TrainingChallenge(
      'female_calisthenics_plan',
      {FitnessGoal.buildMuscle},
      fullBody: true,
      calisthenics: true,
    ),
    TrainingChallenge('female_get_fit_with_dumbbell', {
      FitnessGoal.buildMuscle,
    }, fullBody: true),
    TrainingChallenge('female_lose_weight_for_women', {FitnessGoal.loseWeight}),
    TrainingChallenge('female_lower_body_challenge', {FitnessGoal.buildMuscle}),
    TrainingChallenge('female_flat_belly_six_pack', {FitnessGoal.buildMuscle}),
    TrainingChallenge('female_kegel_pelvic_firming', {FitnessGoal.buildMuscle}),
    TrainingChallenge('female_height_increase_challenge', {
      FitnessGoal.buildMuscle,
    }),
    TrainingChallenge('female_intense_belly_fat_blast', {
      FitnessGoal.loseWeight,
    }),
  ];
  static const filters = [
    'All',
    'Build Muscle',
    'Lose Weight',
    'Abs',
    'Upper Body',
    'Lower Body',
    'Full Body',
    'Calisthenics',
    'Dumbbell',
  ];
  static const catalog = [
    TrainingChallenge('intense_belly_fat_burn', {
      FitnessGoal.loseWeight,
    }, referenceDay: true),
    TrainingChallenge(
      'calisthenics_plan',
      {FitnessGoal.buildMuscle, FitnessGoal.loseWeight},
      fullBody: true,
      calisthenics: true,
    ),
    TrainingChallenge('lose_weight_for_men', {FitnessGoal.loseWeight}),
    TrainingChallenge('lose_weight_for_women', {FitnessGoal.loseWeight}),
    TrainingChallenge('full_body_challenge', {
      FitnessGoal.buildMuscle,
      FitnessGoal.loseWeight,
    }, fullBody: true),
    TrainingChallenge('lower_body_challenge', {FitnessGoal.buildMuscle}),
    TrainingChallenge('massive_body_challenge', {
      FitnessGoal.buildMuscle,
    }, fullBody: true),
    TrainingChallenge('six_pack_challenge', {FitnessGoal.buildMuscle}),
    TrainingChallenge('get_ripped_with_dumbbell', {
      FitnessGoal.buildMuscle,
    }, fullBody: true),
    TrainingChallenge('full_body_shred', {
      FitnessGoal.loseWeight,
    }, fullBody: true),
    TrainingChallenge('beginner_abs_shred', {FitnessGoal.loseWeight}),
  ];

  static Iterable<TrainingChallenge> featured() => catalog.where(
    (item) => const {
      'calisthenics_plan',
      'full_body_challenge',
      'get_ripped_with_dumbbell',
    }.contains(item.workoutId),
  );

  static List<TrainingChallenge> forProfile(UserProfile? profile) {
    final visibleCatalog = profile?.gender == Gender.female
        ? femaleCatalog
        : catalog;
    final recommended = TrainingRecommendations.forProfile(profile);
    if (recommended.isEmpty) return visibleCatalog;
    final id = recommended.first.id;
    final existing = visibleCatalog
        .where((item) => item.workoutId == id)
        .firstOrNull;
    // Preserve the real Day 1 destination, never replace it with a generic card.
    if (existing == null || existing.referenceDay) return visibleCatalog;
    final customized = TrainingChallenge(
      id,
      existing.goals,
      fullBody: existing.fullBody,
      calisthenics: existing.calisthenics,
      customized: true,
    );
    return [
      customized,
      ...visibleCatalog.where((item) => item.workoutId != id),
    ];
  }
}
