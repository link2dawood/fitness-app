import 'dart:io';

import 'package:fitness_pro/data/models/female_body_focus_artwork.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/data/models/user_profile.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/home/pages/training_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('all 21 Body Focus workouts have distinct bundled female photos', () {
    final workouts = trainingWorkouts.where(
      (workout) => RegExp(
        r'^(abs|arm|forearm|chest|leg|butt|shoulder_back)_(beginner|intermediate|advanced)$',
      ).hasMatch(workout.id),
    );
    expect(workouts, hasLength(21));
    expect(
      femaleBodyFocusArtwork.keys.toSet(),
      workouts.map((workout) => workout.id).toSet(),
    );
    expect(femaleBodyFocusArtwork.values.toSet(), hasLength(21));
    for (final path in femaleBodyFocusArtwork.values) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });

  for (final gender in [Gender.female, Gender.male]) {
    testWidgets('Body Focus uses ${gender.name} profile artwork', (
      tester,
    ) async {
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
      final tile = tester.widget<TrainingWorkoutTile>(
        find.byWidgetPredicate(
          (widget) =>
              widget is TrainingWorkoutTile &&
              widget.workout.id == 'abs_beginner',
        ),
      );
      expect(
        tile.imagePath,
        gender == Gender.female ? femaleBodyFocusArtwork['abs_beginner'] : null,
      );
      expect(tile.largeThumbnail, gender == Gender.female);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      vm.dispose();
    });
  }
}
