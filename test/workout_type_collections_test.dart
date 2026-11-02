import 'dart:io';
import 'package:fitness_pro/data/models/workout_type_collections.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/views/search/search_view.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:fitness_pro/views/workouts/challenge_day_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'Workout types contain the screenshot order with valid shared routines',
    () {
      expect(workoutTypeCollection('fat_burning').map((w) => w.id), [
        'intense_belly_fat_burn',
        'lose_weight_for_men',
        'lose_weight_for_women',
        '10_min_shredded_arms',
        'belly_fat_burner_hiit_beginner',
        'belly_fat_burner_hiit_intermediate',
        'belly_fat_burner_hiit_advanced',
        'lose_fat_no_jumping',
        'fat_burning_hiit',
        '3_exercises_lose_belly_fat',
        '7_min_hiit_fat_burning',
        'body_calorie_burner',
        'burn_100_calories',
        'build_strong_triceps',
        'beginner_arm_routine',
        'shred_your_quads',
      ]);
      expect(workoutTypeCollection('hiit').map((w) => w.id), [
        '7_min_hiit_fat_burning',
        'belly_fat_burner_hiit_advanced',
        'belly_fat_burner_hiit_beginner',
        'belly_fat_burner_hiit_intermediate',
        'brutal_ladder_hiit',
        'fat_burning_hiit',
        'man_boobs_hiit_beginner',
        'man_boobs_hiit_intermediate',
        'man_boobs_hiit_advanced',
        'hiit_intermediate',
        'killer_core_hiit_advanced',
        'killer_core_hiit_beginner',
        'killer_core_hiit_intermediate',
      ]);
      expect(workoutTypeCollection('build_muscle').map((w) => w.id), [
        'intense_belly_fat_burn',
        'get_ripped_with_dumbbell',
        'full_body_challenge',
        'massive_body_challenge',
        'lower_body',
        'build_wider_shoulders_intermediate',
        'build_wider_shoulders_advanced',
        'quick_bigger_chest_building',
        'defined_arms_with_dumbbells',
        'dumbbell_abs_shaper',
        'beginner_abs_shred',
        'beginner_back_builder',
        'easy_arm_workout_with_dumbbells',
        'sculpted_arms_workout',
        'bigger_strong_quads_leg_workout',
        'butt_lift_rounder_booty',
        'beginner_chest_workout',
        'arm_building_circuit',
        'intense_leg_transformation',
        'rounder_booty_shaping',
        'killer_chest_routine',
        '10_min_leg_workout',
        'strong_legs_routine',
        '7_min_strong_arms',
      ]);
      expect(workoutTypeCollection('warm_up').map((w) => w.title), [
        'Morning Warm-Up',
        'Before Workout Warm-Up',
        '6 Min Tabata',
      ]);
      expect(
        workoutTypeCollectionTitles.keys.toSet(),
        workoutTypeCollectionIds.keys.toSet(),
      );
      for (final group in workoutTypeCollectionIds.keys) {
        final routines = workoutTypeCollection(group);
        expect(routines.map((w) => w.id).toSet(), hasLength(routines.length));
        for (final w in routines) {
          expect(trainingWorkouts, contains(w));
          expect(w.exercises, isNotEmpty);
          expect(File(w.image).existsSync(), isTrue);
        }
      }
      for (final (id, count, minutes) in [
        ('body_calorie_burner', 30, 28),
        ('burn_100_calories', 14, 13),
        ('brutal_ladder_hiit', 30, 27),
        ('hiit_intermediate', 21, 19),
        ('man_boobs_hiit_beginner', 19, 17),
        ('man_boobs_hiit_intermediate', 19, 18),
        ('man_boobs_hiit_advanced', 25, 22),
      ]) {
        final w = trainingWorkouts.singleWhere((w) => w.id == id);
        expect(w.exercises, hasLength(count));
        expect(w.targets, hasLength(count));
        expect(w.targets!.every((target) => target > 0), isTrue);
        expect(w.estimatedMinutes, minutes);
      }
      final ladder = trainingWorkouts.singleWhere(
        (w) => w.id == 'brutal_ladder_hiit',
      );
      expect(ladder.targetAt(24), greaterThan(ladder.targetAt(0)));
    },
  );
  for (final group in workoutTypeCollectionIds.keys) {
    testWidgets('$group badge opens its list and every working destination', (
      tester,
    ) async {
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
      final badge = find.byKey(ValueKey('search-workout-type-$group'));
      await tester.ensureVisible(badge);
      await tester.pumpAndSettle();
      await tester.tap(badge);
      await tester.pumpAndSettle();
      final page = tester.widget<TrainingCollectionPage>(
        find.byType(TrainingCollectionPage),
      );
      expect(page.title, workoutTypeCollectionTitles[group]);
      expect(page.workouts.map((w) => w.id), workoutTypeCollectionIds[group]);
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
        await tester.tap(tile);
        await tester.pumpAndSettle();
        if (workout.id == 'intense_belly_fat_burn') {
          expect(find.byType(ChallengeDayPage), findsOneWidget);
          await tester.tap(find.byTooltip('Back to training'));
        } else {
          expect(
            tester
                .widget<TrainingWorkoutPage>(find.byType(TrainingWorkoutPage))
                .workout
                .id,
            workout.id,
          );
          expect(find.text('Start workout'), findsOneWidget);
          await tester.pageBack();
        }
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });
  }
}
