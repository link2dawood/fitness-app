import 'dart:io';
import 'package:fitness_pro/data/models/full_body_workouts.dart';
import 'package:fitness_pro/views/search/search_view.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('Full Body includes exactly the six reference workouts in order', () {
    expect(fullBodyWorkouts.map((w) => w.id), [
      'lose_weight_for_men',
      'lose_weight_for_women',
      'full_body_challenge',
      'massive_body_challenge',
      'fat_burning_hiit',
      '7_min_hiit_fat_burning',
    ]);
    expect(fullBodyWorkoutIds.toSet(), hasLength(6));
    for (final workout in fullBodyWorkouts) {
      expect(workout.exercises, isNotEmpty);
      expect(workout.estimatedMinutes, greaterThan(0));
      expect(File(workout.image).existsSync(), isTrue);
    }
  });
  testWidgets('Search Full Body badge opens the collection and every routine', (
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
    await tester.tap(find.byKey(const ValueKey('search-body-focus-Full Body')));
    await tester.pumpAndSettle();
    final page = tester.widget<TrainingCollectionPage>(
      find.byType(TrainingCollectionPage),
    );
    expect(page.title, 'Full Body');
    expect(page.workouts.map((w) => w.id), fullBodyWorkoutIds);
    for (final workout in fullBodyWorkouts) {
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
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(SearchView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
