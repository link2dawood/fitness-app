import 'dart:io';
import 'dart:ui' as ui;
import 'package:fitness_pro/data/models/exercise_guidance.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/views/workouts/exercise_detail.dart';
import 'package:fitness_pro/widgets/exercises/challenge_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final workout = trainingWorkouts.singleWhere(
    (w) => w.id == 'lose_weight_for_men',
  );
  test(
    'Men reference preserves all 12 ordered sets and their units and targets',
    () {
      expect(workout.exerciseIds, [
        'mountain_climber_timed',
        'squats',
        'high_stepping',
        'reverse_crunches',
        'push_ups',
        'plank',
        'squats',
        'high_stepping',
        'reverse_crunches',
        'push_ups',
        'plank',
        'cobra_stretch',
      ]);
      expect(workout.targets, [30, 16, 30, 16, 10, 30, 16, 30, 16, 10, 30, 30]);
      expect(workout.exercises.map((e) => e.timed), [
        true,
        false,
        true,
        false,
        false,
        true,
        false,
        true,
        false,
        false,
        true,
        true,
      ]);
      for (var i = 0; i < 12; i++) {
        expect(workout.exerciseAt(i).target, workout.targetAt(i));
        final guidance = ExerciseGuidance.forExercise(workout.exerciseAt(i));
        expect(guidance.mistakes, hasLength(3));
        expect(guidance.setup, isNotEmpty);
        expect(guidance.movement, isNotEmpty);
        expect(guidance.breathing, isNotEmpty);
      }
      expect(workout.exerciseAt(1).target, 16);
      expect(
        workout.exercises[1].target,
        10,
        reason: 'Keep other workouts defaults',
      );
      expect(workout.progressStorageKey, 'workout_done_lose_weight_for_men_v2');
      expect(
        trainingWorkouts.first.progressStorageKey,
        'workout_done_${trainingWorkouts.first.id}',
      );
    },
  );

  testWidgets(
    'Every realistic atlas decodes and all 32 frames remain in bounds',
    (tester) async {
      await tester.runAsync(() async {
        for (final id in workout.exerciseIds.toSet()) {
          final atlas = challengeAvatarFrames[id]!.$1;
          final codec = await ui.instantiateImageCodec(
            await File(
              'assets/images/challenge_avatars/atlas_$atlas.png',
            ).readAsBytes(),
          );
          final frame = await codec.getNextFrame();
          expect(frame.image.width, 2560);
          expect(frame.image.height, 912);
          for (var i = 0; i < 32; i++) {
            expect(challengeAvatarFrameFor(id, i / 32), i);
          }
          expect(challengeAvatarFrameFor(id, 1), 31);
          frame.image.dispose();
          codec.dispose();
        }
      });
    },
  );

  testWidgets('Every reference exercise opens complete details at a narrow width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final font = File('C:/Windows/Fonts/arial.ttf');
    if (font.existsSync()) {
      await (FontLoader('Review')..addFont(
            Future.value(ByteData.sublistView(font.readAsBytesSync())),
          ))
          .load();
    }
    final icons = File(
      'C:/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (icons.existsSync()) {
      await (FontLoader('MaterialIcons')..addFont(
            Future.value(ByteData.sublistView(icons.readAsBytesSync())),
          ))
          .load();
    }
    for (final index in [0, 1, 2, 3, 4, 5, 11]) {
      final exercise = workout.exerciseAt(index);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(fontFamily: 'Review'),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              disableAnimations: true,
            ),
            child: Scaffold(
              body: RepaintBoundary(
                key: boundary,
                child: ColoredBox(
                  color: Colors.white,
                  child: ExerciseDetailCard(
                    key: ValueKey(index),
                    exercise: exercise,
                  ),
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
          tester.element(find.byType(ExerciseDetailCard)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(exercise.name.toUpperCase()), findsOneWidget);
      expect(
        find.text(
          exercise.timed ? '${exercise.target} seconds' : '×${exercise.target}',
        ),
        findsOneWidget,
      );
      if (index == 1 && const bool.fromEnvironment('EXPORT_MEN_PREVIEW')) {
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('build/men-reference').create(recursive: true);
          await File(
            'build/men-reference/details.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.tap(find.text('How to do'));
      await tester.pumpAndSettle();
      expect(
        find.text('1. ${ExerciseGuidance.forExercise(exercise).setup}'),
        findsOneWidget,
      );
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -2200),
      );
      await tester.pumpAndSettle();
      expect(find.text('BREATHING TIPS').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
  });
}
