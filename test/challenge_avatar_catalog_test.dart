import 'dart:io';
import 'dart:ui' as ui;
import 'package:fitness_pro/data/models/training_challenges.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/widgets/exercises/challenge_avatar.dart';
import 'package:fitness_pro/widgets/exercises/exercise_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final workouts = [
    ...TrainingChallenges.catalog.map((item) => item.workout),
    trainingWorkouts.singleWhere((w) => w.id == 'ripped_v_cut_abs_advanced'),
  ];
  test('All challenge exercises and customized abs have realistic frames', () {
    for (final workout in workouts) {
      for (final id in workout.exerciseIds.toSet()) {
        final mapping = challengeAvatarFrames[id];
        expect(mapping, isNotNull, reason: '${workout.id}: $id');
        expect(
          File(
            'assets/images/challenge_avatars/atlas_${mapping!.$1}.png',
          ).existsSync(),
          isTrue,
        );
        final count = referenceAvatarDurations.containsKey(id) ? 32 : 8;
        final frames = [
          for (var step = 0; step < 32; step++)
            challengeAvatarFrameFor(id, step / 32),
        ];
        expect(frames.toSet().length, greaterThan(1), reason: id);
        expect(
          frames.every(
            (frame) => frame >= mapping.$2 && frame < mapping.$2 + count,
          ),
          isTrue,
          reason: id,
        );
      }
    }
    for (final pair in [
      ('side_plank_left', 'side_plank_right'),
      ('glute_kickback_crossover_left', 'glute_kickback_crossover_right'),
      ('glute_kickback_pulse_left', 'glute_kickback_pulse_right'),
      ('side_lying_kickback_left', 'side_lying_kickback_right'),
      ('side_plank_knee_crunch_left', 'side_plank_knee_crunch_right'),
      ('dumbbell_woodchop_left', 'dumbbell_woodchop_right'),
    ]) {
      final left = challengeAvatarFrames[pair.$1]!;
      final right = challengeAvatarFrames[pair.$2]!;
      expect((left.$1, left.$2), (right.$1, right.$2));
      expect(left.$3, isFalse);
      expect(right.$3, isTrue);
    }
  });
  testWidgets('New realistic movements load and respect reduced motion', (
    tester,
  ) async {
    final exercises = {
      for (final workout in workouts)
        for (final exercise in workout.exercises)
          if (challengeAvatarFrames[exercise.id]!.$1 >= 30)
            exercise.id: exercise,
    };
    final decoded = <int>{};
    for (final exercise in exercises.values) {
      final atlas = challengeAvatarFrames[exercise.id]!.$1;
      final path = 'assets/images/challenge_avatars/atlas_$atlas.png';
      if (decoded.add(atlas)) {
        await tester.runAsync(() async {
          final codec = await ui.instantiateImageCodec(
            await File(path).readAsBytes(),
          );
          final frame = await codec.getNextFrame();
          expect(frame.image.width, frame.image.height);
          expect(frame.image.width, greaterThanOrEqualTo(1024));
          frame.image.dispose();
          codec.dispose();
        });
      }
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Center(
              child: SizedBox(
                width: 260,
                height: 260,
                child: ChallengeAvatar(
                  key: ValueKey(exercise.id),
                  exercise: exercise,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => precacheImage(
          AssetImage(path),
          tester.element(find.byType(ChallengeAvatar)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ExerciseAvatar), findsNothing, reason: exercise.id);
      final builder = tester.widget<AnimatedBuilder>(
        find.descendant(
          of: find.byType(ChallengeAvatar),
          matching: find.byType(AnimatedBuilder),
        ),
      );
      expect((builder.animation as AnimationController).isAnimating, isFalse);
      expect(tester.takeException(), isNull);
    }
    expect(decoded.length, greaterThanOrEqualTo(16));
    await tester.pumpWidget(const SizedBox());
  });
}
