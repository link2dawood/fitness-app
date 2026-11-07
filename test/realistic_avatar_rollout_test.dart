import 'dart:io';
import 'dart:ui' as ui;
import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/data/models/realistic_avatar_frames.dart';
import 'package:fitness_pro/widgets/exercises/challenge_avatar.dart';
import 'package:fitness_pro/widgets/exercises/exercise_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'All catalog exercises have bundled realistic images and valid pose ranges',
    () {
      final ids = exerciseCatalog.map((e) => e.id).toSet();
      expect(ids, containsAll(additionalAvatarFrames.keys));
      expect(challengeAvatarFrames.keys, containsAll(ids));
      for (final id in ids) {
        final mapping = challengeAvatarFrames[id]!;
        expect(
          File(
            'assets/images/challenge_avatars/atlas_${mapping.$1}.png',
          ).existsSync(),
          isTrue,
          reason: id,
        );
        final count = realisticAvatarFrameCountFor(id);
        expect(mapping.$2 % count, 0, reason: id);
        expect(
          mapping.$2 + count,
          lessThanOrEqualTo(count == 32 ? 32 : 16),
          reason: id,
        );
        final frames = [
          for (var step = 0; step < 64; step++)
            challengeAvatarFrameFor(id, step / 64),
        ];
        expect(
          frames.every(
            (frame) => frame >= mapping.$2 && frame < mapping.$2 + count,
          ),
          isTrue,
          reason: id,
        );
        expect(frames.toSet().length, greaterThan(1), reason: id);
      }
    },
  );
  testWidgets(
    'Every installed catalog sheet decodes and renders without illustrated fallback',
    (tester) async {
      final examples = <int, String>{};
      for (final exercise in exerciseCatalog) {
        final mapping = challengeAvatarFrames[exercise.id]!;
        examples.putIfAbsent(mapping.$1, () => exercise.id);
      }
      for (final entry in examples.entries) {
        final path = 'assets/images/challenge_avatars/atlas_${entry.key}.png';
        await tester.runAsync(() async {
          final codec = await ui.instantiateImageCodec(
            await File(path).readAsBytes(),
          );
          final frame = await codec.getNextFrame();
          expect(frame.image.width, greaterThanOrEqualTo(1024));
          if (referenceAvatarDurations.containsKey(entry.value)) {
            expect(frame.image.height, greaterThanOrEqualTo(512));
          } else {
            expect(frame.image.width, frame.image.height);
          }
          frame.image.dispose();
          codec.dispose();
        });
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: SizedBox(
                width: 260,
                height: 260,
                child: ChallengeAvatar(
                  key: ValueKey(entry.value),
                  exercise: exerciseById(entry.value),
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
        expect(find.byType(ExerciseAvatar), findsNothing, reason: entry.value);
        expect(
          find.byTooltip('Reload realistic avatar'),
          findsNothing,
          reason: entry.value,
        );
        expect(
          find.descendant(
            of: find.byType(ChallengeAvatar),
            matching: find.byType(AnimatedBuilder),
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    },
  );
}
