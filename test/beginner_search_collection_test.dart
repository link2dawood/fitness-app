import 'dart:io';
import 'package:fitness_pro/data/models/beginner_workouts.dart';
import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/views/search/search_view.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:fitness_pro/widgets/exercises/exercise_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'Beginner includes all 46 reference workouts in order with unique bundled artwork',
    () {
      expect(beginnerWorkoutIds, [
        'abs_beginner',
        'arm_beginner',
        'chest_beginner',
        'leg_beginner',
        'shoulder_back_beginner',
        '3_exercises_lose_belly_fat',
        '10_min_abs_workout',
        '10_min_butt_workout',
        '12_min_classic',
        '7_min_hiit_fat_burning',
        '10_min_leg_workout',
        '10_min_shredded_arms',
        '7_min_strong_arms',
        'abs_workout_no_crunch',
        'back_stretching',
        'band_workout_at_home',
        'before_workout_warm_up',
        'beginner_abs_shred',
        'beginner_back_builder',
        'beginner_chest_workout',
        'beginner_core_workout',
        'beginner_push_up',
        'belly_fat_burner_hiit_beginner',
        'bigger_strong_quads_leg_workout',
        'build_wider_shoulders',
        'butt_lift_rounder_booty',
        'easy_arm_workout_with_dumbbells',
        'full_body_stretching',
        'beginner_arm_routine',
        'build_strong_triceps',
        'man_boobs_hiit_beginner',
        'immunity_booster_at_home',
        'killer_core_hiit_beginner',
        'knee_pain_relief',
        'leg_workout_no_jumping',
        'lower_back_pain_relief',
        'lower_body_stretching',
        'morning_warm_up',
        'neck_shoulder_tension_relief',
        'only_4_moves_for_abs',
        'ripped_v_cut_abs_beginner',
        'shape_and_tighten_butt',
        'shoulder_tension_relief',
        'sleepy_time_stretching',
        'strong_legs_routine',
        'upper_body_stretching',
      ]);
      expect(beginnerWorkouts.map((w) => w.id).toSet(), hasLength(46));
      expect(beginnerArtwork.values.toSet(), hasLength(46));
      for (final w in beginnerWorkouts) {
        final canonical = trainingWorkouts.singleWhere(
          (entry) => entry.id == w.id,
        );
        expect(w.progressStorageKey, canonical.progressStorageKey);
        expect(w.exerciseIds, canonical.exerciseIds);
        expect(w.targets, canonical.targets);
        expect(w.difficulty, canonical.difficulty);
        expect(w.exercises, isNotEmpty);
        expect(w.estimatedMinutes, greaterThan(0));
        expect(File(beginnerArtwork[w.id]!).existsSync(), isTrue, reason: w.id);
      }
      final noCrunch = beginnerWorkouts.singleWhere(
        (w) => w.id == 'abs_workout_no_crunch',
      );
      expect(
        noCrunch.exercises.any((e) => e.name.toLowerCase().contains('crunch')),
        isFalse,
      );
      final noJump = beginnerWorkouts.singleWhere(
        (w) => w.id == 'leg_workout_no_jumping',
      );
      expect(
        noJump.exercises.any(
          (e) =>
              RegExp('jump|hop|burpee', caseSensitive: false).hasMatch(e.name),
        ),
        isFalse,
      );
      final band = beginnerWorkouts.singleWhere(
        (w) => w.id == 'band_workout_at_home',
      );
      expect(band.equipment, contains(ExerciseEquipment.band));
      for (final (id, count, minutes) in [
        ('10_min_butt_workout', 12, 10),
        ('abs_workout_no_crunch', 12, 11),
        ('band_workout_at_home', 16, 17),
        ('beginner_core_workout', 14, 13),
        ('beginner_push_up', 11, 10),
        ('immunity_booster_at_home', 13, 11),
        ('leg_workout_no_jumping', 13, 13),
        ('shape_and_tighten_butt', 15, 14),
      ]) {
        final w = beginnerWorkouts.singleWhere((w) => w.id == id);
        expect(w.targets, hasLength(count));
        expect(w.targets!.every((target) => target > 0), isTrue);
        expect(w.estimatedMinutes, minutes);
      }
    },
  );

  Widget app(Widget home) => MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: child!,
    ),
    home: home,
  );

  testWidgets('Beginner badge opens every workout using its own thumbnail', (
    tester,
  ) async {
    await tester.pumpWidget(app(const SearchView()));
    await tester.pumpAndSettle();
    final badge = find.byKey(const ValueKey('search-level-Beginner'));
    await tester.ensureVisible(badge);
    await tester.pumpAndSettle();
    await tester.tap(badge);
    await tester.pumpAndSettle();
    final page = tester.widget<TrainingCollectionPage>(
      find.byType(TrainingCollectionPage),
    );
    expect(page.title, 'Beginner');
    expect(page.workouts.map((w) => w.id), beginnerWorkoutIds);
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
      final thumbnail = tester.widget<Image>(
        find.descendant(of: tile, matching: find.byType(Image)),
      );
      expect(
        (thumbnail.image is ResizeImage
                ? (thumbnail.image as ResizeImage).imageProvider
                : thumbnail.image)
            as AssetImage,
        isA<AssetImage>().having(
          (image) => image.assetName,
          'assetName',
          beginnerArtwork[workout.id],
        ),
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

  testWidgets('Band movements render at multiple animation phases', (
    tester,
  ) async {
    for (final id in ['band_squat', 'band_curl', 'band_row']) {
      for (final pose in [0.0, .25, .5, .75]) {
        await tester.pumpWidget(
          app(
            SizedBox(
              width: 240,
              height: 240,
              child: ExerciseAvatar(
                exercise: exerciseById(id),
                animate: false,
                pose: pose,
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    }
    await tester.pumpWidget(const SizedBox());
  });
}
