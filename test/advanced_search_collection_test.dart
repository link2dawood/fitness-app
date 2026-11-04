import 'dart:io';
import 'package:fitness_pro/data/models/advanced_workouts.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/views/search/search_view.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'Advanced matches all 15 screenshot entries with distinct artwork and stable progress',
    () {
      expect(advancedWorkoutIds, [
        'abs_advanced',
        'arm_advanced',
        'chest_advanced',
        'leg_advanced',
        'shoulder_back_advanced',
        'body_calorie_burner',
        'belly_fat_burner_hiit_advanced',
        'booty_shaping_butt_lifting',
        'brutal_ladder_hiit',
        'build_wider_shoulders_advanced',
        'man_boobs_hiit_advanced',
        'intense_leg_transformation',
        'killer_chest_workout',
        'killer_core_hiit_advanced',
        'ripped_v_cut_abs_advanced',
      ]);
      expect(advancedWorkouts.map((w) => w.id).toSet(), hasLength(15));
      expect(advancedArtwork.values.toSet(), hasLength(15));
      for (final w in advancedWorkouts) {
        final canonical = trainingWorkouts.singleWhere(
          (entry) => entry.id == w.id,
        );
        expect(w.exercises, isNotEmpty);
        expect(w.exerciseIds, canonical.exerciseIds);
        expect(w.targets, canonical.targets);
        expect(w.difficulty, canonical.difficulty);
        expect(w.progressStorageKey, canonical.progressStorageKey);
        expect(File(w.image).existsSync(), isTrue, reason: w.id);
      }
      final booty = advancedWorkouts.singleWhere(
        (w) => w.id == 'booty_shaping_butt_lifting',
      );
      expect(booty.title, 'Booty Shaping & Butt Lifting');
      expect(booty.exercises, hasLength(32));
      expect(booty.targets, hasLength(32));
      expect(booty.targets!.every((value) => value > 0), isTrue);
      expect(booty.estimatedMinutes, 30);
      expect(booty.difficulty, ExerciseDifficulty.hard);
      expect(booty.focus, contains(ExerciseFocus.glutes));
      expect(
        booty.progressStorageKey,
        isNot(
          trainingWorkouts
              .singleWhere((w) => w.id == 'rounder_booty_shaping')
              .progressStorageKey,
        ),
      );
    },
  );
  Widget app(Widget home, {double scale = 1}) => MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(disableAnimations: true, textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: home,
  );
  testWidgets('Advanced badge opens every workout with its own cover', (
    tester,
  ) async {
    await tester.pumpWidget(app(const SearchView()));
    await tester.pumpAndSettle();
    final badge = find.byKey(const ValueKey('search-level-Advanced'));
    await tester.ensureVisible(badge);
    await tester.pumpAndSettle();
    await tester.tap(badge);
    await tester.pumpAndSettle();
    final page = tester.widget<TrainingCollectionPage>(
      find.byType(TrainingCollectionPage),
    );
    expect(page.title, 'Advanced');
    expect(page.workouts.map((w) => w.id), advancedWorkoutIds);
    for (final workout in page.workouts) {
      final tile = find.byWidgetPredicate(
        (w) => w is TrainingWorkoutTile && w.workout.id == workout.id,
      );
      await tester.scrollUntilVisible(
        tile,
        120,
        scrollable: find
            .descendant(
              of: find.byType(TrainingCollectionPage),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      final image = tester.widget<Image>(
        find.descendant(of: tile, matching: find.byType(Image)),
      );
      final provider = image.image is ResizeImage
          ? (image.image as ResizeImage).imageProvider
          : image.image;
      expect((provider as AssetImage).assetName, advancedArtwork[workout.id]);
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TrainingWorkoutPage>(find.byType(TrainingWorkoutPage))
            .workout
            .id,
        workout.id,
      );
      expect(find.text('Start workout'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });
  testWidgets('Advanced list fits narrow screens with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      app(
        TrainingCollectionPage(
          title: 'Advanced',
          workouts: advancedWorkouts,
          artwork: advancedArtwork,
        ),
        scale: 2,
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Ripped V-Cut Abs Sculpting - advanced'),
      160,
      maxScrolls: 120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
