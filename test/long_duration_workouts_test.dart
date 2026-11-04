import 'dart:io';
import 'package:fitness_pro/data/models/long_duration_workouts.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/views/search/search_view.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('21–30 Mins reference order, counts, durations and artwork', () {
    expect(longDurationWorkoutIds, [
      'maximum_height_growth',
      'extreme_height_growth',
      'butt_advanced',
      'arm_building_circuit',
      'butt_blaster_challenge',
      'defined_arms_with_dumbbells',
      'intense_leg_power_challenge',
      'plank_challenge',
      'shoulder_back_advanced',
      'strong_arms_basics',
      'forearm_advanced',
      'dumbbell_abs_shaper',
      'man_boobs_hiit_advanced',
      'lower_body_strength',
      'ripped_v_cut_abs_intermediate',
      'glutes_legs_strength_starter',
      'build_wider_shoulders_strength',
      'abs_intermediate',
      'athletes_choice_at_home',
      'forearm_mastery',
      'full_body_muscle_growth',
      'beginner_chest_sculpt',
      'belly_fat_burner_hiit_intermediate',
      'build_wider_shoulders_advanced',
      'lower_body_muscle_gain',
      'brutal_ladder_hiit',
      'ripped_v_cut_abs_advanced',
      'bigger_arms_challenge',
      'full_body_power_progression',
      'peak_full_body_strength',
      'bigger_chest_builder',
      'elite_abs_builder',
      'body_calorie_burner',
      'abs_advanced',
      'ultimate_lower_body_pump',
      'belly_fat_burner_hiit_advanced',
      'killer_chest_workout',
      'intense_v_taper_challenge',
      'booty_shaping_butt_lifting',
    ]);
    expect(longDurationArtwork.values.toSet(), hasLength(39));
    final expected = <String, List<int>>{
      'maximum_height_growth': [21, 26],
      'extreme_height_growth': [21, 26],
      'butt_advanced': [21, 18],
      'arm_building_circuit': [21, 24],
      'butt_blaster_challenge': [21, 25],
      'defined_arms_with_dumbbells': [21, 15],
      'intense_leg_power_challenge': [21, 25],
      'plank_challenge': [21, 24],
      'shoulder_back_advanced': [21, 17],
      'strong_arms_basics': [22, 21],
      'forearm_advanced': [22, 24],
      'dumbbell_abs_shaper': [22, 16],
      'man_boobs_hiit_advanced': [22, 25],
      'lower_body_strength': [22, 27],
      'ripped_v_cut_abs_intermediate': [22, 22],
      'glutes_legs_strength_starter': [23, 23],
      'build_wider_shoulders_strength': [25, 24],
      'abs_intermediate': [25, 21],
      'athletes_choice_at_home': [25, 25],
      'forearm_mastery': [26, 20],
      'full_body_muscle_growth': [26, 24],
      'beginner_chest_sculpt': [26, 23],
      'belly_fat_burner_hiit_intermediate': [26, 30],
      'build_wider_shoulders_advanced': [26, 26],
      'lower_body_muscle_gain': [27, 25],
      'brutal_ladder_hiit': [27, 30],
      'ripped_v_cut_abs_advanced': [27, 24],
      'bigger_arms_challenge': [28, 23],
      'full_body_power_progression': [28, 26],
      'peak_full_body_strength': [28, 24],
      'bigger_chest_builder': [28, 24],
      'elite_abs_builder': [28, 23],
      'body_calorie_burner': [28, 30],
      'abs_advanced': [28, 21],
      'ultimate_lower_body_pump': [29, 24],
      'belly_fat_burner_hiit_advanced': [29, 34],
      'killer_chest_workout': [29, 25],
      'intense_v_taper_challenge': [30, 24],
      'booty_shaping_butt_lifting': [30, 32],
    };
    for (final workout in longDurationWorkouts) {
      final canonical = trainingWorkouts.singleWhere((w) => w.id == workout.id);
      expect(workout.exercises, isNotEmpty);
      expect(
        workout.estimatedMinutes,
        inInclusiveRange(21, 30),
        reason: workout.id,
      );
      expect(workout.exerciseIds, canonical.exerciseIds);
      expect(workout.targets, canonical.targets);
      expect(workout.progressStorageKey, canonical.progressStorageKey);
      expect(File(workout.image).existsSync(), isTrue);
    }
    for (final workout in longDurationWorkouts) {
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
      final badge = find.byKey(const ValueKey('search-duration-21-30'));
      await tester.ensureVisible(badge);
      await tester.pumpAndSettle();
      await tester.tap(badge);
      await tester.pumpAndSettle();
      final page = tester.widget<TrainingCollectionPage>(
        find.byType(TrainingCollectionPage),
      );
      expect(page.title, '21–30 Mins');
      expect(page.workouts.map((w) => w.id), longDurationWorkoutIds);
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
          longDurationArtwork[workout.id],
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
