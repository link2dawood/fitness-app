import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:fitness_pro/widgets/workout_session_view.dart';
import 'calisthenics_workout_test.dart' show CalisthenicsClock;

void main() {
  setUpAll(() async {
    await (FontLoader('MaterialIcons')..addFont(
          Future.value(
            ByteData.sublistView(
              File(
                'C:/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
              ).readAsBytesSync(),
            ),
          ),
        ))
        .load();
    final font = File('C:/Windows/Fonts/arial.ttf');
    await (FontLoader('SessionTest')
          ..addFont(Future.value(ByteData.sublistView(font.readAsBytesSync()))))
        .load();
  });
  testWidgets(
    'Ready, pause, automatic rest, extra rest, editor and skip use the same clock',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'settings_prep': 5,
        'settings_rest_mode': 'Custom',
        'settings_rest_seconds': 30,
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final base = trainingWorkouts.first;
      final workout = TrainingWorkout(
        id: 'video_flow_test',
        title: 'Video flow',
        difficulty: base.difficulty,
        type: base.type,
        image: base.image,
        exerciseIds: base.exerciseIds.take(2).toList(),
        targets: const [2, 3],
        timedExercises: true,
      );
      final clocks = <CalisthenicsClock>[];
      final boundary = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(fontFamily: 'SessionTest'),
          home: RepaintBoundary(
            key: boundary,
            child: TrainingSessionPage(
              workout: workout,
              createStopwatch: () {
                final clock = CalisthenicsClock();
                clocks.add(clock);
                return clock;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('READY TO GO!'), findsOneWidget);
      Future<void> advance(int seconds) async {
        for (final clock in clocks) {
          clock.advance(seconds);
        }
        await tester.pump(const Duration(milliseconds: 250));
      }

      Future<void> capture(String name) async {
        if (!const bool.fromEnvironment('EXPORT_SESSION_PREVIEWS')) return;
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 250)),
        );
        await tester.pump();
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File('build/video_reference/$name.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('ready');
      await tester.tap(find.text('Pause'));
      await advance(8);
      expect(
        tester
            .widget<WorkoutSessionView>(find.byType(WorkoutSessionView))
            .remaining,
        5,
      );
      await tester.tap(find.text('Resume'));
      await advance(5);
      expect(find.text('READY TO GO!'), findsNothing);
      await capture('active');
      await advance(2);
      expect(find.text('REST'), findsOneWidget);
      await tester.tap(find.text('+20s'));
      await tester.pump();
      expect(
        tester
            .widget<WorkoutSessionView>(find.byType(WorkoutSessionView))
            .remaining,
        50,
      );
      await capture('rest');
      await tester.tap(find.text('Edit Rest Time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Longer rest'));
      await tester.tap(find.text('Done'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        tester
            .widget<WorkoutSessionView>(find.byType(WorkoutSessionView))
            .remaining,
        35,
      );
      await tester.tap(find.text('Skip'));
      await tester.pump();
      expect(find.text('REST'), findsNothing);
      expect(
        tester
            .widget<WorkoutSessionView>(find.byType(WorkoutSessionView))
            .index,
        1,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final size in [const Size(320, 640), const Size(844, 390)]) {
    testWidgets('Session fits $size with large text', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final exercise = trainingWorkouts.first.exercises.first;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(fontFamily: 'SessionTest'),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: WorkoutSessionView(
            exercise: exercise,
            index: 0,
            count: 12,
            remaining: 30,
            target: 30,
            preparing: false,
            resting: true,
            paused: true,
            onExit: () {},
            onPause: () {},
            onNext: () {},
            onDetails: () {},
            onAddRest: () {},
            onEditRest: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
