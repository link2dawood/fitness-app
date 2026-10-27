import 'dart:async';
import 'package:fitness_pro/core/settings/settings_record.dart';
import 'package:fitness_pro/core/settings/general_settings.dart';
import 'package:fitness_pro/data/models/training_calendar.dart';
import 'package:fitness_pro/data/repositories/training_history_repository.dart';
import 'package:fitness_pro/views/plan/plan_generation_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class FailingSettingsStore extends InMemorySharedPreferencesStore {
  FailingSettingsStore(super.data) : super.withData();
  bool fail = false;
  Completer<void>? gate;
  int writes = 0;
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    writes++;
    await gate?.future;
    if (fail) return false;
    return super.setValue(type, key, value);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'All seven first weekdays agree across weeks, months and history',
    () async {
      await TrainingHistoryRepository.instance.load();
      for (final first in TrainingCalendar.firstDays) {
        final date = DateTime(2026, 1, 1, 23);
        final week = TrainingCalendar.week(date, first);
        expect(week.first.weekday, TrainingCalendar.firstWeekday(first));
        expect(week.map((d) => d.weekday), TrainingCalendar.weekdays(first));
        expect(week.every((d) => d.hour == 0), isTrue);
        SharedPreferences.setMockInitialValues({});
        await TrainingHistoryRepository.instance.load();
        for (final (id, finished) in [
          ('inside', date),
          (
            'outside',
            DateTime(week.first.year, week.first.month, week.first.day - 1),
          ),
        ]) {
          await TrainingHistoryRepository.instance.complete(
            TrainingCompletion(
              id: id,
              workoutId: 'test',
              title: 'Test',
              finishedAt: finished,
              seconds: 30,
            ),
          );
        }
        expect(
          TrainingHistoryRepository.instance.weeklyDays(date, firstDay: first),
          1,
        );
        final month = TrainingCalendar.month(date, first);
        final offset = month.indexWhere((d) => d != null);
        expect(
          TrainingCalendar.weekdays(first)[offset],
          DateTime(2026, 1, 1).weekday,
        );
      }
    },
  );
  test(
    'Legacy custom rest, Off and routine defaults share one contract',
    () async {
      for (final (mode, seconds) in [
        ('Off', 0),
        ('Default', 12),
        ('Custom', 45),
        ('45s', 45),
      ]) {
        SharedPreferences.setMockInitialValues({
          'settings_rest_mode': mode,
          'settings_rest_seconds': 45,
        });
        expect((await SettingsRecord.load('settings_')).restFor(12), seconds);
      }
    },
  );
  test(
    'A failed atomic write preserves both values and supports durable retry',
    () async {
      final store = FailingSettingsStore({
        'flutter.general_weight_imperial': false,
        'flutter.general_height_imperial': false,
      });
      SharedPreferencesStorePlatform.instance = store;
      final record = await SettingsRecord.load('general_');
      store.fail = true;
      await expectLater(
        record.update({
          'general_weight_imperial': true,
          'general_height_imperial': true,
        }),
        throwsStateError,
      );
      final old = await SettingsRecord.load('general_');
      expect(old.getBool('general_weight_imperial'), false);
      expect(old.getBool('general_height_imperial'), false);
      store.fail = false;
      await record.update({
        'general_weight_imperial': true,
        'general_height_imperial': true,
      });
      final saved = await SettingsRecord.load('general_');
      expect(saved.getBool('general_weight_imperial'), true);
      expect(saved.getBool('general_height_imperial'), true);
    },
  );
  test('Concurrent settings commits merge the latest durable record', () async {
    final first = await SettingsRecord.load('settings_');
    final second = await SettingsRecord.load('settings_');
    await Future.wait([
      first.setBool('settings_music', false),
      second.setInt('settings_prep', 25),
    ]);
    final saved = await SettingsRecord.load('settings_');
    expect(saved.getBool('settings_music'), false);
    expect(saved.getInt('settings_prep'), 25);
  });
  test(
    'Screen-on storage failure rolls back native state and observable state',
    () async {
      final calls = <bool>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(GeneralSettings.channel, (call) async {
            calls.add(call.arguments as bool);
            return null;
          });
      final store = FailingSettingsStore({});
      SharedPreferencesStorePlatform.instance = store;
      await GeneralSettings.instance.load();
      store.fail = true;
      await expectLater(
        GeneralSettings.instance.setKeepScreenOn(true),
        throwsStateError,
      );
      expect(GeneralSettings.instance.keepScreenOn, false);
      expect(calls, [false, true, false]);
      store.fail = false;
      await GeneralSettings.instance.setKeepScreenOn(true);
      expect(
        (await SettingsRecord.load(
          'general_',
        )).getBool('general_keep_screen_on'),
        true,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(GeneralSettings.channel, null);
    },
  );
  for (final delay in [100, 550, 1200]) {
    testWidgets(
      'Leaving plan generation after $delay ms cancels pending work',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: PlanGenerationView()));
        await tester.pump(const Duration(milliseconds: 400));
        if (delay >= 550) await tester.pump(const Duration(milliseconds: 200));
        if (delay >= 1200) await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 10));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
