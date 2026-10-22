import 'dart:convert';
import 'package:fitness_pro/core/theme/app_theme.dart';
import 'package:fitness_pro/data/models/discover_catalog.dart';
import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/data/models/training_recommendations.dart';
import 'package:fitness_pro/data/models/user_profile.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/data/repositories/training_history_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/pages/discover_page.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const beginner = UserProfile(
  level: FitnessLevel.beginner,
  goal: FitnessGoal.buildMuscle,
  focusAreas: {FocusArea.chest},
);
const advanced = UserProfile(
  level: FitnessLevel.advanced,
  goal: FitnessGoal.loseWeight,
  focusAreas: {FocusArea.legs},
);
Widget app({HomeViewModel? model, double scale = 1}) {
  final app = MaterialApp(
    theme: AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(disableAnimations: true, textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: const DiscoverPage(),
  );
  return model == null
      ? app
      : ChangeNotifierProvider.value(value: model, child: app);
}

Finder get section => find.byKey(const ValueKey('picks-section'));
List<String> pickIds(WidgetTester tester) => tester
    .widgetList(
      find.descendant(
        of: section,
        matching: find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key as ValueKey<String>).value.startsWith('discover-workout-'),
        ),
      ),
    )
    .map(
      (w) => (w.key as ValueKey<String>).value.substring(
        'discover-workout-'.length,
      ),
    )
    .toList();

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TrainingHistoryRepository.instance.load();
  });
  testWidgets('Personalized picks fit a narrow screen at 200% text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({
      'user_profile': jsonEncode(advanced.toJson()),
    });
    await tester.pumpWidget(app(scale: 2));
    await tester.pumpAndSettle();
    for (final id in pickIds(tester)) {
      final card = find.descendant(
        of: section,
        matching: find.byKey(ValueKey('discover-workout-$id')),
      );
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets(
    'An unfinished Home profile load does not block the editorial error/retry state',
    (tester) async {
      SharedPreferences.setMockInitialValues({'user_profile': 'invalid-json'});
      final model = HomeViewModel(OnboardingRepository());
      await tester.pumpWidget(app(model: model));
      await tester.pumpAndSettle();
      expect(find.text('Featured workouts'), findsOneWidget);
      expect(find.text('Retry personalized picks'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      model.dispose();
    },
  );
  for (final profile in [beginner, advanced]) {
    testWidgets(
      'Stored ${profile.level!.name} profile uses shared ranked recommendations and real destination',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'user_profile': jsonEncode(profile.toJson()),
        });
        await tester.pumpWidget(app());
        await tester.pumpAndSettle();
        final expected = TrainingRecommendations.forProfile(
          profile,
        ).take(7).map((w) => w.id).toList();
        expect(find.text('Picks for you'), findsOneWidget);
        expect(pickIds(tester), expected);
        if (profile.level == FitnessLevel.beginner) {
          expect(
            expected.every(
              (id) =>
                  DiscoverCatalog.workout(id).difficulty ==
                  ExerciseDifficulty.easy,
            ),
            isTrue,
          );
        }
        final card = find.descendant(
          of: section,
          matching: find.byKey(ValueKey('discover-workout-${expected.first}')),
        );
        await tester.ensureVisible(card);
        await tester.pumpAndSettle();
        await tester.tap(card);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TrainingWorkoutPage>(find.byType(TrainingWorkoutPage))
              .workout
              .id,
          expected.first,
        );
      },
    );
  }
  for (final profile in <UserProfile?>[
    null,
    const UserProfile(goal: FitnessGoal.buildMuscle),
  ]) {
    testWidgets(
      '${profile == null ? 'Missing' : 'Incomplete'} profile is clearly labeled editorial',
      (tester) async {
        if (profile != null) {
          SharedPreferences.setMockInitialValues({
            'user_profile': jsonEncode(profile.toJson()),
          });
        }
        await tester.pumpWidget(app());
        await tester.pumpAndSettle();
        expect(find.text('Featured workouts'), findsOneWidget);
        expect(find.text('Picks for you'), findsNothing);
        expect(
          find.text('Complete your fitness profile for personalized picks.'),
          findsOneWidget,
        );
        expect(
          pickIds(tester),
          DiscoverCatalog.picks
              .expand((g) => g)
              .map((c) => c.workoutId)
              .toList(),
        );
      },
    );
  }
  testWidgets('Live Home profile updates reorder Discover picks', (
    tester,
  ) async {
    final repository = OnboardingRepository();
    await repository.saveProfile(beginner);
    final model = HomeViewModel(repository);
    await model.load();
    await tester.pumpWidget(app(model: model));
    await tester.pumpAndSettle();
    final before = pickIds(tester);
    expect(
      before,
      TrainingRecommendations.forProfile(
        beginner,
      ).take(7).map((w) => w.id).toList(),
    );
    await tester.runAsync(() async {
      await repository.saveProfile(advanced);
      await model.load();
    });
    await tester.pumpAndSettle();
    final after = pickIds(tester);
    expect(
      after,
      TrainingRecommendations.forProfile(
        advanced,
      ).take(7).map((w) => w.id).toList(),
    );
    expect(after, isNot(equals(before)));
    await tester.pumpWidget(const SizedBox());
    model.dispose();
  });
  testWidgets(
    'Profile load failure keeps editorial cards and Retry recovers personalization',
    (tester) async {
      SharedPreferences.setMockInitialValues({'user_profile': 'invalid-json'});
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.text('Featured workouts'), findsOneWidget);
      expect(find.text('Picks for you'), findsNothing);
      expect(find.text('Retry personalized picks'), findsOneWidget);
      expect(pickIds(tester), hasLength(7));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_profile'), 'invalid-json');
      await prefs.setString('user_profile', jsonEncode(beginner.toJson()));
      await tester.ensureVisible(find.text('Retry personalized picks'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retry personalized picks'));
      await tester.pumpAndSettle();
      expect(find.text('Picks for you'), findsOneWidget);
      expect(
        pickIds(tester),
        TrainingRecommendations.forProfile(
          beginner,
        ).take(7).map((w) => w.id).toList(),
      );
    },
  );
  testWidgets(
    'Standalone Discover refreshes stored picks when the app resumes',
    (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.text('Featured workouts'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', jsonEncode(advanced.toJson()));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(
        pickIds(tester),
        TrainingRecommendations.forProfile(
          advanced,
        ).take(7).map((w) => w.id).toList(),
      );
    },
  );
}
