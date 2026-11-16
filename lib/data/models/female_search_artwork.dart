import 'exercise.dart';
import 'female_body_focus_artwork.dart';
import 'training_workout.dart';

/// Female imagery for workout cards reached from Search.
/// Exact Body Focus routines keep their individual photos; other routines use
/// a photo for their focus area and difficulty.
String femaleSearchArtwork(TrainingWorkout workout, {String? focusLabel}) {
  final exact = femaleBodyFocusArtwork[workout.id];
  if (exact != null) return exact;

  final name = workout.title.toLowerCase();
  final area = switch (focusLabel) {
    'Abs' => 'abs',
    'Arm' => 'arm',
    'Butt & Leg' => name.contains(RegExp('butt|booty|glute')) ? 'butt' : 'leg',
    'Chest' => 'chest',
    'Back' || 'Shoulder' => 'shoulder_back',
    _ =>
      name.contains('forearm')
          ? 'forearm'
          : name.contains(RegExp('butt|booty|glute'))
          ? 'butt'
          : name.contains(RegExp('leg|quad|squat'))
          ? 'leg'
          : name.contains(RegExp('shoulder|back'))
          ? 'shoulder_back'
          : name.contains(RegExp('arm|tricep|bicep'))
          ? 'arm'
          : name.contains('chest')
          ? 'chest'
          : name.contains(RegExp('abs|belly|core|six pack'))
          ? 'abs'
          : workout.focus.length == 1
          ? switch (workout.focus.first) {
              ExerciseFocus.abs => 'abs',
              ExerciseFocus.arm => 'arm',
              ExerciseFocus.chest => 'chest',
              ExerciseFocus.leg => 'leg',
              ExerciseFocus.glutes => 'butt',
              ExerciseFocus.shoulder || ExerciseFocus.back => 'shoulder_back',
            }
          : null,
  };
  if (area == null) return 'assets/images/body/fullbody_female.png';

  final level = switch (workout.difficulty) {
    ExerciseDifficulty.easy => 'beginner',
    ExerciseDifficulty.medium => 'intermediate',
    ExerciseDifficulty.hard => 'advanced',
  };
  return femaleBodyFocusArtwork['${area}_$level']!;
}
