import 'dart:io';
import 'package:fitness_pro/data/models/extended_duration_workouts.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/views/search/search_view.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('>30 Mins reference order, counts, durations and artwork', () {
    expect(extendedDurationWorkoutIds, [
      'ultimate_full_body_builder',
      'arm_advanced',
      'intense_leg_transformation',
      'leg_intermediate',
      'elite_dumbbell_arms',
      'killer_core_hiit_intermediate',
      'leg_advanced',
      'killer_core_hiit_advanced',
    ]);
    expect(extendedDurationArtwork.values.toSet(), hasLength(8));
    final expected = <String, List<int>>{
      'ultimate_full_body_builder': [31, 25],
      'arm_advanced': [31, 28],
      'intense_leg_transformation': [31, 30],
      'leg_intermediate': [31, 36],
      'elite_dumbbell_arms': [33, 27],
      'killer_core_hiit_intermediate': [33, 37],
      'leg_advanced': [40, 43],
      'killer_core_hiit_advanced': [49, 53],
    };
    for (final workout in extendedDurationWorkouts) {
      final canonical = trainingWorkouts.singleWhere((w) => w.id == workout.id);
      expect(workout.exercises, isNotEmpty);
      expect(
        workout.estimatedMinutes,
        inInclusiveRange(31, 60),
        reason: workout.id,
      );
      expect(workout.exerciseIds, canonical.exerciseIds);
      expect(workout.targets, canonical.targets);
      expect(workout.progressStorageKey, canonical.progressStorageKey);
      expect(File(workout.image).existsSync(), isTrue);
    }
    for (final workout in extendedDurationWorkouts) {
      expect(
        [workout.estimatedMinutes, workout.exerciseIds.length],
        expected[workout.id],
        reason: workout.id,
      );
    }
  });
  testWidgets(
    'Duration badge opens the ordered list and every workout destination',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: const SearchView(),
        ),
      );
      await tester.pumpAndSettle();
      final badge = find.byKey(const ValueKey('search-duration->30'));
      await tester.ensureVisible(badge);
      await tester.pumpAndSettle();
      await tester.tap(badge);
      await tester.pumpAndSettle();
      final page = tester.widget<TrainingCollectionPage>(
        find.byType(TrainingCollectionPage),
      );
      expect(page.title, '>30 Mins');
      expect(page.workouts.map((w) => w.id), extendedDurationWorkoutIds);
      for (final workout in page.workouts) {
        final tile = find.byWidgetPredicate(
          (w) => w is TrainingWorkoutTile && w.workout.id == workout.id,
        );
        await tester.scrollUntilVisible(
          tile,
          120,
          scrollable: find
              .descendant(
                of: find.byType(TrainingCollectionPage),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        final image = tester.widget<Image>(
          find.descendant(of: tile, matching: find.byType(Image)),
        );
        final provider = image.image is ResizeImage
            ? (image.image as ResizeImage).imageProvider
            : image.image;
        expect(
          (provider as AssetImage).assetName,
          extendedDurationArtwork[workout.id],
        );
        await tester.tap(tile);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TrainingWorkoutPage>(find.byType(TrainingWorkoutPage))
              .workout
              .id,
          workout.id,
        );
        expect(find.text('Start workout'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    },
  );
}
