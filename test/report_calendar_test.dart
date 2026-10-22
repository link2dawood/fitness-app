import 'dart:convert';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/data/repositories/training_history_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/pages/report_page.dart';
import 'package:fitness_pro/views/home/pages/history_calendar_view.dart';
import 'package:fitness_pro/views/workouts/training_history_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> open(WidgetTester tester) async {
    final model = HomeViewModel(OnboardingRepository());
    addTearDown(model.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: model,
        child: const MaterialApp(home: ReportPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('All records'));
    await tester.tap(find.text('All records'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(HistoryCalendarView), findsOneWidget);
  }

  TrainingCompletion entry(String id, DateTime date, int seconds) =>
      TrainingCompletion(
        id: id,
        workoutId: id,
        title: id,
        finishedAt: date,
        seconds: seconds,
      );

  testWidgets(
    'All records reads persisted sessions, week preference and full-date selection',
    (tester) async {
      final now = DateTime.now();
      final previous = DateTime(now.year, now.month - 1, 1);
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode({'firstDayOfWeek': 'MONDAY'}),
        TrainingHistoryRepository.storageKey: jsonEncode([
          entry('Today session', now, 91).toJson(),
          entry('Second session', now, 30).toJson(),
          entry('Previous month session', previous, 600).toJson(),
        ]),
      });
      await open(tester);
      expect(
        tester
            .widget<TrainingHistorySheet>(find.byType(TrainingHistorySheet))
            .firstDay,
        'MONDAY',
      );
      expect(find.text('2 completed workouts'), findsOneWidget);
      expect(find.text('Today session'), findsOneWidget);
      expect(find.textContaining('1 min 31 sec'), findsOneWidget);
      expect(find.text('Previous month session'), findsNothing);
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      final dateKey = ValueKey(
        'history-day-${previous.year}-${previous.month}-1',
      );
      await tester.tap(find.byKey(dateKey));
      await tester.pumpAndSettle();
      expect(find.text('Previous month session'), findsOneWidget);
      expect(find.text('Today session'), findsNothing);
      expect(find.textContaining('10 min 0 sec'), findsOneWidget);
      await tester.tap(
        find.byKey(
          ValueKey('history-day-${previous.year}-${previous.month}-2'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No completed workouts on this day.'), findsOneWidget);
      await tester.tap(find.byTooltip('Close history'));
      await tester.pumpAndSettle();
      expect(find.byType(HistoryCalendarView), findsNothing);
      expect(find.text('REPORT'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'failed All records load retries without showing a false empty history',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        TrainingHistoryRepository.storageKey: 'broken',
      });
      await open(tester);
      expect(
        find.textContaining('Workout history could not be loaded.'),
        findsOneWidget,
      );
      expect(find.text('No completed workouts on this day.'), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(TrainingHistoryRepository.storageKey), 'broken');
      await prefs.remove(TrainingHistoryRepository.storageKey);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('No completed workouts on this day.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
