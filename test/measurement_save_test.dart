import 'dart:async';
import 'dart:convert';
import 'package:fitness_pro/core/settings/general_settings.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/data/repositories/weight_history_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/pages/report_page.dart';
import 'package:fitness_pro/views/onboarding/widgets/ruler_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class ControlledStore extends InMemorySharedPreferencesStore {
  ControlledStore(super.data) : super.withData();
  String? failKey;
  Completer<void>? gate;
  int writes = 0;
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    writes++;
    await gate?.future;
    if (key == failKey) return false;
    return super.setValue(type, key, value);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await WeightHistoryRepository.instance.load();
    await OnboardingRepository().saveMeasurements(heightCm: 180);
  });
  late ControlledStore store;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = ControlledStore({
      'flutter.user_profile': jsonEncode({'weightKg': 80, 'heightCm': 180}),
      'flutter.onboarding_completed': false,
    });
    SharedPreferencesStorePlatform.instance = store;
  });
  tearDown(() => SharedPreferences.setMockInitialValues({}));

  test(
    'failed measurement writes do not publish and retry preserves onboarding status',
    () async {
      final repo = OnboardingRepository();
      final model = HomeViewModel(repo);
      addTearDown(model.dispose);
      await model.load();
      store.failKey = 'flutter.user_profile';
      await expectLater(model.updateHeight(190), throwsStateError);
      expect(model.profile!.heightCm, 180);
      expect((await repo.loadProfile())!.heightCm, 180);
      store.failKey = null;
      await model.updateHeight(190);
      await model.updateWeight(72.6);
      expect(model.profile!.heightCm, 190);
      expect(model.profile!.weightKg, 72.6);
      expect(await repo.isOnboardingCompleted(), isFalse);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_profile');
      await repo.saveMeasurements(weightKg: 71.2);
      expect(await repo.isOnboardingCompleted(), isFalse);
    },
  );

  test(
    'false history storage result retains authoritative records across reload',
    () async {
      final repo = WeightHistoryRepository();
      await repo.save(WeightRecord(date: DateTime(2026, 10, 1), kg: 80));
      store.failKey = 'flutter.${WeightHistoryRepository.storageKey}';
      await expectLater(
        repo.save(WeightRecord(date: DateTime(2026, 10, 2), kg: 72.6)),
        throwsStateError,
      );
      expect(repo.records.length, 1);
      await repo.load();
      expect(repo.records.single.kg, 80);
    },
  );

  test('onboarding completion storage failure is reported', () async {
    final repo = OnboardingRepository();
    final profile = (await repo.loadProfile())!;
    store.failKey = 'flutter.onboarding_completed';
    await expectLater(repo.saveProfile(profile), throwsStateError);
  });

  for (final weight in [false, true]) {
    testWidgets(
      '${weight ? 'Weight' : 'Height'} retains draft after failure and blocks duplicate saves',
      (tester) async {
        final model = HomeViewModel(OnboardingRepository());
        addTearDown(model.dispose);
        await tester.runAsync(model.load);
        GeneralSettings.instance.weightImperial = false;
        GeneralSettings.instance.heightImperial = false;
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: model,
            child: const MaterialApp(home: ReportPage()),
          ),
        );
        await tester.pumpAndSettle();
        final target = find.text(weight ? 'Log' : 'Height');
        await tester.scrollUntilVisible(target, 250);
        await tester.tap(target);
        await tester.pumpAndSettle();
        tester.widget<RulerPicker>(find.byType(RulerPicker)).onDecimalChanged!(
          weight ? 72.6 : 190,
        );
        await tester.pump();
        store.failKey = weight
            ? 'flutter.${WeightHistoryRepository.storageKey}'
            : 'flutter.user_profile';
        final before = store.writes;
        await tester.runAsync(() async {
          store.gate = Completer<void>();
          await tester.tap(find.text('Save'));
          await tester.tap(find.text('Save'));
          await Future<void>.delayed(const Duration(milliseconds: 30));
          expect(store.writes - before, 1);
          store.gate!.complete();
          await Future<void>.delayed(const Duration(milliseconds: 30));
        });
        await tester.pumpAndSettle();
        expect(
          find.text(
            weight
                ? 'Could not save weight. Please retry.'
                : 'Could not save height. Please retry.',
          ),
          findsOneWidget,
        );
        expect(model.profile!.heightCm, 180);
        expect(model.profile!.weightKg, 80);
        store.failKey = null;
        await tester.runAsync(() async {
          await tester.tap(find.text('Save'));
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pumpAndSettle();
        expect(find.byType(RulerPicker), findsNothing);
        expect(
          weight ? model.profile!.weightKg : model.profile!.heightCm,
          weight ? 72.6 : 190,
        );
        expect(await OnboardingRepository().isOnboardingCompleted(), isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
