import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fitness_pro/core/theme/app_theme.dart';
import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/views/workouts/exercise_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  if (const bool.fromEnvironment('EXPORT_FILTER_PREVIEW')) {
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
  test(
    'Filter categories combine with OR within and AND across categories',
    () {
      final wall = exerciseCatalog.firstWhere((e) => e.id == 'wall_push_ups');
      final filters = ExerciseFilters(
        focus: {ExerciseFocus.chest, ExerciseFocus.abs},
        difficulty: {ExerciseDifficulty.easy},
        type: {ExerciseType.training},
        equipment: {ExerciseEquipment.none},
      );
      expect(filters.matches(wall), isTrue);
      filters.difficulty.clear();
      filters.difficulty.add(ExerciseDifficulty.hard);
      expect(filters.matches(wall), isFalse);
      expect(exerciseCatalog.every(ExerciseFilters().matches), isTrue);
      final copy = filters.copy();
      copy.focus.clear();
      expect(filters.focus, hasLength(2));
      expect(
        exerciseCatalog.every(
          (e) => e.focus.isNotEmpty && e.equipment.isNotEmpty,
        ),
        isTrue,
      );
      expect(
        exerciseCatalog.any((e) => e.equipment.contains(ExerciseEquipment.mat)),
        isTrue,
      );
      expect(
        exerciseCatalog.any(
          (e) => e.equipment.contains(ExerciseEquipment.dumbbell),
        ),
        isTrue,
      );
      expect(
        exerciseCatalog.any((e) => e.focus.contains(ExerciseFocus.back)),
        isTrue,
      );
    },
  );

  testWidgets(
    'Filter draft counts, removals, cancel, and save are independent',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      ExerciseFilters current = ExerciseFilters();
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  child: const Text('Open'),
                  onPressed: () async {
                    final result = await showExerciseFilters(
                      context,
                      current,
                      query: 'wall',
                    );
                    if (result != null) current = result;
                  },
                ),
              ),
            ),
          ),
        ),
      );
      Future<void> open() async {
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
      }

      await open();
      await tester.tap(find.text('Chest'));
      await tester.pumpAndSettle();
      final expected = exerciseCatalog
          .where(
            (e) =>
                e.name.toLowerCase().contains('wall') &&
                e.focus.contains(ExerciseFocus.chest),
          )
          .length;
      expect(find.text('$expected exercises'), findsOneWidget);
      expect(find.byType(InputChip), findsOneWidget);
      if (const bool.fromEnvironment('EXPORT_FILTER_PREVIEW')) {
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('build/exercise-previews').create(recursive: true);
          await File(
            'build/exercise-previews/exercise-filters.png',
          ).writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(current.count, 0);
      await open();
      await tester.tap(find.text('Chest'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(current.focus, {ExerciseFocus.chest});
      await open();
      await tester.tap(
        find.descendant(
          of: find.byType(InputChip),
          matching: find.byIcon(Icons.cancel),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(InputChip), findsNothing);
      // Equipment controls remain reachable while actions stay fixed on screen.
      await tester.scrollUntilVisible(
        find.text('Mat'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Mat'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Clear all filters'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(current.count, 0);
      expect(tester.takeException(), isNull);
    },
  );
}
