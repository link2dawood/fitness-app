import 'dart:io';
import 'package:fitness_pro/core/routes/app_routes.dart';
import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/data/models/training_challenges.dart';
import 'package:fitness_pro/data/models/user_profile.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/pages/challenge_page.dart';
import 'package:fitness_pro/views/home/pages/training_page.dart';
import 'package:fitness_pro/views/workouts/challenge_day_page.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:fitness_pro/widgets/training_feature_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = File('C:/Windows/Fonts/arial.ttf');
    if (font.existsSync()) {
      await (FontLoader('ChallengeTest')..addFont(
            Future.value(ByteData.sublistView(font.readAsBytesSync())),
          ))
          .load();
    }
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Widget app(Widget home, {double scale = 1}) => MaterialApp(
    theme: ThemeData(fontFamily: 'ChallengeTest'),
    onGenerateRoute: AppRoutes.onGenerateRoute,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(disableAnimations: true, textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: home,
  );
  test(
    'All includes every explicit challenge once, including all featured cards',
    () {
      final all = TrainingChallenges.forProfile(null);
      expect(all.map((item) => item.workoutId).toSet(), hasLength(all.length));
      expect(
        all.map((item) => item.workoutId),
        containsAll([
          'intense_belly_fat_burn',
          'lose_weight_for_men',
          'lose_weight_for_women',
          ...TrainingChallenges.featured.map((item) => item.workoutId),
        ]),
      );
      for (final item in all) {
        expect(item.workout.exerciseIds, isNotEmpty);
      }
      expect(all.where((item) => item.referenceDay), hasLength(1));
    },
  );
  test('Goal badges use explicit goals rather than words in titles', () {
    final all = TrainingChallenges.catalog;
    expect(
      all
          .where((item) => item.matches('Build Muscle'))
          .map((item) => item.workoutId),
      contains('calisthenics_plan'),
    );
    expect(
      all
          .where((item) => item.matches('Lose Weight'))
          .map((item) => item.workoutId),
      containsAll([
        'calisthenics_plan',
        'lose_weight_for_men',
        'lose_weight_for_women',
      ]),
    );
    expect(
      all
          .where((item) => item.matches('Build Muscle'))
          .map((item) => item.workoutId),
      isNot(contains('lose_weight_for_men')),
    );
    expect(
      all
          .where((item) => item.matches('Dumbbell'))
          .every(
            (item) =>
                item.workout.equipment.contains(ExerciseEquipment.dumbbell),
          ),
      true,
    );
    expect(
      all
          .where((item) => item.matches('Abs'))
          .every((item) => item.workout.focus.contains(ExerciseFocus.abs)),
      true,
    );
    for (final badge in TrainingChallenges.filters) {
      expect(
        all.where((item) => item.matches(badge)),
        isNotEmpty,
        reason: badge,
      );
    }
  });
  testWidgets(
    'Training Challenge arrow opens detailed cards and every badge filters the list',
    (tester) async {
      final vm = HomeViewModel(OnboardingRepository());
      await tester.runAsync(vm.load);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: app(const TrainingPage()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('See all Challenge'));
      await tester.tap(find.byTooltip('See all Challenge'));
      await tester.pumpAndSettle();
      expect(find.byType(ChallengePage), findsOneWidget);
      for (final badge in TrainingChallenges.filters) {
        final chip = find.byKey(ValueKey('challenge-filter-$badge'));
        await tester.ensureVisible(chip);
        await tester.tap(chip);
        await tester.pumpAndSettle();
        expect(tester.widget<ChoiceChip>(chip).selected, true);
        final expected = TrainingChallenges.catalog
            .where((item) => item.matches(badge))
            .length;
        expect(
          find.text('$expected ${expected == 1 ? 'challenge' : 'challenges'}'),
          findsOneWidget,
        );
        for (final card in tester.widgetList<TrainingChallengeCard>(
          find.byType(TrainingChallengeCard),
        )) {
          expect(
            TrainingChallenges.catalog
                .singleWhere((item) => item.workoutId == card.workout.id)
                .matches(badge),
            true,
          );
          expect(card.compact, false);
        }
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      vm.dispose();
    },
  );
  testWidgets('Every available card can be reached by scrolling All', (
    tester,
  ) async {
    await tester.pumpWidget(app(const ChallengePage()));
    await tester.pumpAndSettle();
    for (final item in TrainingChallenges.catalog) {
      final card = find.byKey(ValueKey('challenge-card-${item.workoutId}'));
      await tester.scrollUntilVisible(
        card,
        400,
        scrollable: find.byType(Scrollable).last,
      );
      expect(card, findsOneWidget);
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'Reference card keeps Day 1 destination; other challenges open real workout details',
    (tester) async {
      await tester.pumpWidget(app(const ChallengePage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('START DAY 1'));
      await tester.pumpAndSettle();
      expect(find.byType(ChallengeDayPage), findsOneWidget);
      Navigator.of(tester.element(find.byType(ChallengeDayPage))).pop();
      await tester.pumpAndSettle();
      final chip = find.byKey(const ValueKey('challenge-filter-Calisthenics'));
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('START WORKOUT'));
      await tester.tap(find.text('START WORKOUT'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TrainingWorkoutPage>(find.byType(TrainingWorkoutPage))
            .workout
            .id,
        'calisthenics_plan',
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
  for (final config in [(320.0, 640.0, 2.0), (844.0, 390.0, 1.0)]) {
    testWidgets('Challenge cards and badges fit $config', (tester) async {
      tester.view.physicalSize = Size(config.$1, config.$2);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        app(
          const ChallengePage(
            profile: UserProfile(level: FitnessLevel.beginner),
          ),
          scale: config.$3,
        ),
      );
      await tester.pumpAndSettle();
      final chip = find.byKey(const ValueKey('challenge-filter-Build Muscle'));
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('START WORKOUT').first,
        250,
        scrollable: find.byType(Scrollable).last,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
