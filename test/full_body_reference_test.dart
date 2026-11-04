import 'dart:io';
import 'dart:ui' as ui;
import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/data/models/exercise_guidance.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:fitness_pro/views/workouts/exercise_detail.dart';
import 'package:fitness_pro/widgets/exercises/challenge_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final workout = trainingWorkouts.singleWhere(
    (w) => w.id == 'full_body_challenge',
  );
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'Full Body Day 1 matches reference order and all twelve timed targets',
    () {
      expect(workout.exerciseIds, [
        'knee_to_elbow_crunches',
        'plie_squats',
        'squat_kicks',
        'incline_push_ups',
        'triceps_dips',
        'back_bow_pulls',
        'straight_arm_plank_to_pike',
        'leg_in_and_outs',
        'abdominal_crunches',
        'clasp_hands_behind_back',
        'right_quad_stretch_wall',
        'left_quad_stretch_wall',
      ]);
      expect(workout.exercises.every((e) => e.timed && e.target == 30), isTrue);
      expect(
        workout.estimatedMinutes,
        9,
      ); // Six active minutes plus existing rest.
      expect(workout.progressStorageKey, 'workout_done_full_body_challenge_v2');
      expect(exerciseById('plie_squats').timed, isFalse);
      expect(exerciseById('plie_squats').target, 10);
      for (var i = 0; i < 12; i++) {
        final e = workout.exerciseAt(i);
        expect(e.timed, isTrue);
        expect(e.target, 30);
        final g = ExerciseGuidance.forExercise(e);
        expect(g.setup, isNotEmpty);
        expect(g.movement, isNotEmpty);
        expect(g.mistakes, hasLength(3));
        expect(g.breathing, isNotEmpty);
      }
      expect(
        ExerciseGuidance.forExercise(workout.exercises[10]).movement,
        contains('right ankle'),
      );
      expect(
        ExerciseGuidance.forExercise(workout.exercises[11]).movement,
        contains('left ankle'),
      );
    },
  );
  testWidgets(
    'Each exercise has a decodable realistic atlas and valid frames',
    (tester) async {
      await tester.runAsync(() async {
        for (final e in workout.exercises) {
          final mapping = challengeAvatarFrames[e.id]!;
          final codec = await ui.instantiateImageCodec(
            await File(
              'assets/images/challenge_avatars/atlas_${mapping.$1}.png',
            ).readAsBytes(),
          );
          final frame = await codec.getNextFrame();
          expect(frame.image.width, frame.image.height);
          expect(frame.image.width, greaterThanOrEqualTo(1024));
          for (var i = 0; i < 8; i++) {
            expect(
              challengeAvatarFrameFor(e.id, i / 8),
              inInclusiveRange(mapping.$2, mapping.$2 + 7),
            );
          }
          frame.image.dispose();
          codec.dispose();
        }
      });
      expect(challengeAvatarFrames['left_quad_stretch_wall']!.$3, isTrue);
      expect(challengeAvatarFrames['right_quad_stretch_wall']!.$3, isFalse);
    },
  );
  Widget app(Widget child) => MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: child!,
    ),
    home: child,
  );
  testWidgets(
    'Challenge card list opens details with seconds instead of reps',
    (tester) async {
      await tester.pumpWidget(app(TrainingWorkoutPage(workout: workout)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Knee to Elbow Crunches'));
      await tester.pumpAndSettle();
      expect(find.byType(ExerciseDetailCard), findsOneWidget);
      expect(find.text('DURATION'), findsOneWidget);
      expect(find.text('REPEATS'), findsNothing);
      await tester.tap(find.text('How to do'));
      await tester.pumpAndSettle();
      expect(find.text('3. Continue for 30 seconds.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
