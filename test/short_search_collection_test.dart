import 'dart:io';
import 'package:fitness_pro/data/models/short_workouts.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/views/search/search_view.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'Short collection matches the 16 reference workouts and the inclusive duration bound',
    () {
      expect(shortWorkoutIds, [
        'before_workout_warm_up',
        '6_min_tabata',
        '7_min_strong_arms',
        'beginner_chest_workout',
        'build_strong_triceps',
        '7_min_hiit_fat_burning',
        'beginner_arm_routine',
        '3_exercises_lose_belly_fat',
        '10_min_abs_workout',
        'butt_lift_rounder_booty',
        'chest_beginner',
        'killer_chest_routine',
        'morning_warm_up',
        'sculpted_arms_workout',
        '10_min_butt_workout',
        '10_min_leg_workout',
      ]);
      expect(shortWorkouts.map((w) => w.id).toSet(), hasLength(16));
      expect(shortWorkoutArtwork.values.toSet(), hasLength(16));
      for (final workout in shortWorkouts) {
        final canonical = trainingWorkouts.singleWhere(
          (w) => w.id == workout.id,
        );
        expect(workout.exercises, isNotEmpty);
        expect(
          workout.estimatedMinutes,
          inInclusiveRange(1, 10),
          reason: workout.id,
        );
        expect(workout.exerciseIds, canonical.exerciseIds);
        expect(workout.targets, canonical.targets);
        expect(workout.progressStorageKey, canonical.progressStorageKey);
        expect(File(workout.image).existsSync(), isTrue);
      }
      expect(
        shortWorkouts
            .singleWhere((w) => w.id == '10_min_butt_workout')
            .estimatedMinutes,
        10,
      );
    },
  );
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
      final badge = find.byKey(const ValueKey('search-duration-≤10'));
      await tester.ensureVisible(badge);
      await tester.pumpAndSettle();
      await tester.tap(badge);
      await tester.pumpAndSettle();
      final page = tester.widget<TrainingCollectionPage>(
        find.byType(TrainingCollectionPage),
      );
      expect(page.title, '≤10 Mins');
      expect(page.workouts.map((w) => w.id), shortWorkoutIds);
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
          shortWorkoutArtwork[workout.id],
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
