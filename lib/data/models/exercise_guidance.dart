import 'exercise.dart';

/// Original coaching cues shared by movement families, plus catalog-specific
/// movement descriptions. This does not describe the artwork as instructions.
class ExerciseGuidance {
  const ExerciseGuidance(
    this.setup,
    this.movement,
    this.mistakes,
    this.breathing,
  );
  final String setup;
  final String movement;
  final List<String> mistakes;
  final String breathing;

  static ExerciseGuidance forExercise(ExerciseDefinition exercise) {
    final name = exercise.name.toLowerCase();
    if (exercise.id == 'abdominal_crunches') {
      return const ExerciseGuidance(
        'Lie on your back with knees bent and feet on the floor. Reach your arms forward.',
        'Gently tighten your abdomen and lift your shoulders off the floor. Lower slowly and repeat.',
        [
          'Pulling on your neck instead of lifting with your abdomen.',
          'Using momentum or lifting your whole back off the floor.',
          'Rushing the lowering phase.',
        ],
        'Breathe out as you curl up and breathe in as you lower.',
      );
    }
    if (name.contains('push-up') || name.contains('push up')) {
      return const ExerciseGuidance(
        'Place your hands on the support shown in the demonstration. Align your shoulders, hips, and knees or feet.',
        'Bend your elbows to lower your chest toward the support, then press back to the starting position.',
        [
          'Letting your hips sag or lifting them ahead of your chest.',
          'Shrugging your shoulders toward your ears.',
          'Dropping quickly instead of lowering with control.',
        ],
        'Breathe in as you lower and breathe out as you press away.',
      );
    }
    if (name.contains('squat') || name.contains('lunge')) {
      return const ExerciseGuidance(
        'Start with stable footing and use the stance and support shown in the demonstration.',
        'Bend at your hips and knees through a comfortable range. Press through your supporting foot to return; follow the named side or step pattern.',
        [
          'Allowing your knees to collapse inward.',
          'Losing balance or lifting the supporting heel.',
          'Rushing into a deeper position than you can control.',
        ],
        'Breathe in as you lower and breathe out as you rise.',
      );
    }
    if (name.contains('plank') || name.contains('climber')) {
      return const ExerciseGuidance(
        'Set your hands or forearms under your shoulders as shown. Brace your abdomen and keep your neck aligned with your spine.',
        'Maintain a steady trunk while performing the arm or leg movement shown. For a static plank, hold the position for the displayed time.',
        [
          'Letting the lower back sag.',
          'Rocking your hips while moving your limbs.',
          'Holding your breath or shrugging your shoulders.',
        ],
        'Breathe steadily throughout the hold; breathe out during the moving effort.',
      );
    }
    if (exercise.type == ExerciseType.stretch) {
      return const ExerciseGuidance(
        'Settle into the starting position shown and use any indicated wall or support for balance.',
        'Move gently into a comfortable stretch. Follow the named side and return slowly; avoid forcing the range or bouncing.',
        [
          'Bouncing or forcing the stretch.',
          'Twisting away from the intended position.',
          'Holding your breath or tensing your shoulders.',
        ],
        'Take slow, even breaths as you ease into the stretch.',
      );
    }
    if (name.contains('crunch') ||
        name.contains('sit-up') ||
        name.contains('v-up')) {
      return const ExerciseGuidance(
        'Lie on a comfortable surface in the starting position shown, keeping your neck relaxed.',
        'Tighten your abdomen and follow the demonstrated curl or leg movement. Return with control, using the named side where applicable.',
        [
          'Pulling the head forward with the hands.',
          'Swinging the arms or legs to gain momentum.',
          'Dropping back down without control.',
        ],
        'Breathe out during the curl or lift and breathe in as you return.',
      );
    }
    if (name.contains('bridge') ||
        name.contains('glute') ||
        name.contains('donkey')) {
      return const ExerciseGuidance(
        'Use the starting position and support shown. Keep your trunk steady and use the indicated side.',
        'Move from your hip and gently squeeze your glutes during the lift. Return slowly without arching your lower back.',
        [
          'Overarching the lower back to lift higher.',
          'Turning the hips away from the starting position.',
          'Swinging the working leg instead of controlling it.',
        ],
        'Breathe out as you lift and breathe in as you return.',
      );
    }
    if (exercise.equipment.contains(ExerciseEquipment.dumbbell)) {
      return const ExerciseGuidance(
        'Take a stable stance or supported position as shown. Use weights you can move with control and keep a secure grip.',
        'Follow the demonstrated path while keeping your trunk steady. Lift and lower smoothly without swinging the weights.',
        [
          'Using momentum to move the weights.',
          'Losing wrist alignment or shrugging the shoulders.',
          'Choosing a load that prevents controlled movement.',
        ],
        'Breathe out during the lifting effort and breathe in on the return.',
      );
    }
    return const ExerciseGuidance(
      'Take the starting position shown in the demonstration. Clear enough space and use any indicated support.',
      'Follow the movement described below at a controlled pace. Use the named side and repeat for the displayed reps or time.',
      [
        'Rushing and losing control of the movement.',
        'Forcing a range you cannot maintain comfortably.',
        'Holding your breath or adding unnecessary tension.',
      ],
      'Keep breathing evenly. Breathe out during the effort and breathe in as you return.',
    );
  }
}
