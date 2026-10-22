import 'dart:convert';
import 'package:fitness_pro/core/settings/general_settings.dart';
import 'package:fitness_pro/data/models/user_profile.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/data/repositories/weight_history_repository.dart';
import 'package:fitness_pro/views/onboarding/widgets/ruler_picker.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/pages/report_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await WeightHistoryRepository.instance.load();
  });
  Future<HomeViewModel> open(WidgetTester tester, UserProfile? profile) async {
    SharedPreferences.setMockInitialValues({
      if (profile != null) 'user_profile': jsonEncode(profile.toJson()),
    });
    GeneralSettings.instance.weightImperial = false;
    final model = HomeViewModel(OnboardingRepository());
    addTearDown(model.dispose);
    await tester.runAsync(model.load);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: model,
        child: const MaterialApp(home: ReportPage()),
      ),
    );
    await tester.pumpAndSettle();
    return model;
  }

  Future<void> showBmi(WidgetTester tester) async {
    await tester.scrollUntilVisible(find.text('BMI'), 250);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'decimal log saves profile and history, survives reopening, and cancel is inert',
    (tester) async {
      final model = await open(
        tester,
        const UserProfile(weightKg: 80, heightCm: 180),
      );
      await tester.ensureVisible(find.text('Log'));
      await tester.tap(find.text('Log'));
      await tester.pumpAndSettle();
      tester.widget<RulerPicker>(find.byType(RulerPicker)).onDecimalChanged!(
        72.6,
      );
      await tester.pump();
      await tester.runAsync(() async {
        await tester.tap(find.text('Save'));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect((await OnboardingRepository().loadProfile())!.weightKg, 72.6);
      final reopened = WeightHistoryRepository();
      await tester.runAsync(reopened.load);
      expect(reopened.records.single.kg, 72.6);
      await tester.tap(find.text('Log'));
      await tester.pumpAndSettle();
      tester.widget<RulerPicker>(find.byType(RulerPicker)).onDecimalChanged!(
        90.2,
      );
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(WeightHistoryRepository.instance.records.single.kg, 72.6);
      expect(find.text('72.6 kg'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: model,
          child: const MaterialApp(home: ReportPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('72.6 kg'), findsOneWidget);
      expect(find.text('No logged weight history yet.'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'saved profile weight drives current weight and BMI without sample history',
    (tester) async {
      final model = await open(
        tester,
        const UserProfile(weightKg: 80, heightCm: 180),
      );
      expect(find.text('80.0 kg'), findsOneWidget);
      expect(find.text('No logged weight history yet.'), findsOneWidget);
      expect(find.text('48.4 kg'), findsNothing);
      await showBmi(tester);
      expect(find.text('24.7'), findsOneWidget);
      await tester.runAsync(() => model.updateWeight(90));
      await tester.pumpAndSettle();
      expect(find.text('27.8'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: model,
          child: const MaterialApp(home: ReportPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('90.0 kg'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final profile in <UserProfile?>[
    null,
    const UserProfile(weightKg: 0),
    const UserProfile(heightCm: 0),
  ]) {
    testWidgets(
      'missing or invalid measurements have no fabricated BMI ($profile)',
      (tester) async {
        await open(tester, profile);
        await showBmi(tester);
        expect(
          find.text('BMI unavailable. Add a saved weight and height.'),
          findsOneWidget,
        );
        expect(find.text('Normal weight'), findsNothing);
        if (profile == null || profile.weightKg == 0) {
          expect(
            find.text('No saved weight yet. Tap Log to add your weight.'),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
