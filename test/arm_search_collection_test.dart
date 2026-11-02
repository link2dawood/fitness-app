import 'dart:io';
import 'package:fitness_pro/data/models/arm_workouts.dart';
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
    'Arm contains the 18 pictured workouts in order with valid routines',
    () {
      expect(armWorkouts.map((w) => w.title), [
        'Arm Beginner',
        'Arm Intermediate',
        'Arm Advanced',
        'Arm Workout (No Push-Ups!)',
        '10 Min Shredded Arms',
        'Easy Arm Workout with Dumbbells',
        'Defined Arms with Dumbbells',
        'Sculpted Arms Workout',
        'Build Strong Triceps',
        'Beginner Arm Routine',
        'Arm Building Circuit',
        '7 Min Strong Arms',
        'Forearm Mastery',
        'Forearm Builder',
        'Forearm Beginner',
        'Forearm Advanced',
        'Forearm Intermediate',
        'Forearm Foundation',
      ]);
      expect(armWorkoutIds.toSet(), hasLength(18));
      for (final workout in armWorkouts) {
        expect(workout.exercises, isNotEmpty);
        expect(workout.estimatedMinutes, greaterThan(0));
        expect(File(workout.image).existsSync(), isTrue);
      }
      final noPushUps = armWorkouts.singleWhere(
        (w) => w.id == 'arm_workout_no_push_ups',
      );
      expect(
        noPushUps.exercises.any((e) => e.name.toLowerCase().contains('push')),
        isFalse,
      );
      expect(noPushUps.equipment, isNot(contains(ExerciseEquipment.dumbbell)));
      for (final (id, minutes) in [
        ('arm_workout_no_push_ups', 19),
        ('forearm_mastery', 26),
        ('forearm_builder', 24),
        ('forearm_foundation', 20),
      ]) {
        final w = armWorkouts.singleWhere((w) => w.id == id);
        expect(w.exerciseIds, hasLength(20));
        expect(w.targets, hasLength(20));
        expect(w.targets!.every((target) => target > 0), isTrue);
        expect(w.estimatedMinutes, minutes);
      }
    },
  );
  testWidgets('Arm badge opens its collection and every workout destination', (
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
    await tester.ensureVisible(
      find.byKey(const ValueKey('search-body-focus-Arm')),
    );
    await tester.tap(find.byKey(const ValueKey('search-body-focus-Arm')));
    await tester.pumpAndSettle();
    final page = tester.widget<TrainingCollectionPage>(
      find.byType(TrainingCollectionPage),
    );
    expect(page.title, 'Arm');
    expect(page.workouts.map((w) => w.id), armWorkoutIds);
    for (final workout in armWorkouts) {
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
}
