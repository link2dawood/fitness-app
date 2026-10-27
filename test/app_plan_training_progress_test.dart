import 'package:fitness_pro/views/plan/plan_generation_view.dart';
import 'dart:convert';
import 'package:fitness_pro/data/models/user_profile.dart';
import 'package:fitness_pro/data/models/challenge_day.dart';
import 'package:fitness_pro/data/models/training_recommendations.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/data/repositories/training_history_repository.dart';
import 'package:fitness_pro/data/repositories/challenge_day_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/pages/training_page.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/plan/plan_ready_view.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:fitness_pro/views/workouts/challenge_day_page.dart';
import 'package:fitness_pro/views/workouts/challenge_session_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Widget app(Widget child) => MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: child!,
    ),
    home: child,
    routes: {'/home': (_) => const Scaffold(body: Text('Home destination'))},
  );
  const profile = UserProfile(
    level: FitnessLevel.beginner,
    goal: FitnessGoal.buildMuscle,
    focusAreas: {FocusArea.arms},
  );
  testWidgets(
    'Preferences link to real recommended workouts and a launchable detail page',
    (tester) async {
      await tester.pumpWidget(app(const PlanReadyView(profile: profile)));
      await tester.pumpAndSettle();
      expect(find.text('Your plan is ready!'), findsNothing);
      expect(find.text('10-22 Min'), findsNothing);
      expect(find.text('No Equipment'), findsNothing);
      await tester.ensureVisible(find.text('View recommended workouts'));
      await tester.tap(find.text('View recommended workouts'));
      await tester.pumpAndSettle();
      final expected = TrainingRecommendations.forProfile(profile);
      final collection = tester.widget<TrainingCollectionPage>(
        find.byType(TrainingCollectionPage),
      );
      expect(collection.workouts.map((w) => w.id), expected.map((w) => w.id));
      await tester.tap(find.byType(TrainingWorkoutTile).first);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TrainingWorkoutPage>(find.byType(TrainingWorkoutPage))
            .workout
            .id,
        expected.first.id,
      );
      expect(find.text('Start workout'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'Skipped fitness level uses honest editorial fallback; home is a separate destination',
    (tester) async {
      await tester.pumpWidget(app(const PlanReadyView()));
      await tester.pumpAndSettle();
      expect(find.text('Advanced'), findsNothing);
      expect(find.text('Not selected'), findsWidgets);
      await tester.ensureVisible(find.text('Browse workouts'));
      await tester.tap(find.text('Browse workouts'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TrainingCollectionPage>(find.byType(TrainingCollectionPage))
            .workouts
            .map((w) => w.id),
        trainingWorkouts.map((w) => w.id),
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Go to homepage'));
      await tester.tap(find.text('Go to homepage'));
      await tester.pumpAndSettle();
      expect(find.text('Home destination'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  for (final scenario in [
    (
      'SUNDAY',
      DateTime(2026, 10, 31, 23, 59, 59),
      DateTime(2026, 11, 1, 0, 0, 1),
    ),
    (
      'FRIDAY',
      DateTime(2026, 12, 31, 23, 59, 59),
      DateTime(2027, 1, 1, 0, 0, 1),
    ),
    (
      'WEDNESDAY',
      DateTime(2026, 10, 20, 23, 59, 59),
      DateTime(2026, 10, 21, 0, 0, 1),
    ),
  ]) {
    testWidgets(
      'Retained Training refreshes highlight and weekly count at ${scenario.$1} midnight',
      (tester) async {
        var now = scenario.$2;
        SharedPreferences.setMockInitialValues({
          'user_profile': jsonEncode(
            UserProfile(firstDayOfWeek: scenario.$1).toJson(),
          ),
        });
        final model = HomeViewModel(OnboardingRepository());
        await tester.runAsync(() async {
          await TrainingHistoryRepository.instance.load();
          await TrainingHistoryRepository.instance.complete(
            TrainingCompletion(
              id: 'before',
              workoutId: 'test',
              title: 'Test',
              finishedAt: now,
              seconds: 60,
            ),
          );
          await model.load();
        });
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: model,
            child: app(
              IndexedStack(
                index: 0,
                children: [
                  TrainingPage(now: () => now),
                  const SizedBox(),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('1/4'), findsOneWidget);
        final previousLabel = '${now.year}/${now.month}/${now.day}';
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Semantics &&
                w.properties.label == previousLabel &&
                w.properties.selected == true,
          ),
          findsOneWidget,
        );
        now = scenario.$3;
        await tester.pump(const Duration(seconds: 2));
        await tester.pump();
        expect(find.text('0/4'), findsOneWidget);
        final currentLabel = '${now.year}/${now.month}/${now.day}';
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Semantics &&
                w.properties.label == currentLabel &&
                w.properties.selected == true,
          ),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Semantics &&
                w.properties.label == previousLabel &&
                w.properties.selected == true,
          ),
          findsNothing,
        );
        expect(TrainingHistoryRepository.instance.entries, hasLength(1));
        await tester.pumpWidget(const SizedBox());
        model.dispose();
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('An open streak sheet and retained Training refresh on resume', (
    tester,
  ) async {
    var now = DateTime(2026, 10, 31, 12);
    final model = HomeViewModel(OnboardingRepository());
    await tester.runAsync(() async {
      await TrainingHistoryRepository.instance.load();
      await TrainingHistoryRepository.instance.complete(
        TrainingCompletion(
          id: 'last',
          workoutId: 'test',
          title: 'Test',
          finishedAt: now,
          seconds: 60,
        ),
      );
      await model.load();
    });
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: model,
        child: app(TrainingPage(now: () => now)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Training streak'));
    await tester.pumpAndSettle();
    expect(find.text('1 Day Streak!'), findsOneWidget);
    now = DateTime(2026, 11, 2, 12);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('0 Day Streak!'), findsOneWidget);
    await tester.tap(find.text('KEEP GOING'));
    await tester.pumpAndSettle();
    expect(find.text('0/4'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('training-day-2026-11-2')),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
    model.dispose();
  });
  testWidgets(
    'Day 1 restart is scoped, confirms cancellation and preserves completed history and edits',
    (tester) async {
      final entry = referenceDayEntries().first.copyWith(seconds: 42);
      final day = ChallengeDay(
        entries: [entry],
        progress: ChallengeProgress(
          sessionId: 'old',
          index: 0,
          phase: ChallengePhase.exercise,
          remainingMs: 10000,
          activeMs: 32000,
        ),
      );
      await tester.runAsync(() async {
        await ChallengeDayRepository.instance.save(day);
        await TrainingHistoryRepository.instance.load();
        await TrainingHistoryRepository.instance.complete(
          TrainingCompletion(
            id: 'completed',
            workoutId: 'test',
            title: 'Completed',
            finishedAt: DateTime(2026, 10, 20),
            seconds: 90,
          ),
        );
      });
      await tester.pumpWidget(app(const ChallengeDayPage(enableMedia: false)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();
      expect(find.text('Restart Day 1?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(
        (await tester.runAsync(
          ChallengeDayRepository.instance.load,
        ))!.progress!.sessionId,
        'old',
      );
      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(FilledButton, 'Restart'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ChallengeSessionPage), findsOneWidget);
      final saved = await tester.runAsync(ChallengeDayRepository.instance.load);
      expect(saved!.progress!.sessionId, isNot('old'));
      expect(saved.entries.single.seconds, 42);
      expect(saved.progress!.phase, ChallengePhase.prep);
      expect(TrainingHistoryRepository.instance.entries.single.id, 'completed');
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'Preparation copy reviews preferences without claiming a generated schedule',
    (tester) async {
      await tester.pumpWidget(app(const PlanGenerationView()));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pump();
      expect(find.text('REVIEWING YOUR\nPREFERENCES'), findsOneWidget);
      expect(
        find.textContaining('Fitness level: Not selected'),
        findsOneWidget,
      );
      expect(find.textContaining('Beginner'), findsNothing);
      expect(find.textContaining('Your personalized plan'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 10));
      expect(tester.takeException(), isNull);
    },
  );
}
