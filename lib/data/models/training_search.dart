import 'exercise.dart';
import 'training_workout.dart';

class TrainingSearch {
  static List<TrainingWorkout> results({
    String query = '',
    ExerciseFocus? focus,
    ExerciseDifficulty? difficulty,
    ExerciseType? type,
    int? durationBand,
  }) {
    return trainingWorkouts.where((w) {
      final equipment = w.equipment.any(
        (e) => e != ExerciseEquipment.none && e != ExerciseEquipment.mat,
      );
      final fatBurning = w.title.toLowerCase().contains(
        RegExp('hiit|burn|shred|tabata|lose'),
      );
      final text =
          '${w.title} ${w.focus.map((e) => e.label).join(' ')} ${w.difficulty.label} ${w.difficulty == ExerciseDifficulty.easy
                  ? 'beginner'
                  : w.difficulty == ExerciseDifficulty.medium
                  ? 'intermediate'
                  : 'advanced'} ${w.type.label} ${w.type == ExerciseType.training ? (fatBurning ? 'burn fat' : 'build muscle') : 'keep fit'} ${w.type == ExerciseType.warmUp ? 'warm-up' : ''} ${equipment ? 'with equipment dumbbell' : 'no equipment'} ${w.exercises.map((e) => e.name).join(' ')}'
              .toLowerCase();
      final tokens = query
          .trim()
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((t) => t.isNotEmpty);
      final band = w.estimatedMinutes <= 10
          ? 0
          : w.estimatedMinutes <= 20
          ? 1
          : w.estimatedMinutes <= 30
          ? 2
          : 3;
      return tokens.every(text.contains) &&
          (focus == null || w.focus.contains(focus)) &&
          (difficulty == null || w.difficulty == difficulty) &&
          (type == null || w.type == type) &&
          (durationBand == null || durationBand == band);
    }).toList();
  }
}
