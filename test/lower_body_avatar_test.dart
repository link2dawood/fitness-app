import 'dart:io';
import 'dart:ui' as ui;
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/widgets/exercises/challenge_avatar.dart';
import 'package:fitness_pro/widgets/exercises/exercise_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final workout = trainingWorkouts.singleWhere(
    (w) => w.id == 'lower_body_challenge',
  );
  testWidgets('Every Lower Body entry has a decodable realistic animation', (
    tester,
  ) async {
    expect(workout.exerciseIds, hasLength(8));
    await tester.runAsync(() async {
      for (final exercise in workout.exercises) {
        final mapping = challengeAvatarFrames[exercise.id]!;
        final codec = await ui.instantiateImageCodec(
          await File(
            'assets/images/challenge_avatars/atlas_${mapping.$1}.png',
          ).readAsBytes(),
        );
        final frame = await codec.getNextFrame();
        expect(frame.image.width, greaterThanOrEqualTo(1024));
        final count = referenceAvatarDurations.containsKey(exercise.id)
            ? 32
            : 8;
        for (var i = 0; i < count; i++) {
          expect(
            challengeAvatarFrameFor(exercise.id, i / count),
            inInclusiveRange(mapping.$2, mapping.$2 + count - 1),
          );
        }
        frame.image.dispose();
        codec.dispose();
      }
    });
    final left = challengeAvatarFrames['runners_lunge_left']!;
    final right = challengeAvatarFrames['runners_lunge_right']!;
    expect((left.$1, left.$2), (right.$1, right.$2));
    expect(left.$3, isFalse);
    expect(right.$3, isTrue);
  });
  testWidgets(
    'All Lower Body previews use realistic images and respect reduced motion',
    (tester) async {
      for (final exercise in workout.exercises) {
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
            AssetImage(
              'assets/images/challenge_avatars/atlas_${challengeAvatarFrames[exercise.id]!.$1}.png',
            ),
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
      await tester.pumpWidget(const SizedBox());
    },
  );
}
