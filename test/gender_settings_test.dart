import 'package:fitness_pro/data/models/user_profile.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/views/settings/gender_settings_view.dart';
import 'package:fitness_pro/core/routes/app_routes.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/home_view.dart';
import 'package:fitness_pro/views/home/pages/training_page.dart';
import 'package:fitness_pro/views/home/pages/discover_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final gender in [Gender.male, Gender.female]) {
    testWidgets(
      'legacy Other profile requires explicit ${gender.name} selection',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final repository = OnboardingRepository();
        await repository.saveProfile(
          const UserProfile(gender: Gender.other, weightKg: 81),
        );
        final vm = HomeViewModel(repository);
        await tester.runAsync(vm.load);
        await tester.pumpWidget(
          Provider.value(
            value: repository,
            child: ChangeNotifierProvider.value(
              value: vm,
              child: MaterialApp(
                home: const HomeView(),
                onGenerateRoute: AppRoutes.onGenerateRoute,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Choose a workout profile'), findsOneWidget);
        expect(find.byType(TrainingPage), findsNothing);
        expect(find.byType(DiscoverPage), findsNothing);

        await tester.tap(find.text('Choose profile'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ListTile, 'Gender'));
        await tester.pumpAndSettle();
        expect(
          find.byWidgetPredicate(
            (widget) => widget is ListTile &&
                widget.title is Text &&
                (widget.title! as Text).data == 'Other',
          ),
          findsNothing,
        );
        expect(find.widgetWithText(ListTile, 'Male'), findsOneWidget);
        expect(find.widgetWithText(ListTile, 'Female'), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'))
              .onPressed,
          isNull,
        );
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect((await repository.loadProfile())!.gender, Gender.other);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('Choose a workout profile'), findsOneWidget);

        await tester.tap(find.text('Choose profile'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ListTile, 'Gender'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ListTile, gender.label));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('Choose a workout profile'), findsNothing);
        expect(find.byType(TrainingPage), findsOneWidget);
        expect(vm.profile!.gender, gender);
        final saved = (await repository.loadProfile())!;
        expect(saved.gender, gender);
        expect(saved.weightKg, 81);
        await tester.pumpWidget(const SizedBox());
        vm.dispose();
      },
    );
  }

  testWidgets(
    'Gender and birth date cards save changes and cancel discards edits',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repository = OnboardingRepository();
      await repository.saveProfile(
        const UserProfile(gender: Gender.male, weightKg: 81),
      );
      await tester.pumpWidget(
        Provider.value(
          value: repository,
          child: const MaterialApp(home: GenderSettingsView()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.text('Not set'), findsOneWidget);
      await tester.tap(find.widgetWithText(ListTile, 'Gender'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Female'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect((await repository.loadProfile())!.gender, Gender.female);
      await tester.tap(find.text('Date of Birth'));
      await tester.pumpAndSettle();
      tester
          .widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker))
          .onDateTimeChanged(DateTime(2000, 2, 29));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect((await repository.loadProfile())!.dateOfBirth, isNull);
      await tester.tap(find.text('Date of Birth'));
      await tester.pumpAndSettle();
      tester
          .widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker))
          .onDateTimeChanged(DateTime(2000, 2, 29));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final profile = (await repository.loadProfile())!;
      expect(profile.dateOfBirth, DateTime(2000, 2, 29));
      expect(profile.gender, Gender.female);
      expect(profile.weightKg, 81);
      expect(tester.takeException(), isNull);
    },
  );

  test('Birth date survives profile updates and calculates age', () {
    final today = DateTime.now();
    final birth = DateTime(today.year - 30, today.month, today.day);
    final profile = UserProfile(dateOfBirth: birth);
    expect(profile.age, 30);
    final restored = UserProfile.fromJson(
      profile.copyWith(weightKg: 90).toJson(),
    );
    expect(restored.dateOfBirth, birth);
    expect(restored.age, 30);
    expect(UserProfile.fromJson({'age': 42}).age, 42);
  });
}
