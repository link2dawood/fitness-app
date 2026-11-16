import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/data/models/female_search_artwork.dart';
import 'package:fitness_pro/data/models/training_recommendations.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/data/models/user_profile.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/pages/build_muscle_more_page.dart';
import 'package:fitness_pro/views/home/pages/burn_fat_more_page.dart';
import 'package:fitness_pro/views/home/pages/just_for_you_page.dart';
import 'package:fitness_pro/views/home/pages/keep_fit_more_page.dart';
import 'package:fitness_pro/views/home/pages/stretch_warm_up_page.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/home/pages/training_page.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:fitness_pro/widgets/training_feature_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const profile = UserProfile(
    gender: Gender.female,
    level: FitnessLevel.beginner,
    focusAreas: {FocusArea.chest},
    goal: FitnessGoal.buildMuscle,
  );
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('female Training sections use female artwork into detail', (
    tester,
  ) async {
    final repository = OnboardingRepository();
    await repository.saveProfile(profile);
    final vm = HomeViewModel(repository);
    await tester.runAsync(vm.load);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
        child: const MaterialApp(home: TrainingPage()),
      ),
    );
    await tester.pumpAndSettle();

    final ranked = TrainingRecommendations.forProfile(profile);
    final recommendedCard = tester.widget<TrainingPhotoCard>(
      find.byWidgetPredicate(
        (widget) => widget is TrainingPhotoCard && widget.recommended,
      ),
    );
    expect(recommendedCard.image, femaleSearchArtwork(ranked.first));
    for (final workout
        in trainingWorkouts
            .where((item) => item.type != ExerciseType.training)
            .take(4)) {
      final card = tester.widget<TrainingPhotoCard>(
        find.byWidgetPredicate(
          (widget) =>
              widget is TrainingPhotoCard && widget.title == workout.title,
        ),
      );
      expect(card.image, femaleSearchArtwork(workout));
    }
    final collage = tester.widget<TrainingPhotoCard>(
      find.byWidgetPredicate(
        (widget) => widget is TrainingPhotoCard && widget.collage,
      ),
    );
    expect(collage.collageImages, hasLength(3));
    expect(
      collage.collageImages!.every((path) => path.contains('female')),
      isTrue,
    );
    expect(
      tester
          .widgetList<TrainingWorkoutTile>(find.byType(TrainingWorkoutTile))
          .every((tile) => tile.gender == Gender.female),
      isTrue,
    );

    recommendedCard.onTap();
    await tester.pumpAndSettle();
    final detail = tester.widget<TrainingWorkoutPage>(
      find.byType(TrainingWorkoutPage),
    );
    expect(detail.imageOverride, femaleSearchArtwork(detail.workout));
    await tester.pumpWidget(const SizedBox());
    vm.dispose();
  });

  testWidgets('female Training See all lists receive the profile', (
    tester,
  ) async {
    for (final page in <Widget>[
      const JustForYouPage(profile: profile),
      const StretchWarmUpPage(profile: profile),
      const BuildMuscleMorePage(profile: profile),
      const BurnFatMorePage(profile: profile),
      const KeepFitMorePage(profile: profile),
    ]) {
      await tester.pumpWidget(MaterialApp(home: page));
      await tester.pumpAndSettle();
      final list = tester.widget<TrainingCollectionPage>(
        find.byType(TrainingCollectionPage),
      );
      expect(list.gender, Gender.female);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
