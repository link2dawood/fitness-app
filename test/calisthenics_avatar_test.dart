import 'dart:io';
import 'dart:ui' as ui;

import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/widgets/exercises/challenge_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final workout = trainingWorkouts.singleWhere(
    (workout) => workout.id == 'calisthenics_plan',
  );

  test('All 22 Calisthenics entries have valid looping frame mappings', () {
    expect(workout.exerciseIds.length, 22);
    for (final id in workout.exerciseIds) {
      final mapping = challengeAvatarFrames[id]!;
      expect(
        File(
          'assets/images/challenge_avatars/atlas_${mapping.$1}.png',
        ).existsSync(),
        isTrue,
      );
      final frames = [
        for (var i = 0; i < 8; i++) challengeAvatarFrameFor(id, i / 8),
      ];
      expect(
        frames.every((frame) => frame >= mapping.$2 && frame < mapping.$2 + 8),
        isTrue,
      );
      expect(frames.toSet().length, greaterThan(1));
    }
    for (final pair in [
      ('standing_hip_rotations_left', 'standing_hip_rotations_right'),
      ('left_pivot_step_lunge', 'right_pivot_step_lunge'),
      ('hip_flexor_stretch_left', 'hip_flexor_stretch_right'),
    ]) {
      final left = challengeAvatarFrames[pair.$1]!;
      final right = challengeAvatarFrames[pair.$2]!;
      expect((left.$1, left.$2), (right.$1, right.$2));
      expect(left.$3, isFalse);
      expect(right.$3, isTrue);
    }
  });

  testWidgets('New atlases decode and playback repeats, pauses and resumes', (
    tester,
  ) async {
    await tester.runAsync(() async {
      for (var atlas = 6; atlas <= 13; atlas++) {
        final codec = await ui.instantiateImageCodec(
          await File(
            'assets/images/challenge_avatars/atlas_$atlas.png',
          ).readAsBytes(),
        );
        final frame = await codec.getNextFrame();
        expect(frame.image.width, frame.image.height);
        expect(frame.image.width, greaterThanOrEqualTo(1024));
        frame.image.dispose();
        codec.dispose();
      }
    });
    Widget app({
      bool animate = true,
      bool reduced = false,
      bool ticker = true,
    }) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: TickerMode(
          enabled: ticker,
          child: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: ChallengeAvatar(
                exercise: workout.exercises.first,
                animate: animate,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(app());
    await tester.runAsync(
      () => precacheImage(
        const AssetImage('assets/images/challenge_avatars/atlas_6.png'),
        tester.element(find.byType(ChallengeAvatar)),
      ),
    );
    await tester.pump();
    final builder = tester.widget<AnimatedBuilder>(
      find
          .descendant(
            of: find.byType(ChallengeAvatar),
            matching: find.byType(AnimatedBuilder),
          )
          .first,
    );
    final controller = builder.animation as AnimationController;
    expect(controller.isAnimating, isTrue);
    await tester.pump(const Duration(milliseconds: 400));
    final before = controller.value;
    await tester.pump(const Duration(milliseconds: 400));
    expect(controller.value, isNot(before));
    await tester.pump(const Duration(seconds: 6));
    expect(controller.isAnimating, isTrue);
    await tester.pumpWidget(app(animate: false));
    expect(controller.isAnimating, isFalse);
    final paused = controller.value;
    await tester.pump(const Duration(seconds: 1));
    expect(controller.value, paused);
    await tester.pumpWidget(app(reduced: true));
    expect(controller.isAnimating, isFalse);
    await tester.pumpWidget(app(ticker: false));
    expect(controller.isAnimating, isFalse);
    await tester.pumpWidget(app());
    expect(controller.isAnimating, isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(controller.isAnimating, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(controller.isAnimating, isTrue);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
