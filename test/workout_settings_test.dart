import 'package:fitness_pro/data/models/challenge_day.dart';
import 'package:fitness_pro/data/repositories/challenge_day_repository.dart';
import 'package:fitness_pro/core/settings/settings_record.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'dart:async';

import 'package:fitness_pro/views/settings/workout_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutFailStore extends InMemorySharedPreferencesStore {
  WorkoutFailStore(super.data) : super.withData();
  bool fail = true;
  Completer<void>? gate;
  int writes = 0;
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    writes++;
    await gate?.future;
    return fail ? false : super.setValue(type, key, value);
  }
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  MockStreamHandlerEventSink? audioEvents;
  Completer<void>? pendingStop;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'settings_rest_mode': 'Off',
      'settings_prep': 25,
      'settings_imported_tracks': ['null', '{}', '{invalid json'],
    });
    pendingStop = null;
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (_) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global/events'),
      (_) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async {
        if (call.method == 'create') {
          final playerId = (call.arguments as Map)['playerId'] as String;
          messenger.setMockStreamHandler(
            EventChannel('xyz.luan/audioplayers/events/$playerId'),
            MockStreamHandler.inline(
              onListen: (_, sink) {
                audioEvents = sink;
              },
            ),
          );
        }
        if (call.method == 'stop' && pendingStop != null) {
          await pendingStop!.future;
          throw PlatformException(
            code: 'test',
            message: 'Playback interrupted',
          );
        }
        if (call.method == 'getDuration' ||
            call.method == 'getCurrentPosition') {
          return 0;
        }
        return null;
      },
    );
  });

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: WorkoutSettingsView()));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Timers persist, music updates live, and dismissal during playback is safe',
    (tester) async {
      await open(tester);
      expect(find.text('25 secs >'), findsOneWidget);
      await tester.tap(find.text('Rest timer'));
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      final prefs = await SettingsRecord.load('settings_');
      expect(prefs.getString('settings_rest_mode'), 'Off');
      await tester.tap(find.text('Rest timer'));
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      Navigator.of(tester.element(find.byType(Switch))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Music'));
      await tester.pumpAndSettle();
      expect(tester.widget<Slider>(find.byType(Slider)).max, 1);
      expect(audioEvents, isNotNull);
      audioEvents!.success({'event': 'audio.onDuration', 'value': 120000});
      await tester.pump();
      await tester.pumpAndSettle();
      expect(tester.widget<Slider>(find.byType(Slider)).max, 120000);
      await tester.tap(find.byIcon(Icons.format_list_bulleted_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Playing Queue'), findsOneWidget);
      expect(find.text('Dancing All Night'), findsOneWidget);
      expect(find.text("Can't Stop"), findsOneWidget);
      expect(find.text('Holiday Wishes'), findsOneWidget);
      expect(find.text('null'), findsNothing);
      expect(tester.takeException(), isNull);
      Navigator.of(tester.element(find.text('Playing Queue'))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Music'));
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byType(Slider))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Music'));
      await tester.pumpAndSettle();
      pendingStop = Completer<void>();
      await tester.tap(find.byTooltip('Next track'));
      await tester.pump();
      Navigator.of(tester.element(find.byType(Slider))).pop();
      await tester.pumpAndSettle();
      pendingStop!.complete();
      await tester.pumpAndSettle();
      pendingStop = null;
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Failed settings commit keeps the draft and blocks duplicate Done taps',
    (tester) async {
      final store = WorkoutFailStore({'flutter.settings_rest_mode': 'Off'});
      SharedPreferencesStorePlatform.instance = store;
      await open(tester);
      await tester.tap(find.text('Rest timer'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      store.gate = Completer<void>();
      await tester.tap(find.text('Done'));
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Saving…'))
            .onPressed,
        isNull,
      );
      expect(store.writes, 1);
      store.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(Switch), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, true);
      expect(
        (await SettingsRecord.load(
          'settings_',
        )).getString('settings_rest_mode'),
        'Off',
      );
      store.fail = false;
      store.gate = null;
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(Switch), findsNothing);
      expect(
        (await SettingsRecord.load(
          'settings_',
        )).getString('settings_rest_mode'),
        'Custom',
      );
      await tester.pumpWidget(const SizedBox());
      SharedPreferences.setMockInitialValues({});
    },
  );
  testWidgets(
    'Global settings removes obsolete restart action and preserves the saved challenge',
    (tester) async {
      final day = ChallengeDay(
        entries: referenceDayEntries(),
        progress: ChallengeProgress(
          sessionId: 'keep-me',
          index: 0,
          phase: ChallengePhase.exercise,
          remainingMs: 10000,
          activeMs: 20000,
        ),
      );
      await tester.runAsync(() => ChallengeDayRepository.instance.save(day));
      await open(tester);
      expect(find.text('Restart progress'), findsNothing);
      expect(
        find.textContaining('progress tracking is not available'),
        findsNothing,
      );
      final saved = await tester.runAsync(ChallengeDayRepository.instance.load);
      expect(saved!.progress!.sessionId, 'keep-me');
      expect(saved.progress!.remainingMs, 10000);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
