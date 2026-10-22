import 'dart:convert';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/data/repositories/training_history_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/pages/report_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await TrainingHistoryRepository.instance.load();
  });
  Future<void> open(WidgetTester tester) async {
    final model = HomeViewModel(OnboardingRepository());
    addTearDown(model.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: model,
        child: const MaterialApp(home: ReportPage()),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  }

  TrainingCompletion entry(String id, DateTime date, int seconds) =>
      TrainingCompletion(
        id: id,
        workoutId: 'test',
        title: 'Test',
        finishedAt: date,
        seconds: seconds,
      );

  testWidgets('empty saved history has zero totals and unavailable calories', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await open(tester);
    expect(find.text('No completed workouts yet.'), findsOneWidget);
    expect(find.text('Recorded duration: 0 min 0 sec'), findsOneWidget);
    expect(
      find.text('Calories unavailable: not recorded for completed workouts.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'aggregates sessions before converting seconds and updates after completion',
    (tester) async {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final records = [entry('1', yesterday, 30), entry('2', yesterday, 30)];
      SharedPreferences.setMockInitialValues({
        TrainingHistoryRepository.storageKey: jsonEncode(
          records.map((e) => e.toJson()).toList(),
        ),
      });
      await open(tester);
      expect(find.text('Recorded duration: 1 min 0 sec'), findsOneWidget);
      expect(find.text('No completed workouts yet.'), findsNothing);
      expect(TrainingHistoryRepository.instance.streak(now), 1);
      await tester.runAsync(
        () => TrainingHistoryRepository.instance.complete(entry('3', now, 61)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Recorded duration: 2 min 1 sec'), findsOneWidget);
      expect(find.text('3'), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label ==
                  '${now.year}-${now.month}-${now.day}, workout completed',
        ),
        findsOneWidget,
      );
      expect(TrainingHistoryRepository.instance.streak(now), 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'load failure hides stale totals and retry can recover to true empty',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        TrainingHistoryRepository.storageKey: 'invalid json',
      });
      await open(tester);
      expect(find.text('Could not load workout history.'), findsOneWidget);
      expect(find.text('No completed workouts yet.'), findsNothing);
      expect(find.textContaining('Recorded duration:'), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(TrainingHistoryRepository.storageKey);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Could not load workout history.'), findsNothing);
      expect(find.text('No completed workouts yet.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
