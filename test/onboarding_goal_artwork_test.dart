import 'package:fitness_pro/data/models/user_profile.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/viewmodels/onboarding_viewmodel.dart';
import 'package:fitness_pro/views/onboarding/steps/goal_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  for (final gender in [Gender.male, Gender.female, Gender.other, null]) {
    testWidgets(
      'every onboarding goal loads artwork for ${gender?.name ?? 'default'}',
      (tester) async {
        final vm = OnboardingViewModel(OnboardingRepository());
        if (gender != null) vm.selectGender(gender);
        final expected = gender == Gender.female
            ? {
                FitnessGoal.loseWeight:
                    'assets/images/ui/goal_female_lose_weight.jpg',
                FitnessGoal.buildMuscle:
                    'assets/images/ui/goal_female_build_muscle.jpg',
                FitnessGoal.keepFit:
                    'assets/images/ui/goal_female_keep_fit.jpg',
                FitnessGoal.endurance:
                    'assets/images/ui/goal_female_endurance.jpg',
              }
            : {
                FitnessGoal.loseWeight:
                    'assets/images/workouts/popular_burn_fat_male_1.jpg',
                FitnessGoal.buildMuscle:
                    'assets/images/workouts/popular_build_muscle_male_3.jpg',
                FitnessGoal.keepFit:
                    'assets/images/workouts/popular_keep_fit_male_1.jpg',
                FitnessGoal.endurance:
                    'assets/images/workouts/popular_burn_fat_male_3.jpg',
              };
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: vm,
            child: const MaterialApp(home: Scaffold(body: GoalStep())),
          ),
        );
        await tester.pumpAndSettle();

        for (final goal in FitnessGoal.values) {
          final artwork = find.byKey(ValueKey('goal-artwork-${goal.name}'));
          await tester.scrollUntilVisible(
            artwork,
            120,
            scrollable: find.descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            ),
          );
          await tester.pumpAndSettle();
          final image = tester.widget<Image>(artwork);
          expect((image.image as AssetImage).assetName, expected[goal]);
          final data = await tester.runAsync(
            () => rootBundle.load(expected[goal]!),
          );
          expect(data!.lengthInBytes, greaterThan(0), reason: goal.name);
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox());
        vm.dispose();
      },
    );
  }
}
