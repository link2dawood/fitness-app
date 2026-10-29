import 'dart:io';
import 'dart:convert';
import 'package:fitness_pro/core/theme/app_theme.dart';
import 'package:fitness_pro/core/routes/app_routes.dart';
import 'package:fitness_pro/data/models/discover_catalog.dart';
import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/data/repositories/training_history_repository.dart';
import 'package:fitness_pro/views/home/pages/discover_page.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:fitness_pro/views/workouts/training_history_sheet.dart';
import 'package:fitness_pro/views/search/search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget app() => MaterialApp(
  theme: AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child!,
  ),
  home: const DiscoverPage(),
);

Future<void> reveal(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target.first);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TrainingHistoryRepository.instance.load();
  });
  testWidgets(
    'Every editorial workout placement opens its exact routine, including offscreen cards',
    (tester) async {
      final oldFatal = WidgetController.hitTestWarningShouldBeFatal;
      WidgetController.hitTestWarningShouldBeFatal = true;
      addTearDown(
        () => WidgetController.hitTestWarningShouldBeFatal = oldFatal,
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      final occurrences = <String, int>{};
      final targets = <(String, int)>[];
      for (final widget in tester.widgetList(
        find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key as ValueKey<String>).value.startsWith('discover-workout-'),
        ),
      )) {
        final key = (widget.key as ValueKey<String>).value;
        final occurrence = occurrences[key] ?? 0;
        targets.add((key, occurrence));
        occurrences[key] = occurrence + 1;
      }
      expect(targets, hasLength(44));
      for (final (key, occurrence) in targets) {
        final card = find.byKey(ValueKey(key)).at(occurrence);
        await Scrollable.ensureVisible(tester.element(card), alignment: .5);
        await tester.pumpAndSettle();
        final id = key.substring('discover-workout-'.length);
        final expected = DiscoverCatalog.workout(id);
        expect(
          find.descendant(of: card, matching: find.text(expected.title)),
          findsOneWidget,
        );
        await tester.tap(card);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TrainingWorkoutPage>(find.byType(TrainingWorkoutPage))
              .workout
              .id,
          id,
          reason: '$key placement $occurrence',
        );
        expect(find.text(expected.summary), findsOneWidget);
        expect(find.text('Start workout'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(DiscoverPage), findsOneWidget);
      }
      expect(TrainingHistoryRepository.instance.entries, isEmpty);
    },
  );
  testWidgets(
    'Discover Search opens the real search route and a matching workout',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: const DiscoverPage(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Search workouts'));
      await tester.pumpAndSettle();
      expect(find.byType(SearchView), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Tabata');
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
      find.byType(TrainingWorkoutTile),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TrainingWorkoutTile>(find.byType(TrainingWorkoutTile).first)
            .workout
            .id,
        '6_min_tabata',
      );
      await tester.ensureVisible(find.byType(TrainingWorkoutTile).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TrainingWorkoutTile).first);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TrainingWorkoutPage>(find.byType(TrainingWorkoutPage))
            .workout
            .id,
        '6_min_tabata',
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Tabata'), findsWidgets);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(DiscoverPage), findsOneWidget);
    },
  );
  testWidgets('Discover history reads storage and saved week preference', (
    tester,
  ) async {
    final date = DateTime.now();
    final completion = TrainingCompletion(
      id: 'persisted-discover',
      workoutId: 'abs_beginner',
      title: 'Stored abs workout',
      finishedAt: date,
      seconds: 125,
    );
    SharedPreferences.setMockInitialValues({
      TrainingHistoryRepository.storageKey: jsonEncode([completion.toJson()]),
      'user_profile': jsonEncode({'firstDayOfWeek': 'MONDAY'}),
    });
    expect(TrainingHistoryRepository.instance.entries, isEmpty);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Workout history'));
    await tester.pumpAndSettle();
    expect(find.text('Stored abs workout'), findsOneWidget);
    expect(find.textContaining('2 min 5 sec'), findsOneWidget);
    expect(
      tester
          .widget<TrainingHistorySheet>(find.byType(TrainingHistorySheet))
          .firstDay,
      'MONDAY',
    );
    expect(find.text('1 completed workout'), findsOneWidget);
    await tester.tap(find.byTooltip('Close history'));
    await tester.pumpAndSettle();
    expect(find.byType(DiscoverPage), findsOneWidget);
  });
  testWidgets('Discover history shows empty state and refreshes on reopening', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Workout history'));
    await tester.pumpAndSettle();
    expect(find.text('No completed workouts on this day.'), findsOneWidget);
    await tester.tap(find.byTooltip('Close history'));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      TrainingHistoryRepository.storageKey,
      jsonEncode([
        TrainingCompletion(
          id: 'later',
          workoutId: 'abs_beginner',
          title: 'Newly saved session',
          finishedAt: DateTime.now(),
          seconds: 60,
        ).toJson(),
      ]),
    );
    await tester.tap(find.byTooltip('Workout history'));
    await tester.pumpAndSettle();
    expect(find.text('Newly saved session'), findsOneWidget);
  });
  testWidgets(
    'Invalid persisted history shows Retry without false empty state or overwriting data',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        TrainingHistoryRepository.storageKey: 'invalid-json',
      });
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Workout history'));
      await tester.pumpAndSettle();
      expect(find.textContaining('could not be loaded'), findsOneWidget);
      expect(find.text('No completed workouts on this day.'), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(TrainingHistoryRepository.storageKey),
        'invalid-json',
      );
      await prefs.setString(
        TrainingHistoryRepository.storageKey,
        jsonEncode([
          TrainingCompletion(
            id: 'recovered',
            workoutId: 'abs_beginner',
            title: 'Recovered session',
            finishedAt: DateTime.now(),
            seconds: 90,
          ).toJson(),
        ]),
      );
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Recovered session'), findsOneWidget);
      expect(find.textContaining('could not be loaded'), findsNothing);
    },
  );
  testWidgets('Hero and workout rows use the destination catalog metadata', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    final hero = find.byKey(const ValueKey('discover-hero'));
    final heroWorkout = DiscoverCatalog.workout(DiscoverCatalog.heroWorkoutId);
    expect(
      find.descendant(of: hero, matching: find.text(heroWorkout.title)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: hero, matching: find.text(heroWorkout.summary)),
      findsOneWidget,
    );
    for (final id in ['beginner_chest_workout', 'before_workout_warm_up']) {
      final card = find.byKey(ValueKey('discover-workout-$id')).first;
      final workout = DiscoverCatalog.workout(id);
      await reveal(tester, card);
      expect(
        find.descendant(
          of: card,
          matching: find.text(workout.durationAndLevel),
        ),
        findsOneWidget,
      );
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(find.text(workout.summary), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    for (final card in DiscoverCatalog.workoutCards) {
      final workout = card.workout;
      expect(
        workout.durationAndLevel,
        '~${workout.estimatedMinutes} min • ${workout.difficulty.label}',
      );
    }
  });
  test(
    'Every Discover placement resolves to a real routine and bundled image',
    () {
      expect(DiscoverCatalog.workoutCards, hasLength(45));
      for (final card in DiscoverCatalog.workoutCards) {
        expect(card.workout.exerciseIds, isNotEmpty);
        expect(card.workout.exercises.length, card.workout.exerciseIds.length);
        expect(File(card.image).existsSync(), isTrue, reason: card.image);
      }
      expect(() => DiscoverCatalog.workout('missing'), throwsArgumentError);
      expect(() => DiscoverCatalog.collection('missing'), throwsArgumentError);
    },
  );
  test(
    'Collections resolve unique IDs and apply real equipment and focus filters',
    () {
      expect(
        DiscoverCatalog.collections.map((c) => c.id).toSet(),
        hasLength(6),
      );
      expect(DiscoverCatalog.collection('stay_active').workouts, hasLength(5));
      for (final collection in DiscoverCatalog.collections) {
        final workouts = collection.workouts;
        expect(workouts, isNotEmpty, reason: collection.id);
        expect(workouts.map((w) => w.id).toSet().length, workouts.length);
        for (final workout in workouts) {
          if (collection.equipmentOnly) {
            expect(
              workout.equipment.any(
                (e) =>
                    e != ExerciseEquipment.none && e != ExerciseEquipment.mat,
              ),
              isTrue,
            );
          }
          if (collection.focus != null) {
            expect(workout.focus.any(collection.focus!.contains), isTrue);
          }
        }
      }
    },
  );
  testWidgets('Hero opens its exact workout and Start launches a session', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('discover-hero')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TrainingWorkoutPage>(find.byType(TrainingWorkoutPage))
          .workout
          .id,
      DiscoverCatalog.heroWorkoutId,
    );
    await tester.tap(find.text('Start workout'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TrainingSessionPage>(find.byType(TrainingSessionPage))
          .workout
          .id,
      DiscoverCatalog.heroWorkoutId,
    );
    await tester.pumpWidget(const SizedBox());
  });
  for (final (section, id) in [
    ('Picks', 'beginner_chest_workout'),
    ('Beginners', 'beginner_arm_routine'),
    ('Fast', 'before_workout_warm_up'),
    ('Challenge', 'abs_advanced'),
    ('Stretch', 'neck_shoulder_tension_relief'),
  ]) {
    testWidgets('$section card opens the workout selected by ID', (
      tester,
    ) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      final card = find.byKey(ValueKey('discover-workout-$id'));
      await reveal(tester, card);
      await tester.tap(card.first);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TrainingWorkoutPage>(find.byType(TrainingWorkoutPage))
            .workout
            .id,
        id,
      );
      expect(find.text('Start workout'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(DiscoverPage), findsOneWidget);
    });
  }
  for (final collection in DiscoverCatalog.collections) {
    testWidgets(
      '${collection.id} opens its collection and a working workout detail',
      (tester) async {
        await tester.pumpWidget(app());
        await tester.pumpAndSettle();
        final card = find.byKey(
          ValueKey('discover-collection-${collection.id}'),
        );
        await reveal(tester, card);
        await tester.tap(card);
        await tester.pumpAndSettle();
        final page = tester.widget<TrainingCollectionPage>(
          find.byType(TrainingCollectionPage),
        );
        expect(page.title, collection.title);
        expect(
          page.workouts.map((w) => w.id),
          collection.workouts.map((w) => w.id),
        );
        await tester.tap(find.byType(TrainingWorkoutTile).first);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TrainingWorkoutPage>(find.byType(TrainingWorkoutPage))
              .workout
              .id,
          collection.workouts.first.id,
        );
      },
    );
  }
}
