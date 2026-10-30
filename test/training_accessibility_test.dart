import 'package:fitness_pro/core/theme/app_theme.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/data/repositories/training_history_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/home_view.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/home/pages/training_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  builder: (context, widget) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: widget!,
  ),
  home: child,
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TrainingHistoryRepository.instance.load();
  });
  testWidgets(
    'Training icon actions have names, button semantics and 48px targets',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        final model = HomeViewModel(OnboardingRepository());
        await model.load();
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: model,
            child: app(const TrainingPage()),
          ),
        );
        await tester.pumpAndSettle();
        for (final label in [
          'Training streak',
          'Pro plans',
          'Edit weekly goal',
          'See all Challenge',
        ]) {
          final button = find.byTooltip(label);
          await tester.ensureVisible(button);
          await tester.pumpAndSettle();
          final size = tester.getSize(button);
          expect(size.width, greaterThanOrEqualTo(48));
          expect(size.height, greaterThanOrEqualTo(48));
          expect(
            tester.semantics.find(button),
            isSemantics(isButton: true, hasTapAction: true),
          );
        }
        await tester.pumpWidget(const SizedBox());
        model.dispose();
        expect(tester.takeException(), isNull);
      } finally {
        handle.dispose();
      }
    },
  );
  testWidgets(
    'A screen reader can open a workout through one descriptive action',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        final workout = trainingWorkouts.first;
        final label = 'Open workout: ${workout.title}. ${workout.summary}';
        await tester.pumpWidget(
          app(Scaffold(body: TrainingWorkoutTile(workout: workout))),
        );
        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel(label), findsOneWidget);
        expect(
          tester.semantics.find(find.bySemanticsLabel(label)),
          isSemantics(isButton: true, hasTapAction: true),
        );
        tester.semantics.tap(find.semantics.byLabel(label));
        await tester.pumpAndSettle();
        expect(find.text('Start workout'), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        handle.dispose();
      }
    },
  );
  testWidgets('Home navigation exposes selected tabs and semantic activation', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      final model = HomeViewModel(OnboardingRepository());
      await model.load();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: model,
          child: app(const HomeView()),
        ),
      );
      await tester.pumpAndSettle();
      for (final label in ['Training', 'Discover', 'Report', 'Settings']) {
        final button = find.bySemanticsLabel('$label tab');
        expect(button, findsOneWidget);
        final size = tester.getSize(button);
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
      expect(
        tester.semantics.find(find.bySemanticsLabel('Training tab')),
        isSemantics(isButton: true, isSelected: true, hasTapAction: true),
      );
      tester.semantics.tap(find.semantics.byLabel('Discover tab'));
      await tester.pumpAndSettle();
      expect(model.currentTab, 1);
      expect(
        tester.semantics.find(find.bySemanticsLabel('Discover tab')),
        isSemantics(isSelected: true, hasTapAction: true),
      );
      expect(
        tester.semantics.find(find.bySemanticsLabel('Training tab')),
        isSemantics(isSelected: false),
      );
      await tester.pumpWidget(const SizedBox());
      model.dispose();
      expect(tester.takeException(), isNull);
    } finally {
      handle.dispose();
    }
  });
}
