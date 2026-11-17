import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/search/body_focus_results_view.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('every body-focus badge lists valid, distinct catalog IDs', () {
    for (final entry in bodyFocusWorkouts.entries) {
      expect(entry.value.toSet(), hasLength(entry.value.length));
      for (final id in entry.value) {
        expect(
          trainingWorkouts.where((workout) => workout.id == id),
          hasLength(1),
          reason: '${entry.key}: $id',
        );
      }
    }
  });

  for (final (label, id) in [
    ('Butt & Leg', 'leg_beginner'),
    ('Chest', 'killer_chest_workout'),
  ]) {
    testWidgets('$id displays and opens the same catalog workout', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final workout = trainingWorkouts.singleWhere((entry) => entry.id == id);
      await tester.pumpWidget(
        MaterialApp(home: BodyFocusResultsView(focusLabel: label)),
      );
      await tester.pumpAndSettle();

      final row = find.widgetWithText(TrainingWorkoutTile, workout.title);
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: row, matching: find.text(workout.summary)),
        findsOneWidget,
      );

      await tester.tap(row);
      await tester.pumpAndSettle();
      final detail = tester.widget<TrainingWorkoutPage>(
        find.byType(TrainingWorkoutPage),
      );
      expect(detail.workout, same(workout));
      expect(find.text('~${workout.estimatedMinutes} mins'), findsOneWidget);
      expect(
        find.text('${workout.exercises.length} Exercises'),
        findsOneWidget,
      );
    });
  }

  testWidgets('a missing ID displays an unavailable row without navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BodyFocusResultsView(
          focusLabel: 'Chest',
          workoutIds: ['removed_workout'],
        ),
      ),
    );
    final unavailable = find.text('Workout unavailable');
    expect(unavailable, findsOneWidget);
    await tester.tap(unavailable);
    await tester.pumpAndSettle();
    expect(find.byType(TrainingWorkoutPage), findsNothing);
  });
}
