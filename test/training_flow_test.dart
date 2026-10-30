import 'package:fitness_pro/core/theme/app_theme.dart';
import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/data/models/training_search.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/data/repositories/training_history_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/pages/training_page.dart';
import 'package:fitness_pro/views/search/search_view.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManualStopwatch implements Stopwatch {
  Duration value = Duration.zero;
  @override
  bool isRunning = false;
  void advance(Duration duration) {
    if (isRunning) value += duration;
  }

  @override
  Duration get elapsed => value;
  @override
  int get elapsedMicroseconds => value.inMicroseconds;
  @override
  int get elapsedMilliseconds => value.inMilliseconds;
  @override
  int get elapsedTicks => value.inMicroseconds;
  @override
  int get frequency => 1000000;
  @override
  void start() => isRunning = true;
  @override
  void stop() => isRunning = false;
  @override
  void reset() => value = Duration.zero;
}

const sample = TrainingWorkout(
  id: 'test',
  title: 'Test routine',
  difficulty: ExerciseDifficulty.easy,
  type: ExerciseType.training,
  image: 'assets/images/workouts/abs.jpg',
  exerciseIds: ['wall_push_ups', 'punches'],
  targets: [3, 2],
  restSeconds: [1, 0],
);
Widget app(Widget home) => MaterialApp(
  theme: AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child!,
  ),
  home: home,
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'settings_prep': 0});
    await TrainingHistoryRepository.instance.load();
  });
  test(
    'Every workout has valid stable IDs, actual targets and computed duration',
    () {
      expect(
        trainingWorkouts.map((w) => w.id).toSet(),
        hasLength(trainingWorkouts.length),
      );
      for (final workout in trainingWorkouts) {
        expect(workout.exercises.length, greaterThanOrEqualTo(4));
        expect(workout.estimatedMinutes, greaterThan(0));
        expect(
          workout.exerciseIds.toSet(),
          hasLength(
            switch (workout.id) {
              'calisthenics_plan' => 20,
              'lose_weight_for_men' => 7, // Reference includes repeated sets.
              _ => workout.exerciseIds.length,
            },
          ),
        );
        expect(
          workout.exercises.every((e) => exerciseCatalog.contains(e)),
          isTrue,
        );
      }
      expect(sample.targetAt(0), 3);
      expect(sample.restAfter(0), 1);
      expect(sample.estimatedMinutes, 1);
    },
  );
  test(
    'Search combines text, focus, difficulty, type and duration and can be empty',
    () {
      final results = TrainingSearch.results(
        query: 'chest',
        focus: ExerciseFocus.chest,
        difficulty: ExerciseDifficulty.easy,
        type: ExerciseType.training,
        durationBand: 0,
      );
      expect(results, isNotEmpty);
      expect(
        results.every(
          (w) =>
              w.focus.contains(ExerciseFocus.chest) &&
              w.difficulty == ExerciseDifficulty.easy &&
              w.type == ExerciseType.training &&
              w.estimatedMinutes <= 10,
        ),
        isTrue,
      );
      expect(TrainingSearch.results(query: 'no-such-workout-xyz'), isEmpty);
      expect(TrainingSearch.results(), hasLength(trainingWorkouts.length));
    },
  );
  test(
    'History survives reload, de-duplicates writes, counts days rather than sessions',
    () async {
      final repo = TrainingHistoryRepository.instance;
      final now = DateTime(2026, 10, 19, 20);
      TrainingCompletion entry(String id, DateTime when) => TrainingCompletion(
        id: id,
        workoutId: 'test',
        title: 'Test',
        finishedAt: when,
        seconds: 60,
      );
      final first = entry('1', DateTime(2026, 10, 18, 23));
      await Future.wait([
        repo.complete(first),
        repo.complete(first),
        repo.complete(entry('2', now)),
        repo.complete(entry('3', now)),
      ]);
      await repo.load();
      expect(repo.entries, hasLength(3));
      expect(repo.streak(now), 2);
      expect(repo.weeklyDays(now), 1);
      expect(repo.weeklyDays(now, sundayFirst: true), 2);
      expect(repo.streak(DateTime(2026, 10, 21)), 0);
    },
  );
  test('Corrupt history is not overwritten by a completion attempt', () async {
    SharedPreferences.setMockInitialValues({
      TrainingHistoryRepository.storageKey: 'broken json',
    });
    final repo = TrainingHistoryRepository.instance;
    await expectLater(repo.load(), throwsFormatException);
    await expectLater(
      repo.complete(
        TrainingCompletion(
          id: 'x',
          workoutId: 'test',
          title: 'Test',
          finishedAt: DateTime.now(),
          seconds: 1,
        ),
      ),
      throwsFormatException,
    );
    expect(
      (await SharedPreferences.getInstance()).getString(
        TrainingHistoryRepository.storageKey,
      ),
      'broken json',
    );
  });
  testWidgets(
    'New user has zero streak; saved completions refresh weekly progress',
    (tester) async {
      final vm = HomeViewModel(OnboardingRepository());
      await vm.load();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: app(const TrainingPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('0/4'), findsOneWidget);
      await tester.tap(find.byTooltip('Training streak'));
      await tester.pumpAndSettle();
      expect(find.text('0 Day Streak!'), findsOneWidget);
      await tester.tap(find.text('KEEP GOING'));
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => TrainingHistoryRepository.instance.complete(
          TrainingCompletion(
            id: 'today',
            workoutId: 'test',
            title: 'Test',
            finishedAt: DateTime.now(),
            seconds: 120,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1/4'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      vm.dispose();
    },
  );
  testWidgets(
    'Row launches details and Start launches a session; abandoning saves nothing',
    (tester) async {
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => openTrainingWorkout(context, sample),
              child: const Text('Open routine'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open routine'));
      await tester.pumpAndSettle();
      expect(find.text('3 reps'), findsOneWidget);
      expect(find.text('2 seconds'), findsOneWidget);
      await tester.tap(find.text('Start workout'));
      await tester.pumpAndSettle();
      expect(find.text('Exercise 1 of 2'), findsOneWidget);
      await tester.tap(find.byTooltip('Leave workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();
      expect(TrainingHistoryRepository.instance.entries, isEmpty);
      expect(find.text('Start workout'), findsOneWidget);
    },
  );
  testWidgets(
    'Session honors custom targets, pauses timers and saves exactly once after final exercise',
    (tester) async {
      final watches = <ManualStopwatch>[];
      await tester.pumpWidget(
        app(
          TrainingSessionPage(
            workout: sample,
            createStopwatch: () {
              final watch = ManualStopwatch();
              watches.add(watch);
              return watch;
            },
          ),
        ),
      );
      await tester.pump();
      expect(find.text('3 reps'), findsOneWidget);
      await tester.tap(find.text('Exercise done'));
      await tester.pump();
      expect(find.text('1 seconds'), findsOneWidget);
      await tester.tap(find.text('Skip rest'));
      await tester.pump();
      expect(find.text('2 seconds'), findsOneWidget);
      await tester.tap(find.text('Pause'));
      await tester.pump();
      for (final watch in watches) {
        watch.advance(const Duration(seconds: 10));
      }
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('2 seconds'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Finish exercise'),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Resume'));
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      for (final watch in watches) {
        watch.advance(const Duration(seconds: 10));
      }
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.text('Paused'), findsOneWidget);
      expect(find.text('2 seconds'), findsOneWidget);
      await tester.tap(find.text('Resume'));
      await tester.pump();
      for (final watch in watches) {
        watch.advance(const Duration(seconds: 2));
      }
      await tester.pump(const Duration(milliseconds: 250));
      await tester.tap(find.text('Finish exercise'));
      await tester.pump();
      expect(TrainingHistoryRepository.instance.entries, isEmpty);
      await tester.tap(find.text('Save completion'));
      await tester.runAsync(() async {
        await Future<void>.delayed(Duration.zero);
      });
      await tester.pumpAndSettle();
      expect(find.text('Progress saved'), findsOneWidget);
      expect(TrainingHistoryRepository.instance.entries, hasLength(1));
      expect(TrainingHistoryRepository.instance.entries.single.seconds, 2);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'Search shows real results, empty state and clear restores them',
    (tester) async {
      await tester.pumpWidget(app(const SearchView()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'no-such-workout-xyz');
      await tester.pumpAndSettle();
      expect(find.text('0 workouts'), findsOneWidget);
      expect(find.textContaining('No workouts match.'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(find.text('${trainingWorkouts.length} workouts'), findsOneWidget);
    },
  );
  testWidgets('Shared preparation and Off rest apply to a generic workout', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'settings_prep': 5,
      'settings_rest_mode': 'Off',
      'settings_music': false,
      'settings_voice': false,
      'settings_effect': false,
    });
    final clocks = <ManualStopwatch>[];
    await tester.pumpWidget(
      app(
        TrainingSessionPage(
          workout: sample,
          createStopwatch: () {
            final clock = ManualStopwatch();
            clocks.add(clock);
            return clock;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Get ready'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Exercise done'),
          )
          .onPressed,
      isNull,
    );
    for (final clock in clocks) {
      clock.advance(const Duration(seconds: 5));
    }
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Get ready'), findsNothing);
    await tester.tap(find.text('Exercise done'));
    await tester.pump();
    expect(find.text('Exercise 2 of 2'), findsOneWidget);
    expect(find.text('Rest'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
  testWidgets('Unreadable session settings offer retry before clocks start', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'settings_record_v1': 'broken'});
    final clocks = <ManualStopwatch>[];
    await tester.pumpWidget(
      app(
        TrainingSessionPage(
          workout: sample,
          createStopwatch: () {
            final clock = ManualStopwatch();
            clocks.add(clock);
            return clock;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    expect(clocks.every((clock) => !clock.isRunning), isTrue);
    SharedPreferences.setMockInitialValues({'settings_prep': 0});
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Exercise 1 of 2'), findsOneWidget);
    expect(clocks.every((clock) => clock.isRunning), isTrue);
    await tester.pumpWidget(const SizedBox());
  });
}
