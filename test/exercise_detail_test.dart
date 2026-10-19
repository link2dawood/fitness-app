import 'dart:io';
import 'dart:ui' as ui;
import 'package:fitness_pro/core/theme/app_theme.dart';
import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/data/models/exercise_guidance.dart';
import 'package:fitness_pro/views/workouts/exercise_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  if (const bool.fromEnvironment('EXPORT_DETAIL_PREVIEW')) {
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
    'All exercises have guidance and correct crunch-specific instructions',
    () {
      for (final exercise in exerciseCatalog) {
        final guidance = ExerciseGuidance.forExercise(exercise);
        expect(guidance.setup, isNotEmpty);
        expect(guidance.movement, isNotEmpty);
        expect(guidance.mistakes, hasLength(3));
        expect(guidance.breathing, isNotEmpty);
      }
      final crunch = exerciseCatalog.firstWhere(
        (e) => e.id == 'abdominal_crunches',
      );
      expect(
        ExerciseGuidance.forExercise(crunch).setup,
        contains('knees bent'),
      );
    },
  );
  testWidgets(
    'Details scroll through all sections and close without selection actions',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showExercisePreview(
                    context,
                    exerciseCatalog.firstWhere(
                      (e) => e.id == 'abdominal_crunches',
                    ),
                  ),
                  child: const Text('Open details'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open details'));
      await tester.pumpAndSettle();
      expect(find.text('REPEATS'), findsOneWidget);
      expect(find.text('×10'), findsOneWidget);
      expect(find.byType(Checkbox), findsNothing);
      if (const bool.fromEnvironment('EXPORT_DETAIL_PREVIEW')) {
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'build/exercise-previews/exercise-detail.png',
          ).writeAsBytes(png!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.scrollUntilVisible(find.text('BREATHING TIPS'), 350);
      expect(find.text('COMMON MISTAKES'), findsOneWidget);
      expect(find.text('BREATHING TIPS'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Open details'), findsOneWidget);
      expect(find.text('REPEATS'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
