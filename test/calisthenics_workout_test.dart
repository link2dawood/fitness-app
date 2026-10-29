import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/pages/training_page.dart';
import 'package:fitness_pro/widgets/training_feature_cards.dart';
import 'package:provider/provider.dart';
import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/data/repositories/training_history_repository.dart';
import 'package:fitness_pro/views/home/pages/challenge_page.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalisthenicsClock implements Stopwatch {
  Duration value = Duration.zero;
  @override
  bool isRunning = false;
  void advance(int seconds) {
    if (isRunning) value += Duration(seconds: seconds);
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final workout = trainingWorkouts.singleWhere(
    (workout) => workout.id == 'calisthenics_plan',
  );
  const names = [
    'Cross-Body Shoulder Stretch',
    'Elbow Rotations',
    'Alternating Side Bends',
    'Spinal Roll Down',
    'Standing Hip Rotations Left',
    'Standing Hip Rotations Right',
    'Kneeling Push-Ups',
    'Bird Dog',
    'Reverse Hip Raise',
    'Superman',
    'Reverse Hip Raise',
    'Superman',
    'Leg Scissors',
    'Suitcase Crunch',
    'Left Pivot Step Lunge',
    'Right Pivot Step Lunge',
    'Prisoner Squat',
    'Hip Flexor Stretch Left',
    'Hip Flexor Stretch Right',
    'Straight Arm Plank To Downward Dog',
    'Cat Cow Pose',
    "Child's Pose",
  ];
  Widget app(Widget home) => MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: child!,
    ),
    home: home,
  );
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'settings_prep': 0,
      'settings_rest_mode': 'Off',
      'settings_music': false,
      'settings_voice': false,
      'settings_effect': false,
    }),
  );
  test(
    'Calisthenics matches all 22 screenshot entries, including repeats and durations',
    () {
      expect(workout.exercises.map((exercise) => exercise.name), names);
      expect(workout.exercises.every((exercise) => exercise.timed), true);
      expect(workout.targets, [for (var i = 0; i < 22; i++) i == 7 ? 40 : 30]);
      expect(
        workout.exercises.every(
          (exercise) => exercise.equipment.every(
            (equipment) => {
              ExerciseEquipment.none,
              ExerciseEquipment.mat,
            }.contains(equipment),
          ),
        ),
        true,
      );
      expect(
        workout.exerciseIds.where((id) => id == 'reverse_hip_raise'),
        hasLength(2),
      );
      expect(
        workout.exerciseIds.where((id) => id == 'superman_timed'),
        hasLength(2),
      );
      expect(List.generate(22, workout.targetAt).reduce((a, b) => a + b), 670);
    },
  );
  testWidgets('Calisthenics card opens the complete timed exercise list', (
    tester,
  ) async {
    await tester.pumpWidget(app(const ChallengePage()));
    await tester.pumpAndSettle();
    final badge = find.byKey(const ValueKey('challenge-filter-Calisthenics'));
    await tester.ensureVisible(badge);
    await tester.tap(badge);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('START WORKOUT'));
    await tester.tap(find.text('START WORKOUT'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TrainingWorkoutPage>(find.byType(TrainingWorkoutPage))
          .workout
          .id,
      workout.id,
    );
    for (var i = 0; i < names.length; i++) {
      final tile = find.byKey(
        ValueKey('training-exercise-calisthenics_plan-$i'),
      );
      try {
        await tester.scrollUntilVisible(
          tile,
          100,
          scrollable: find
              .descendant(
                of: find.byType(TrainingWorkoutPage),
                matching: find.byType(Scrollable),
              )
              .first,
        );
      } catch (error) {
        fail('Could not reveal entry $i (${names[i]}): $error');
      }
      final row = tester.widget<ListTile>(tile);
      expect((row.title as Text).data, names[i]);
      expect((row.subtitle as Text).data, '${i == 7 ? 40 : 30} seconds');
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'The complete Calisthenics session times every set and records 670 active seconds',
    (tester) async {
      await TrainingHistoryRepository.instance.load();
      final clocks = <CalisthenicsClock>[];
      await tester.pumpWidget(
        app(
          TrainingSessionPage(
            workout: workout,
            createStopwatch: () {
              final clock = CalisthenicsClock();
              clocks.add(clock);
              return clock;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < 22; i++) {
        expect(find.text('Exercise ${i + 1} of 22'), findsOneWidget);
        expect(find.text(names[i]), findsOneWidget);
        final action = find.widgetWithText(
          FilledButton,
          i == 21 ? 'Finish exercise' : 'Exercise done',
        );
        expect(tester.widget<FilledButton>(action).onPressed, isNull);
        for (final clock in clocks) {
          clock.advance(workout.targetAt(i));
        }
        await tester.pump(const Duration(milliseconds: 250));
        await tester.ensureVisible(action);
        await tester.tap(action);
        await tester.pump();
      }
      await tester.ensureVisible(find.text('Save completion'));
      await tester.tap(find.text('Save completion'));
      await tester.pumpAndSettle();
      expect(
        TrainingHistoryRepository.instance.entries.single.workoutId,
        'calisthenics_plan',
      );
      expect(TrainingHistoryRepository.instance.entries.single.seconds, 670);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'Training carousel Calisthenics card opens the 22 reference exercises directly',
    (tester) async {
      final model = HomeViewModel(OnboardingRepository());
      await tester.runAsync(model.load);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: model,
          child: app(const TrainingPage()),
        ),
      );
      await tester.pumpAndSettle();
      final card = find.byWidgetPredicate(
        (widget) =>
            widget is TrainingChallengeCard &&
            widget.workout.id == 'calisthenics_plan',
      );
      final start = find.descendant(
        of: card,
        matching: find.widgetWithText(FilledButton, 'START WORKOUT'),
      );
      await tester.ensureVisible(start);
      await tester.pumpAndSettle();
      await tester.tap(start);
      await tester.pumpAndSettle();
      final opened = tester
          .widget<TrainingWorkoutPage>(find.byType(TrainingWorkoutPage))
          .workout;
      expect(opened.id, 'calisthenics_plan');
      expect(opened.exercises.map((exercise) => exercise.name), names);
      expect(opened.exerciseIds, hasLength(22));
      expect(opened.targetAt(7), 40);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      model.dispose();
    },
  );
}
