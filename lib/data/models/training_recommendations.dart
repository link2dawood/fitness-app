import 'exercise.dart';
import 'training_workout.dart';
import 'user_profile.dart';

class TrainingRecommendations {
  static List<TrainingWorkout> forProfile(UserProfile? profile) {
    // Never invent an advanced level or a customized plan for an absent profile.
    if (profile == null || profile.level == null) return [];
    final level = switch (profile.level!) {
      FitnessLevel.beginner => ExerciseDifficulty.easy,
      FitnessLevel.intermediate => ExerciseDifficulty.medium,
      FitnessLevel.advanced => ExerciseDifficulty.hard,
    };
    final focus = <ExerciseFocus>{
      for (final area in profile.focusAreas)
        ...switch (area) {
          FocusArea.arms => {ExerciseFocus.arm},
          FocusArea.chest => {ExerciseFocus.chest},
          FocusArea.abs => {ExerciseFocus.abs},
          FocusArea.butt => {ExerciseFocus.glutes},
          FocusArea.legs => {ExerciseFocus.leg},
          FocusArea.fullBody => <ExerciseFocus>{},
        },
    };
    int score(TrainingWorkout workout) {
      var value = workout.difficulty == level ? 20 : 0;
      if (focus.isNotEmpty) {
        value +=
            100 * workout.focus.where(focus.contains).length ~/ focus.length;
        if (workout.focus.every(focus.contains)) value += 25;
      } else if (profile.focusAreas.contains(FocusArea.fullBody)) {
        value += workout.focus.length * 10;
      }
      final name = workout.title.toLowerCase();
      value += switch (profile.goal) {
        FitnessGoal.keepFit => workout.type != ExerciseType.training ? 60 : 0,
        FitnessGoal.loseWeight =>
          name.contains(RegExp('burn|hiit|tabata|shred|lose')) ? 60 : 0,
        FitnessGoal.endurance =>
          name.contains(RegExp('hiit|tabata|circuit|calisthenics')) ? 60 : 0,
        FitnessGoal.buildMuscle =>
          workout.type == ExerciseType.training ? 60 : 0,
        null => 0,
      };
      return value;
    }

    final candidates = trainingWorkouts
        .where((w) => w.difficulty.index <= level.index)
        .toList();
    candidates.sort((a, b) {
      final byScore = score(b).compareTo(score(a));
      return byScore != 0 ? byScore : a.id.compareTo(b.id);
    });
    return candidates;
  }
}
