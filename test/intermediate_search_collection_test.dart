import 'dart:io';
import 'package:fitness_pro/data/models/intermediate_workouts.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/views/search/search_view.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'Intermediate includes all 32 screenshot entries in order with unique artwork and stable progress',
    () {
      expect(intermediateWorkoutIds, [
        'abs_intermediate',
        'arm_intermediate',
        'chest_intermediate',
        'leg_intermediate',
        'shoulder_back_intermediate',
        '6_min_tabata',
        'arm_building_circuit',
        'arm_workout_no_push_ups',
        'athletes_choice_at_home',
        'belly_fat_burner_hiit_intermediate',
        'bubble_butt_workout',
        'build_wider_shoulders_intermediate',
        'burn_100_calories',
        'shred_your_quads',
        'butt_blaster_challenge',
        'defined_arms_with_dumbbells',
        'dumbbell_abs_shaper',
        'dumbbell_workout_at_home',
        'fat_burning_hiit',
        'man_boobs_hiit_intermediate',
        'hiit_intermediate',
        'intense_leg_power_challenge',
        'killer_chest_routine',
        'killer_core_hiit_intermediate',
        'last_longer_in_bed',
        'lower_body_strength',
        'lose_fat_no_jumping',
        'plank_challenge',
        'quick_bigger_chest_building',
        'ripped_v_cut_abs_intermediate',
        'rounder_booty_shaping',
        'sculpted_arms_workout',
      ]);
      expect(intermediateWorkouts.map((w) => w.id).toSet(), hasLength(32));
      expect(intermediateArtwork.values.toSet(), hasLength(32));
      for (final workout in intermediateWorkouts) {
        final canonical = trainingWorkouts.singleWhere(
          (w) => w.id == workout.id,
        );
        expect(workout.exercises, isNotEmpty);
        expect(workout.progressStorageKey, canonical.progressStorageKey);
        expect(workout.exerciseIds, canonical.exerciseIds);
        expect(workout.targets, canonical.targets);
        expect(workout.difficulty, canonical.difficulty);
        expect(File(workout.image).existsSync(), isTrue, reason: workout.id);
      }
      for (final (id, count, minutes) in [
        ('athletes_choice_at_home', 25, 25),
        ('dumbbell_workout_at_home', 14, 16),
        ('butt_blaster_challenge', 25, 21),
        ('intense_leg_power_challenge', 25, 21),
        ('last_longer_in_bed', 12, 13),
        ('lower_body_strength', 27, 22),
      ]) {
        final w = intermediateWorkouts.singleWhere((w) => w.id == id);
        expect(w.exercises, hasLength(count));
        expect(w.targets, hasLength(count));
        expect(w.targets!.every((target) => target > 0), isTrue);
        expect(w.difficulty, ExerciseDifficulty.medium);
        expect(w.estimatedMinutes, minutes);
      }
      expect(
        intermediateWorkouts
            .singleWhere((w) => w.id == 'dumbbell_workout_at_home')
            .equipment,
        contains(ExerciseEquipment.dumbbell),
      );
      expect(
        intermediateWorkouts
            .singleWhere((w) => w.id == 'butt_blaster_challenge')
            .progressStorageKey,
        isNot(
          trainingWorkouts
              .singleWhere((w) => w.id == 'lower_body_challenge')
              .progressStorageKey,
        ),
      );
    },
  );
  Widget app(Widget home, {double scale = 1}) => MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(disableAnimations: true, textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: home,
  );
  testWidgets('Intermediate badge opens every routine with its mapped image', (
    tester,
  ) async {
    await tester.pumpWidget(app(const SearchView()));
    await tester.pumpAndSettle();
    final badge = find.byKey(const ValueKey('search-level-Intermediate'));
    await tester.ensureVisible(badge);
    await tester.pumpAndSettle();
    await tester.tap(badge);
    await tester.pumpAndSettle();
    final page = tester.widget<TrainingCollectionPage>(
      find.byType(TrainingCollectionPage),
    );
    expect(page.title, 'Intermediate');
    expect(page.workouts.map((w) => w.id), intermediateWorkoutIds);
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
        intermediateArtwork[workout.id],
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
  });
  testWidgets('Intermediate list fits a narrow screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      app(
        TrainingCollectionPage(
          title: 'Intermediate',
          workouts: intermediateWorkouts,
          artwork: intermediateArtwork,
        ),
        scale: 2,
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Sculpted Arms Workout'),
      160,
      maxScrolls: 120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
