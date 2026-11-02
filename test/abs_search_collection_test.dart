import 'dart:io';
import 'package:fitness_pro/data/models/abs_workouts.dart';
import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/views/search/search_view.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:fitness_pro/views/workouts/challenge_day_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Widget app(Widget home) => MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: child!,
    ),
    home: home,
  );
  test(
    'Abs contains all 19 reference workouts in order with valid playable data',
    () {
      expect(absWorkouts.map((w) => w.title.toLowerCase()), [
        'intense belly fat burn',
        'six pack challenge',
        'abs beginner',
        'abs intermediate',
        'abs advanced',
        'only 4 moves for abs',
        '10 min abs workout',
        'beginner abs shred',
        'dumbbell abs shaper',
        'plank challenge',
        'ripped v-cut abs sculpting - beginner',
        'ripped v-cut abs sculpting - intermediate',
        'ripped v-cut abs sculpting - advanced',
        'belly fat burner hiit beginner',
        'belly fat burner hiit intermediate',
        'belly fat burner hiit advanced',
        'killer core hiit beginner',
        'killer core hiit intermediate',
        'killer core hiit advanced',
      ]);
      expect(absWorkoutIds.toSet(), hasLength(19));
      for (final w in absWorkouts) {
        expect(w.focus, contains(ExerciseFocus.abs));
        expect(w.exercises, isNotEmpty);
        expect(w.estimatedMinutes, greaterThan(0));
        expect(File(w.image).existsSync(), isTrue);
      }
      for (final (id, count, minutes) in [
        ('only_4_moves_for_abs', 12, 11),
        ('10_min_abs_workout', 10, 9),
        ('plank_challenge', 24, 21),
        ('ripped_v_cut_abs_beginner', 18, 16),
        ('ripped_v_cut_abs_intermediate', 22, 22),
        ('ripped_v_cut_abs_advanced', 24, 27),
        ('killer_core_hiit_beginner', 23, 20),
        ('killer_core_hiit_intermediate', 37, 33),
        ('killer_core_hiit_advanced', 53, 49),
      ]) {
        final w = absWorkouts.singleWhere((w) => w.id == id);
        expect(w.exerciseIds, hasLength(count));
        expect(w.targets, hasLength(count));
        expect(w.estimatedMinutes, minutes);
      }
    },
  );
  testWidgets(
    'Search Abs badge opens the ordered collection and working destinations',
    (tester) async {
      await tester.pumpWidget(app(const SearchView()));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('search-body-focus-Abs')));
      await tester.pumpAndSettle();
      final page = tester.widget<TrainingCollectionPage>(
        find.byType(TrainingCollectionPage),
      );
      expect(page.title, 'Abs');
      expect(page.workouts.map((w) => w.id), absWorkoutIds);
      await tester.tap(find.byType(TrainingWorkoutTile).first);
      await tester.pumpAndSettle();
      expect(find.byType(ChallengeDayPage), findsOneWidget);
      await tester.tap(find.byTooltip('Back to training'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Only 4 Moves for Abs'),
        180,
        scrollable: find
            .descendant(
              of: find.byType(TrainingCollectionPage),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.ensureVisible(find.text('Only 4 Moves for Abs'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Only 4 Moves for Abs'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TrainingWorkoutPage>(find.byType(TrainingWorkoutPage))
            .workout
            .id,
        'only_4_moves_for_abs',
      );
      expect(find.text('Start workout'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
