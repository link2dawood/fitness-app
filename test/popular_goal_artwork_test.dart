import 'package:fitness_pro/data/models/popular_goal_artwork.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/data/models/user_profile.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/home/pages/training_page.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:fitness_pro/widgets/training_feature_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all badges have distinct bundled photos for both profiles', () async {
    final paths = <String>{};
    for (final gender in [Gender.male, Gender.female]) {
      for (final goal in ['Burn Fat', 'Build Muscle', 'Keep Fit']) {
        final images = popularGoalArtwork(goal, gender);
        expect(images, hasLength(3));
        for (final path in images) {
          expect(
            (await rootBundle.load(path)).lengthInBytes,
            greaterThan(0),
            reason: path,
          );
          expect(paths.add(path), isTrue);
        }
      }
    }
  });

  testWidgets('a missing thumbnail keeps the workout tile usable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: TrainingWorkoutTile(
              workout: trainingWorkouts.first,
              imagePath: 'assets/missing-workout-photo.jpg',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    expect(find.text(trainingWorkouts.first.title), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(ClipRRect)), const Size(56, 56));
  });

  for (final gender in [Gender.female, Gender.male]) {
    testWidgets('Popular Goals uses distinct ${gender.name} badge photos', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final repository = OnboardingRepository();
      await repository.saveProfile(UserProfile(gender: gender));
      final vm = HomeViewModel(repository);
      await tester.runAsync(vm.load);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: const MaterialApp(home: TrainingPage()),
        ),
      );
      await tester.pumpAndSettle();
      for (final goal in ['Burn Fat', 'Build Muscle', 'Keep Fit']) {
        final chip = find.widgetWithText(ChoiceChip, goal);
        await tester.ensureVisible(chip);
        await tester.tap(chip);
        await tester.pumpAndSettle();
        final images = popularGoalArtwork(goal, gender);
        final rows = tester
            .widgetList<TrainingWorkoutTile>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is TrainingWorkoutTile &&
                    widget.key is ValueKey<String> &&
                    (widget.key! as ValueKey<String>).value.startsWith(
                      'popular-goal-',
                    ),
              ),
            )
            .toList();
        expect(rows.map((row) => row.imagePath), images);
        final collage = tester.widget<TrainingPhotoCard>(
          find.byWidgetPredicate(
            (widget) => widget is TrainingPhotoCard && widget.collage,
          ),
        );
        expect(collage.collageImages, images);
        rows.first.onOpen!();
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TrainingWorkoutPage>(find.byType(TrainingWorkoutPage))
              .imageOverride,
          images.first,
        );
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
      await tester.pumpWidget(const SizedBox());
      vm.dispose();
    });
  }
}
