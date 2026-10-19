import 'dart:convert';
import 'package:fitness_pro/core/theme/app_theme.dart';
import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/data/models/training_calendar.dart';
import 'package:fitness_pro/data/models/training_recommendations.dart';
import 'package:fitness_pro/data/models/user_profile.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/data/repositories/training_history_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/pages/challenge_page.dart';
import 'package:fitness_pro/views/home/pages/just_for_you_page.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/widgets/training_feature_cards.dart';
import 'package:fitness_pro/views/home/pages/training_page.dart';
import 'package:fitness_pro/views/search/search_view.dart';
import 'package:fitness_pro/views/workouts/training_history_sheet.dart';
import 'package:fitness_pro/views/workouts/training_goal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FailOnceRepository extends OnboardingRepository {
  int writes = 0;
  @override
  Future<UserProfile> saveTrainingPreferences(int days, String firstDay) async {
    if (writes++ == 0) throw StateError('Save failed');
    return super.saveTrainingPreferences(days, firstDay);
  }
}

Widget app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  builder: (context, widget) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: widget!,
  ),
  home: child,
);
const profile = UserProfile(
  gender: Gender.female,
  level: FitnessLevel.beginner,
  focusAreas: {FocusArea.chest},
  goal: FitnessGoal.buildMuscle,
  firstDayOfWeek: 'SUNDAY',
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TrainingHistoryRepository.instance.load();
  });
  test(
    'Goal preferences preserve the latest profile and onboarding state',
    () async {
      final repository = OnboardingRepository();
      await repository.saveProfile(profile);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', false);
      final result = await repository.saveTrainingPreferences(6, 'MONDAY');
      expect(result.gender, Gender.female);
      expect(result.level, FitnessLevel.beginner);
      expect(result.focusAreas, {FocusArea.chest});
      expect(result.goal, FitnessGoal.buildMuscle);
      expect((await repository.loadProfile())!.workoutDaysPerWeek, 6);
      expect((await repository.loadProfile())!.firstDayOfWeek, 'MONDAY');
      expect(await repository.isOnboardingCompleted(), isFalse);
      await expectLater(
        repository.saveTrainingPreferences(8, 'MONDAY'),
        throwsArgumentError,
      );
      await expectLater(
        repository.saveTrainingPreferences(5, 'FRIDAY'),
        throwsArgumentError,
      );
      expect((await repository.loadProfile())!.workoutDaysPerWeek, 6);
    },
  );
  test('Calendar aligns Sunday/Monday across weeks, months and leap years', () {
    expect(
      TrainingCalendar.week(DateTime(2026, 10, 19), 'SUNDAY').first,
      DateTime(2026, 10, 18),
    );
    expect(
      TrainingCalendar.week(DateTime(2026, 10, 19), 'MONDAY').first,
      DateTime(2026, 10, 19),
    );
    expect(
      TrainingCalendar.month(
        DateTime(2026, 10),
        'SUNDAY',
      ).takeWhile((d) => d == null),
      hasLength(4),
    );
    expect(
      TrainingCalendar.month(
        DateTime(2026, 10),
        'MONDAY',
      ).takeWhile((d) => d == null),
      hasLength(3),
    );
    expect(
      TrainingCalendar.month(DateTime(2024, 2), 'MONDAY').whereType<DateTime>(),
      hasLength(29),
    );
    expect(
      TrainingCalendar.week(DateTime(2027, 1, 1), 'MONDAY').first,
      DateTime(2026, 12, 28),
    );
  });
  test(
    'Recommendations use focus/goal/level without inventing an incomplete profile',
    () {
      final chest = TrainingRecommendations.forProfile(profile);
      final legs = TrainingRecommendations.forProfile(
        profile.copyWith(focusAreas: {FocusArea.legs}),
      );
      expect(chest, isNotEmpty);
      expect(chest.first.focus, contains(ExerciseFocus.chest));
      expect(legs.first.focus, contains(ExerciseFocus.leg));
      expect(chest.first.id, isNot(legs.first.id));
      expect(
        chest.every((w) => w.difficulty == ExerciseDifficulty.easy),
        isTrue,
      );
      expect(chest.first.type, ExerciseType.training);
      final fit = TrainingRecommendations.forProfile(
        profile.copyWith(goal: FitnessGoal.keepFit),
      );
      expect(fit.first.type, isNot(ExerciseType.training));
      expect(TrainingRecommendations.forProfile(null), isEmpty);
      expect(TrainingRecommendations.forProfile(const UserProfile()), isEmpty);
    },
  );
  testWidgets(
    'Goal editor retries failed saves, persists changes and discards Cancel',
    (tester) async {
      final repository = FailOnceRepository();
      await repository.saveProfile(profile);
      final vm = HomeViewModel(repository);
      await vm.load();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: app(const TrainingPage()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit weekly goal'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, '7'));
      await tester.tap(find.text('Monday'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(
        find.text('Could not save your goal. Please try again.'),
        findsOneWidget,
      );
      expect(vm.profile!.workoutDaysPerWeek, 4);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(vm.profile!.workoutDaysPerWeek, 7);
      expect(vm.profile!.firstDayOfWeek, 'MONDAY');
      expect(find.text('0/7'), findsOneWidget);
      expect((await repository.loadProfile())!.workoutDaysPerWeek, 7);
      await tester.tap(find.byTooltip('Edit weekly goal'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, '2'));
      await tester.tap(find.text('Sunday'));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect((await repository.loadProfile())!.workoutDaysPerWeek, 7);
      expect((await repository.loadProfile())!.firstDayOfWeek, 'MONDAY');
      await tester.pumpWidget(const SizedBox());
      vm.dispose();
    },
  );
  testWidgets(
    'History shows real days, durations and selected-day empty state',
    (tester) async {
      final repo = TrainingHistoryRepository.instance;
      for (final entry in [
        TrainingCompletion(
          id: 'earlier',
          workoutId: 'x',
          title: 'Earlier routine',
          finishedAt: DateTime(2026, 10, 7, 9, 30),
          seconds: 90,
        ),
        TrainingCompletion(
          id: 'today',
          workoutId: 'x',
          title: 'Today routine',
          finishedAt: DateTime(2026, 10, 19, 10),
          seconds: 120,
        ),
      ]) {
        await tester.runAsync(() => repo.complete(entry));
      }
      await tester.pumpWidget(
        app(
          Scaffold(
            body: TrainingHistorySheet(
              date: DateTime(2026, 10, 19),
              firstDay: 'MONDAY',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Today routine'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('history-day-2026-10-7')));
      await tester.pumpAndSettle();
      expect(find.text('Earlier routine'), findsOneWidget);
      expect(find.text('1 min 30 sec • 09:30'), findsOneWidget);
      expect(find.text('Today routine'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('history-day-2026-10-8')));
      await tester.pumpAndSettle();
      expect(find.text('No completed workouts on this day.'), findsOneWidget);
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      expect(find.text('2026/09'), findsOneWidget);
      final headers = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byKey(const ValueKey('history-weekdays')),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data)
          .toList();
      expect(headers, ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Customized cards and Just For You share the same profile ranking',
    (tester) async {
      await OnboardingRepository().saveProfile(profile);
      final expected = TrainingRecommendations.forProfile(profile).first.id;
      final vm = HomeViewModel(OnboardingRepository());
      await vm.load();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: app(const TrainingPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<TrainingChallengeCard>(
              find.byType(TrainingChallengeCard),
            )
            .first
            .workout
            .id,
        expected,
      );
      await tester.pumpWidget(app(const JustForYouPage()));
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<TrainingWorkoutTile>(find.byType(TrainingWorkoutTile))
            .first
            .workout
            .id,
        expected,
      );
      await tester.pumpWidget(app(const ChallengePage(profile: profile)));
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<TrainingWorkoutTile>(find.byType(TrainingWorkoutTile))
            .first
            .workout
            .id,
        expected,
      );
      await tester.pumpWidget(const SizedBox());
      vm.dispose();
    },
  );
  for (final source in ['Training', 'Search']) {
    testWidgets(
      '$source feature request action collects and saves a local request',
      (tester) async {
        final vm = HomeViewModel(OnboardingRepository());
        await vm.load();
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: vm,
            child: app(
              source == 'Training' ? const TrainingPage() : const SearchView(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Tell us what you need'),
          500,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Tell us what you need'));
        await tester.pumpAndSettle();
        final option = find.widgetWithText(FilterChip, 'Customize workout');
        await tester.ensureVisible(option);
        await tester.tap(option);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Submit'));
        await tester.tap(find.text('Submit'));
        await tester.pumpAndSettle();
        expect(find.text('Feature request saved!'), findsOneWidget);
        final prefs = await SharedPreferences.getInstance();
        final request =
            jsonDecode(prefs.getStringList('feature_requests')!.single) as Map;
        expect(request['features'], ['Customize workout']);
        await tester.pumpWidget(const SizedBox());
        vm.dispose();
      },
    );
  }
  testWidgets(
    'Goal and history controls fit narrow screens with 200 percent text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: TrainingHistorySheet(
              date: DateTime(2026, 10, 19),
              firstDay: 'SUNDAY',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final headers = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byKey(const ValueKey('history-weekdays')),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data)
          .toList();
      expect(headers, ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: TrainingGoalSheet(
              days: 4,
              firstDay: 'SUNDAY',
              onSave: (_, _) async {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save'));
      expect(tester.takeException(), isNull);
    },
  );
}
