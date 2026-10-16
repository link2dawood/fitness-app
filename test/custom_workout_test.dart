import 'dart:io';
import 'dart:ui' as ui;

import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/core/theme/app_theme.dart';
import 'package:fitness_pro/data/repositories/custom_workout_repository.dart';
import 'package:fitness_pro/views/home/pages/custom_workout_page.dart';
import 'package:fitness_pro/views/workouts/exercise_picker.dart';
import 'package:fitness_pro/widgets/exercises/exercise_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget app(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light,
  builder: (context, widget) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: widget!,
  ),
  home: child,
);

void main() {
  if (const bool.fromEnvironment('EXPORT_EXERCISE_PREVIEWS')) {
    setUpAll(() async {
      final text = FontLoader('Roboto')
        ..addFont(
          Future.value(
            ByteData.sublistView(
              File('C:/Windows/Fonts/arial.ttf').readAsBytesSync(),
            ),
          ),
        );
      final icons = FontLoader('MaterialIcons')
        ..addFont(
          Future.value(
            ByteData.sublistView(
              File(
                'C:/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
              ).readAsBytesSync(),
            ),
          ),
        );
      await text.load();
      await icons.load();
    });
  }
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'Every starter exercise has a unique original motion and default target',
    () {
      expect(exerciseCatalog.length, 11);
      expect(exerciseCatalog.map((exercise) => exercise.id).toSet().length, 11);
      expect(
        exerciseCatalog.map((exercise) => exercise.motion).toSet().length,
        11,
      );
      expect(
        exerciseCatalog.where((exercise) => exercise.recommended).length,
        5,
      );
    },
  );

  test(
    'Workout storage preserves order, duplicate exercises, and changes',
    () async {
      final repo = CustomWorkoutRepository();
      final now = DateTime.now().toUtc();
      final workout = CustomWorkout(
        id: 'morning',
        name: 'Morning Workout',
        difficulty: 'Beginner',
        createdAt: now,
        updatedAt: now,
        entries: const [
          WorkoutEntry(
            id: 'first',
            exerciseId: 'wall_push_ups',
            target: 10,
            restSeconds: 15,
          ),
          WorkoutEntry(
            id: 'second',
            exerciseId: 'wall_push_ups',
            target: 12,
            restSeconds: 20,
          ),
        ],
      );
      await repo.save(workout);
      final restored = (await repo.load()).single;
      expect(restored.entries.map((entry) => entry.id), ['first', 'second']);
      expect(restored.entries.last.target, 12);
      await repo.delete('morning');
      expect(await repo.load(), isEmpty);
    },
  );

  test('Corrupt saved workouts are not overwritten by a new save', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(CustomWorkoutRepository.key, 'invalid data');
    final now = DateTime.now().toUtc();
    await expectLater(
      CustomWorkoutRepository().save(
        CustomWorkout(
          id: 'x',
          name: 'Test',
          difficulty: 'Beginner',
          createdAt: now,
          updatedAt: now,
          entries: const [
            WorkoutEntry(id: 'one', exerciseId: 'punches', target: 20),
          ],
        ),
      ),
      throwsFormatException,
    );
    expect(prefs.getString(CustomWorkoutRepository.key), 'invalid data');
  });

  testWidgets('Exercise picker searches and can reset its body-area filter', (
    tester,
  ) async {
    List<ExerciseDefinition>? selected;
    await tester.pumpWidget(
      app(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => selected = await pickExercises(context),
              child: const Text('Open picker'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();
    expect(find.text('All Areas (11)'), findsOneWidget);
    await tester.tap(find.byTooltip('Filter body area'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abs'));
    await tester.pumpAndSettle();
    expect(find.text('Abs (2)'), findsOneWidget);
    await tester.tap(find.byTooltip('Filter body area'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All Areas'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'wall');
    await tester.pumpAndSettle();
    expect(find.text('WALL PUSH-UPS'), findsOneWidget);
    expect(find.text('PUNCHES'), findsNothing);
    await tester.tap(find.text('WALL PUSH-UPS'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add 1 exercise'));
    await tester.pumpAndSettle();
    expect(selected!.single.id, 'wall_push_ups');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Create a workout, add an exercise, save, and reopen it', (
    tester,
  ) async {
    await tester.pumpWidget(app(const CustomWorkoutPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create workout'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'My starter workout');
    await tester.tap(find.text('Choose exercises'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Exercises'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('WALL PUSH-UPS'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add 1 exercise'));
    await tester.pumpAndSettle();
    expect(find.text('Wall Push-ups'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      (await CustomWorkoutRepository().load()).single.entries.single.exerciseId,
      'wall_push_ups',
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app(const CustomWorkoutPage()));
    await tester.pumpAndSettle();
    expect(find.text('My starter workout'), findsOneWidget);
    await tester.tap(find.text('My starter workout'));
    await tester.pumpAndSettle();
    expect(find.text('Wall Push-ups'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'All original avatars paint at the start, middle, and end of a loop',
    (tester) async {
      for (final exercise in exerciseCatalog) {
        for (final pose in [0.0, .25, .5, .75, 1.0]) {
          await tester.pumpWidget(
            app(
              Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 240,
                    height: 240,
                    child: ExerciseAvatar(exercise: exercise, pose: pose),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(
            tester.takeException(),
            isNull,
            reason: '${exercise.name} at $pose',
          );
        }
      }
    },
  );

  testWidgets(
    'Timed values validate, reordering persists, and cancelling discards changes',
    (tester) async {
      final now = DateTime.now().toUtc();
      await CustomWorkoutRepository().save(
        CustomWorkout(
          id: 'editable',
          name: 'Editable workout',
          difficulty: 'Beginner',
          createdAt: now,
          updatedAt: now,
          entries: const [
            WorkoutEntry(id: 'punch', exerciseId: 'punches', target: 20),
            WorkoutEntry(id: 'wall', exerciseId: 'wall_push_ups', target: 10),
          ],
        ),
      );
      await tester.pumpWidget(app(const CustomWorkoutPage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editable workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Punches'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, '0');
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.text('Enter 1–3600.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).first, '35');
      await tester.enterText(find.byType(TextFormField).last, '0');
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      tester
          .widget<ReorderableListView>(find.byType(ReorderableListView))
          .onReorderItem!(0, 1);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final saved = (await CustomWorkoutRepository().load()).single;
      expect(saved.entries.map((entry) => entry.exerciseId), [
        'wall_push_ups',
        'punches',
      ]);
      expect(saved.entries.last.target, 35);
      expect(saved.entries.last.restSeconds, 0);
      await tester.tap(find.text('Editable workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Remove Wall Push-ups'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect((await CustomWorkoutRepository().load()).single.entries.length, 2);
      expect(tester.takeException(), isNull);
    },
  );

  if (const bool.fromEnvironment('EXPORT_EXERCISE_PREVIEWS')) {
    testWidgets('Export mobile workout-builder screens', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final now = DateTime.now().toUtc();
      await CustomWorkoutRepository().save(
        CustomWorkout(
          id: 'preview',
          name: 'Morning Starter',
          difficulty: 'Beginner',
          createdAt: now,
          updatedAt: now,
          entries: const [
            WorkoutEntry(id: 'wall', exerciseId: 'wall_push_ups', target: 10),
            WorkoutEntry(id: 'punch', exerciseId: 'punches', target: 20),
            WorkoutEntry(id: 'raise', exerciseId: 'side_arm_raise', target: 20),
          ],
        ),
      );
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(key: boundary, child: app(const CustomWorkoutPage())),
      );
      await tester.pumpAndSettle();
      Future<void> screenshot(String name) async {
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('build/exercise-previews').create(recursive: true);
          await File(
            'build/exercise-previews/$name.png',
          ).writeAsBytes(png!.buffer.asUint8List());
          image.dispose();
        });
      }

      await screenshot('saved-workouts');
      await tester.tap(find.text('Morning Starter'));
      await tester.pumpAndSettle();
      await screenshot('workout-builder');
      await tester.tap(find.text('Add Exercises'));
      await tester.pumpAndSettle();
      await screenshot('exercise-picker');
      expect(tester.takeException(), isNull);
    });
    testWidgets('Export original exercise motion previews', (tester) async {
      final boundary = GlobalKey();
      for (final exercise in exerciseCatalog) {
        for (var frame = 0; frame < 24; frame++) {
          await tester.pumpWidget(
            app(
              Scaffold(
                body: Center(
                  child: RepaintBoundary(
                    key: boundary,
                    child: SizedBox(
                      width: 320,
                      height: 320,
                      child: ExerciseAvatar(
                        exercise: exercise,
                        pose: frame / 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          await tester.runAsync(() async {
            final image =
                await (boundary.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary)
                    .toImage();
            final png = await image.toByteData(format: ui.ImageByteFormat.png);
            final dir = Directory('build/exercise-previews/${exercise.id}');
            await dir.create(recursive: true);
            await File(
              '${dir.path}/${frame.toString().padLeft(2, '0')}.png',
            ).writeAsBytes(png!.buffer.asUint8List());
            image.dispose();
          });
        }
      }
    });
  }
}
