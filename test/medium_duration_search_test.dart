import 'dart:io';
import 'package:fitness_pro/data/models/medium_duration_workouts.dart';
import 'package:fitness_pro/data/models/short_workouts.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/data/repositories/training_history_repository.dart';
import 'package:fitness_pro/views/search/search_view.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Widget app(Widget home, {double scale = 1}) => MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(disableAnimations: true, textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: home,
  );
  test(
    '11–20 collection follows all 49 visible references and actual duration bounds',
    () {
      expect(mediumDurationWorkoutIds, [
        '10_min_shredded_arms',
        'abs_workout_no_crunch',
        'bigger_strong_quads_leg_workout',
        'full_body_stretching',
        'immunity_booster_at_home',
        'only_4_moves_for_abs',
        'quick_bigger_chest_building',
        '12_min_classic',
        'strong_legs_routine',
        'upper_body_stretching',
        'back_stretching',
        'fat_burning_hiit',
        'knee_pain_relief',
        'shape_and_tighten_butt',
        'butt_beginner',
        'build_wider_shoulders',
        'lower_back_pain_relief',
        'lower_body_stretching',
        'shoulder_back_beginner',
        'grow_taller_foundation',
        'height_starter',
        'forearm_beginner',
        'abs_beginner',
        'beginner_back_builder',
        'dumbbell_workout_at_home',
        'neck_shoulder_tension_relief',
        'ripped_v_cut_abs_beginner',
        'band_workout_at_home',
        'beginner_abs_shred',
        'build_wider_shoulders_intermediate',
        'easy_arm_workout_with_dumbbells',
        'man_boobs_hiit_beginner',
        'arm_beginner',
        'chest_advanced',
        'man_boobs_hiit_intermediate',
        'explosive_height_gains',
        '360_height_boost',
        'butt_intermediate',
        'arm_workout_no_push_ups',
        'shred_your_quads',
        'hiit_intermediate',
        'shoulder_back_intermediate',
        'forearm_foundation',
        'forearm_intermediate',
        'belly_fat_burner_hiit_beginner',
        'killer_core_hiit_beginner',
        'lose_fat_no_jumping',
        'rounder_booty_shaping',
        'stay_in_shape_at_home',
      ]);
      expect(mediumDurationWorkoutIds.toSet(), hasLength(49));
      expect(mediumDurationArtwork.values.toSet(), hasLength(49));
      expect(
        mediumDurationWorkoutIds.toSet().intersection(shortWorkoutIds.toSet()),
        isEmpty,
      );
      for (final workout in mediumDurationWorkouts) {
        final canonical = trainingWorkouts.singleWhere(
          (w) => w.id == workout.id,
        );
        expect(
          workout.estimatedMinutes,
          inInclusiveRange(11, 20),
          reason: workout.id,
        );
        expect(
          workout.targets,
          hasLength(workout.exercises.length),
          reason: workout.id,
        );
        expect(workout.targets!.every((target) => target > 0), isTrue);
        expect(workout.progressStorageKey, canonical.progressStorageKey);
        expect(workout.exerciseIds, canonical.exerciseIds);
        expect(File(workout.image).existsSync(), isTrue, reason: workout.id);
      }
      for (final (id, minutes) in [
        ('grow_taller_foundation', 16),
        ('height_starter', 16),
        ('explosive_height_gains', 19),
        ('360_height_boost', 19),
      ]) {
        final w = mediumDurationWorkouts.singleWhere((w) => w.id == id);
        expect(w.exercises, hasLength(22));
        expect(w.estimatedMinutes, minutes);
      }
    },
  );
  testWidgets(
    'Duration badge opens all 49 correct workout destinations and thumbnails',
    (tester) async {
      await tester.pumpWidget(app(const SearchView()));
      await tester.pumpAndSettle();
      final badge = find.byKey(const ValueKey('search-duration-11-20'));
      await tester.ensureVisible(badge);
      await tester.pumpAndSettle();
      await tester.tap(badge);
      await tester.pumpAndSettle();
      final page = tester.widget<TrainingCollectionPage>(
        find.byType(TrainingCollectionPage),
      );
      expect(page.title, '11–20 Mins');
      expect(page.workouts.map((w) => w.id), mediumDurationWorkoutIds);
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
          mediumDurationArtwork[workout.id],
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
  testWidgets(
    'Expanded routines isolate old set indices and retain recorded history',
    (tester) async {
      final workout = trainingWorkouts.singleWhere(
        (w) => w.id == 'abs_beginner',
      );
      expect(workout.planVersion, greaterThan(1));
      final oldKey = 'workout_done_abs_beginner';
      SharedPreferences.setMockInitialValues({
        oldKey: ['0', '1'],
      });
      final repository = TrainingHistoryRepository.instance;
      await repository.load();
      await repository.complete(
        TrainingCompletion(
          id: 'legacy-abs',
          workoutId: workout.id,
          title: workout.title,
          finishedAt: DateTime(2026, 11, 1),
          seconds: 240,
        ),
      );
      await tester.pumpWidget(app(TrainingWorkoutPage(workout: workout)));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Mark as incomplete'), findsNothing);
      await tester.tap(find.byTooltip('Mark as completed').first);
      await tester.pumpAndSettle();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(oldKey), ['0', '1']);
      expect(prefs.getStringList(workout.progressStorageKey), ['0']);
      expect(repository.entries.map((e) => e.id), contains('legacy-abs'));
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('Long duration collection remains scrollable with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      app(
        TrainingCollectionPage(
          title: '11–20 Mins',
          workouts: mediumDurationWorkouts,
          artwork: mediumDurationArtwork,
        ),
        scale: 2,
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Stay in Shape at Home'),
      180,
      maxScrolls: 160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
