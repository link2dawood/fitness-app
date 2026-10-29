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
      expect(exerciseCatalog.length, 384);
      expect(
        exerciseCatalog.map((exercise) => exercise.id).toSet().length,
        384,
      );
      expect(
        exerciseCatalog.map((exercise) => exercise.motion).toSet().length,
        384,
      );
      expect(
        exerciseCatalog.where((exercise) => exercise.recommended).length,
        5,
      );
    },
  );

  test(
    'New video exercises retain their defaults when saved together',
    () async {
      final added = exerciseCatalog.skip(11).take(16).toList();
      expect(added.length, 16);
      expect(added.where((e) => e.timed).length, 6);
      for (final exercise in added) {
        expect(exercise.target, exercise.timed ? 20 : 10);
        expect(exercise.description, isNotEmpty);
      }
      final now = DateTime.now().toUtc();
      final workout = CustomWorkout(
        id: 'video-batch',
        name: 'Video exercises',
        difficulty: 'Beginner',
        createdAt: now,
        updatedAt: now,
        entries: [
          for (final e in added)
            WorkoutEntry(id: e.id, exerciseId: e.id, target: e.target),
        ],
      );
      final repo = CustomWorkoutRepository();
      await repo.save(workout);
      final saved = (await repo.load()).single;
      expect(saved.entries.map((e) => e.exerciseId), added.map((e) => e.id));
      expect(saved.entries.map((e) => e.target), added.map((e) => e.target));
      expect(
        saved.entries.map((e) => e.exercise.name),
        added.map((e) => e.name),
      );
    },
  );

  test(
    'Second video batch preserves side and timed variants in storage',
    () async {
      final batch = exerciseCatalog.skip(27).take(21).toList();
      expect(batch.length, 21);
      expect(batch.where((e) => e.timed).length, 6);
      for (final e in batch) {
        expect(e.target, e.timed ? 20 : 10);
      }
      expect(exerciseById('backward_lunge').timed, isFalse);
      expect(exerciseById('backward_lunge_timed').timed, isTrue);
      expect(exerciseById('butt_bridge').timed, isFalse);
      expect(exerciseById('butt_bridge_timed').timed, isTrue);
      final now = DateTime.now().toUtc();
      final repo = CustomWorkoutRepository();
      await repo.save(
        CustomWorkout(
          id: 'second-video',
          name: 'Second batch',
          difficulty: 'Beginner',
          createdAt: now,
          updatedAt: now,
          entries: [
            for (final e in batch)
              WorkoutEntry(id: e.id, exerciseId: e.id, target: e.target),
          ],
        ),
      );
      final restored = (await repo.load()).single;
      expect(
        restored.entries.map((e) => e.exercise.id),
        batch.map((e) => e.id),
      );
      expect(restored.entries.map((e) => e.target), batch.map((e) => e.target));
    },
  );

  test(
    'October 19 batch saves all 29 exercises with reference targets',
    () async {
      final batch = exerciseCatalog.skip(48).take(29).toList();
      expect(batch.length, 29);
      expect(batch.where((e) => e.timed).length, 16);
      for (final e in batch) {
        expect(e.target, e.timed ? 20 : 10);
      }
      final now = DateTime.now().toUtc();
      final repo = CustomWorkoutRepository();
      await repo.save(
        CustomWorkout(
          id: 'oct19',
          name: 'October 19',
          difficulty: 'Beginner',
          createdAt: now,
          updatedAt: now,
          entries: [
            for (final e in batch)
              WorkoutEntry(id: e.id, exerciseId: e.id, target: e.target),
          ],
        ),
      );
      final saved = (await repo.load()).single;
      expect(saved.entries.map((e) => e.exercise.id), batch.map((e) => e.id));
      expect(saved.entries.map((e) => e.target), batch.map((e) => e.target));
    },
  );

  test(
    'D and E video batch preserves defaults without duplicating Elbows Back',
    () async {
      final batch = exerciseCatalog.skip(77).take(31).toList();
      expect(batch.length, 31);
      expect(batch.where((e) => e.timed).length, 5);
      expect(exerciseCatalog.where((e) => e.name == 'Elbows Back').length, 1);
      for (final e in batch) {
        expect(e.target, e.timed ? 20 : 10);
      }
      final now = DateTime.now().toUtc();
      final repo = CustomWorkoutRepository();
      await repo.save(
        CustomWorkout(
          id: 'oct19-d',
          name: 'D and E batch',
          difficulty: 'Beginner',
          createdAt: now,
          updatedAt: now,
          entries: [
            for (final e in batch)
              WorkoutEntry(id: e.id, exerciseId: e.id, target: e.target),
          ],
        ),
      );
      final restored = (await repo.load()).single;
      expect(
        restored.entries.map((e) => e.exercise.id),
        batch.map((e) => e.id),
      );
      expect(restored.entries.map((e) => e.target), batch.map((e) => e.target));
    },
  );

  test('F to H batch saves 32 entries and reuses Forward Arm Swings', () async {
    final batch = exerciseCatalog.skip(108).take(32).toList();
    expect(batch.length, 32);
    expect(batch.where((e) => e.timed).length, 9);
    expect(
      exerciseCatalog.where((e) => e.name == 'Forward Arm Swings').length,
      1,
    );
    expect(exerciseById('glute_kickback_pulse_left').timed, isFalse);
    expect(exerciseById('donkey_kicks_left_pulse').timed, isTrue);
    for (final e in batch) {
      expect(e.target, e.timed ? 20 : 10);
    }
    final repo = CustomWorkoutRepository();
    final now = DateTime.now().toUtc();
    await repo.save(
      CustomWorkout(
        id: 'f-to-h',
        name: 'F to H',
        difficulty: 'Beginner',
        createdAt: now,
        updatedAt: now,
        entries: [
          for (final e in batch)
            WorkoutEntry(id: e.id, exerciseId: e.id, target: e.target),
        ],
      ),
    );
    final saved = (await repo.load()).single;
    expect(saved.entries.map((e) => e.exercise.id), batch.map((e) => e.id));
    expect(saved.entries.map((e) => e.target), batch.map((e) => e.target));
  });

  test('I to M batch keeps all 41 entries and timed squat variant', () async {
    final batch = exerciseCatalog.skip(140).take(41).toList();
    expect(batch.length, 41);
    expect(batch.where((e) => e.timed).length, 19);
    expect(exerciseById('jumping_squats').timed, isFalse);
    expect(exerciseById('jumping_squats_timed').timed, isTrue);
    for (final e in batch) {
      expect(e.target, e.timed ? 20 : 10);
    }
    final repo = CustomWorkoutRepository();
    final now = DateTime.now().toUtc();
    await repo.save(
      CustomWorkout(
        id: 'i-to-m',
        name: 'I to M',
        difficulty: 'Beginner',
        createdAt: now,
        updatedAt: now,
        entries: [
          for (final e in batch)
            WorkoutEntry(id: e.id, exerciseId: e.id, target: e.target),
        ],
      ),
    );
    final saved = (await repo.load()).single;
    expect(saved.entries.map((e) => e.exercise.id), batch.map((e) => e.id));
    expect(saved.entries.map((e) => e.target), batch.map((e) => e.target));
  });

  test('M to R batch saves 41 entries with separate timed variants', () async {
    final batch = exerciseCatalog.skip(181).take(41).toList();
    expect(batch.length, 41);
    expect(batch.where((e) => e.timed).length, 15);
    expect(exerciseCatalog.where((e) => e.name == 'Punches').length, 1);
    expect(exerciseById('mountain_climber_timed').timed, isTrue);
    expect(exerciseById('mountain_climber').timed, isFalse);
    expect(exerciseById('modified_burpees_timed').timed, isTrue);
    expect(exerciseById('modified_burpees').timed, isFalse);
    for (final e in batch) {
      expect(e.target, e.timed ? 20 : 10);
    }
    final repo = CustomWorkoutRepository();
    final now = DateTime.now().toUtc();
    await repo.save(
      CustomWorkout(
        id: 'm-to-r',
        name: 'M to R',
        difficulty: 'Beginner',
        createdAt: now,
        updatedAt: now,
        entries: [
          for (final e in batch)
            WorkoutEntry(id: e.id, exerciseId: e.id, target: e.target),
        ],
      ),
    );
    final saved = (await repo.load()).single;
    expect(saved.entries.map((e) => e.exercise.id), batch.map((e) => e.id));
    expect(saved.entries.map((e) => e.target), batch.map((e) => e.target));
  });

  test('R and S batch saves 81 entries and reuses Side Arm Raise', () async {
    final batch = exerciseCatalog.skip(222).take(81).toList();
    expect(batch.length, 81);
    expect(batch.where((e) => e.timed).length, 33);
    expect(exerciseCatalog.where((e) => e.name == 'Side Arm Raise').length, 1);
    expect(exerciseById('squat_pulses').target, 20);
    for (final e in batch) {
      expect(e.target, e.timed ? 20 : 10);
    }
    final repo = CustomWorkoutRepository();
    final now = DateTime.now().toUtc();
    await repo.save(
      CustomWorkout(
        id: 'r-and-s',
        name: 'R and S',
        difficulty: 'Beginner',
        createdAt: now,
        updatedAt: now,
        entries: [
          for (final e in batch)
            WorkoutEntry(id: e.id, exerciseId: e.id, target: e.target),
        ],
      ),
    );
    final saved = (await repo.load()).single;
    expect(saved.entries.map((e) => e.exercise.id), batch.map((e) => e.id));
    expect(saved.entries.map((e) => e.target), batch.map((e) => e.target));
  });

  test(
    'Final video batch saves 50 entries and confirms existing targets',
    () async {
      final batch = exerciseCatalog.skip(303).take(50).toList();
      expect(batch.length, 50);
      expect(batch.where((e) => e.timed).length, 23);
      expect(exerciseCatalog.where((e) => e.name == 'Wall Push-ups').length, 1);
      expect(exerciseCatalog.where((e) => e.name == 'Squat Pulses').length, 1);
      expect(exerciseById('squat_pulses').targetLabel(), '00:20');
      expect(
        exerciseById('slow_mountain_climber').animationDuration,
        exerciseById('mountain_climber').animationDuration * 2,
      );
      expect(exerciseById('spiderman_plank').timed, isFalse);
      expect(exerciseById('spiderman_plank_timed').timed, isTrue);
      expect(exerciseById('toy_soldiers').timed, isFalse);
      expect(exerciseById('toy_soldiers_timed').timed, isTrue);
      for (final e in batch) {
        expect(e.target, e.timed ? 20 : 10);
      }
      final repo = CustomWorkoutRepository();
      final now = DateTime.now().toUtc();
      await repo.save(
        CustomWorkout(
          id: 's-to-w',
          name: 'S to W',
          difficulty: 'Beginner',
          createdAt: now,
          updatedAt: now,
          entries: [
            for (final e in batch)
              WorkoutEntry(id: e.id, exerciseId: e.id, target: e.target),
          ],
        ),
      );
      final saved = (await repo.load()).single;
      expect(saved.entries.map((e) => e.exercise.id), batch.map((e) => e.id));
      expect(saved.entries.map((e) => e.target), batch.map((e) => e.target));
    },
  );

  testWidgets('Reused avatars switch between slow and normal playback', (
    tester,
  ) async {
    final selected = ValueNotifier(exerciseById('slow_mountain_climber'));
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: false),
          child: ValueListenableBuilder<ExerciseDefinition>(
            valueListenable: selected,
            builder: (context, exercise, child) => Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: ExerciseAvatar(
                  key: const ValueKey('reused-avatar'),
                  exercise: exercise,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    AnimationController controller() {
      final paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(ExerciseAvatar),
          matching: find.byType(CustomPaint),
        ),
      );
      return (paint.painter as dynamic).animation as AnimationController;
    }

    final original = controller();
    await tester.pump(const Duration(milliseconds: 1300));
    expect(original.value, closeTo(.25, .02));
    selected.value = exerciseById('mountain_climber');
    await tester.pump();
    expect(identical(original, controller()), isTrue);
    expect(controller().isAnimating, isTrue);
    await tester.pump(const Duration(milliseconds: 650));
    expect(controller().value, closeTo(.50, .02));
    await tester.pumpWidget(const SizedBox.shrink());
    selected.dispose();
    expect(tester.takeException(), isNull);
  });

  test(
    'W and X batch saves 13 entries with rep-based kickback holds',
    () async {
      final batch = exerciseCatalog.skip(353).take(13).toList();
      expect(batch.length, 13);
      expect(batch.where((e) => e.timed).length, 5);
      for (final id in [
        'wall_glute_kickback_left_hold',
        'wall_glute_kickback_right_hold',
      ]) {
        expect(exerciseById(id).timed, isFalse);
        expect(exerciseById(id).targetLabel(), 'x10');
      }
      for (final e in batch) {
        expect(e.target, e.timed ? 20 : 10);
      }
      final repo = CustomWorkoutRepository();
      final now = DateTime.now().toUtc();
      await repo.save(
        CustomWorkout(
          id: 'w-and-x',
          name: 'W and X',
          difficulty: 'Beginner',
          createdAt: now,
          updatedAt: now,
          entries: [
            for (final e in batch)
              WorkoutEntry(id: e.id, exerciseId: e.id, target: e.target),
          ],
        ),
      );
      final saved = (await repo.load()).single;
      expect(saved.entries.map((e) => e.exercise.id), batch.map((e) => e.id));
      expect(saved.entries.map((e) => e.target), batch.map((e) => e.target));
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
    expect(find.text('All Exercises (384)'), findsOneWidget);
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abs'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Filters (1)'), findsOneWidget);
    await tester.tap(find.text('Filters (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear all filters'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'wall');
    await tester.pumpAndSettle();
    expect(find.text('WALL PUSH-UPS'), findsOneWidget);
    expect(find.text('PUNCHES'), findsNothing);
    await tester.tap(find.text('WALL PUSH-UPS'));
    await tester.pumpAndSettle();
    expect(find.text('INSTRUCTIONS'), findsOneWidget);
    expect(find.text('Animation'), findsOneWidget);
    await tester.tap(find.text('Muscle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('How to do'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Checkbox>(find.byKey(const ValueKey('select_wall_push_ups')))
          .value,
      isFalse,
    );
    await tester.tap(find.byKey(const ValueKey('select_wall_push_ups')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('WALL PUSH-UPS'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close exercise details'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Checkbox>(find.byKey(const ValueKey('select_wall_push_ups')))
          .value,
      isTrue,
    );
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
    await tester.tap(find.byKey(const ValueKey('select_wall_push_ups')));
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
      for (final exercise
          in exerciseCatalog
              .skip(const int.fromEnvironment('EXPORT_EXERCISE_START'))
              .where(
                (exercise) =>
                    const String.fromEnvironment('EXPORT_EXERCISES').isEmpty ||
                    const String.fromEnvironment(
                      'EXPORT_EXERCISES',
                    ).split(',').contains(exercise.id),
              )) {
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
