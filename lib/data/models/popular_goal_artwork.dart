import 'user_profile.dart';

/// The three workout previews for each Popular Goals badge.
List<String> popularGoalArtwork(String goal, Gender? gender) {
  final category = switch (goal) {
    'Build Muscle' => 'build_muscle',
    'Keep Fit' => 'keep_fit',
    _ => 'burn_fat',
  };
  final profile = gender == Gender.female ? 'female' : 'male';
  return [
    for (var index = 1; index <= 3; index++)
      'assets/images/workouts/popular_${category}_${profile}_$index.jpg',
  ];
}
