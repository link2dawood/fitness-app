import 'dart:io';

import 'package:fitness_pro/data/models/user_profile.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/data/models/female_search_artwork.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/search/body_focus_results_view.dart';
import 'package:fitness_pro/views/search/search_view.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const badges = <String, String>{
    'Abs': 'abs',
    'Full Body': 'fullbody',
    'Arm': 'arm',
    'Butt & Leg': 'leg',
    'Chest': 'chest',
    'Back': 'back',
    'Shoulder': 'shoulder',
  };

  test('female Search workout artwork is bundled for every routine', () {
    for (final workout in trainingWorkouts) {
      final path = femaleSearchArtwork(workout);
      expect(path, contains('female'));
      expect(File(path).existsSync(), isTrue, reason: workout.id);
    }
  });

  testWidgets('Search Body Focus uses each profile-specific badge image', (
    tester,
  ) async {
    for (final gender in [Gender.female, Gender.male]) {
      SharedPreferences.setMockInitialValues({});
      await OnboardingRepository().saveProfile(UserProfile(gender: gender));
      await tester.pumpWidget(const MaterialApp(home: SearchView()));
      await tester.pumpAndSettle();

      final bodyFocusScroll = find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first;
      for (final entry in badges.entries) {
        final badge = find.byKey(ValueKey('search-body-focus-${entry.key}'));
        await tester.scrollUntilVisible(
          badge,
          120,
          scrollable: bodyFocusScroll,
        );
        final image = tester.widget<Image>(
          find.descendant(of: badge, matching: find.byType(Image)),
        );
        final path =
            'assets/images/body/${entry.value}'
            '${gender == Gender.female ? '_female' : ''}.png';
        final provider = image.image as ResizeImage;
        expect((provider.imageProvider as AssetImage).assetName, path);
        expect(File(path).existsSync(), isTrue);
      }
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('female Body Focus workout rows and details keep female images', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await OnboardingRepository().saveProfile(
      const UserProfile(gender: Gender.female),
    );
    await tester.pumpWidget(const MaterialApp(home: SearchView()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('search-body-focus-Abs')));
    await tester.pumpAndSettle();
    final absTile = tester.widget<TrainingWorkoutTile>(
      find.byType(TrainingWorkoutTile).first,
    );
    expect(absTile.gender, Gender.female);
    expect(absTile.imagePath, femaleSearchArtwork(absTile.workout));
    await tester.tap(find.byType(TrainingWorkoutTile).first);
    await tester.pumpAndSettle();
    final firstAbsDetail = tester.widget<TrainingWorkoutPage>(
      find.byType(TrainingWorkoutPage),
    );
    expect(
      firstAbsDetail.imageOverride,
      femaleSearchArtwork(firstAbsDetail.workout),
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    final absRow = find.byWidgetPredicate(
      (widget) =>
          widget is TrainingWorkoutTile && widget.workout.id == 'abs_beginner',
    );
    await tester.scrollUntilVisible(
      absRow,
      120,
      scrollable: find
          .descendant(
            of: find.byType(TrainingCollectionPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(absRow);
    await tester.pumpAndSettle();
    final absDetail = tester.widget<TrainingWorkoutPage>(
      find.byType(TrainingWorkoutPage),
    );
    expect(absDetail.imageOverride, femaleSearchArtwork(absDetail.workout));
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    final bodyFocusScroll = find
        .descendant(
          of: find.byType(ListView).first,
          matching: find.byType(Scrollable),
        )
        .first;
    final chestBadge = find.byKey(const ValueKey('search-body-focus-Chest'));
    await tester.scrollUntilVisible(
      chestBadge,
      120,
      scrollable: bodyFocusScroll,
    );
    await tester.tap(chestBadge);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<BodyFocusResultsView>(find.byType(BodyFocusResultsView))
          .gender,
      Gender.female,
    );
    await tester.tap(find.text('Chest Beginner').first);
    await tester.pumpAndSettle();
    final chestDetail = tester.widget<TrainingWorkoutPage>(
      find.byType(TrainingWorkoutPage),
    );
    expect(
      chestDetail.imageOverride,
      femaleSearchArtwork(chestDetail.workout, focusLabel: 'Chest'),
    );
  });

  testWidgets('female text search results use female images', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await OnboardingRepository().saveProfile(
      const UserProfile(gender: Gender.female),
    );
    await tester.pumpWidget(
      const MaterialApp(home: SearchView(initialQuery: 'chest')),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    final row = find.byType(TrainingWorkoutTile).first;
    final tile = tester.widget<TrainingWorkoutTile>(row);
    expect(tile.gender, Gender.female);
    expect(femaleSearchArtwork(tile.workout), contains('female'));
  });
}
