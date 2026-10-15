import 'package:fitness_pro/core/settings/tts_service.dart';
import 'package:fitness_pro/views/settings/voice_options_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <String>[];
  late Map<String, dynamic> state;
  setUp(() {
    calls.clear();
    state = {
      'engine': 'system',
      'engineLabel': 'Android Voice',
      'engines': [
        {'id': 'system', 'label': 'Android Voice'},
        {'id': 'other', 'label': 'Other Voice'},
      ],
      'language': '',
      'languageLabel': 'Default',
      'languages': [
        {'id': 'fr-FR', 'label': 'French'},
      ],
      'natural': false,
      'naturalAvailable': true,
    };
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      TtsService.channel,
      (call) async {
        calls.add(call.method);
        if (call.method == 'getState' || call.method == 'refresh') return state;
        if (call.method == 'setNatural') state['natural'] = call.arguments;
        if (call.method == 'setEngine') {
          state['engine'] = call.arguments;
          state['engineLabel'] = 'Other Voice';
        }
        if (call.method == 'setLanguage') {
          state['language'] = call.arguments;
          state['languageLabel'] = 'French';
        }
        return null;
      },
    );
  });

  testWidgets(
    'Voice options test audio and select engine, language, and natural voice',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: VoiceOptionsView()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Natural Voice'));
      await tester.pumpAndSettle();
      expect(state['natural'], isTrue);
      await tester.tap(find.text('Test Voice'));
      await tester.pumpAndSettle();
      expect(calls, contains('testVoice'));
      await tester.tap(find.text('Select TTS Engine'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Other Voice'));
      await tester.pumpAndSettle();
      expect(state['engine'], 'other');
      await tester.ensureVisible(find.text('Voice language'));
      await tester.tap(find.text('Voice language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('French'));
      await tester.pumpAndSettle();
      expect(state['language'], 'fr-FR');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Download and device-settings actions invoke native controls', (
    tester,
  ) async {
    state['naturalAvailable'] = false;
    await tester.pumpWidget(const MaterialApp(home: VoiceOptionsView()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Natural Voice'));
    await tester.pumpAndSettle();
    expect(calls, contains('installLanguage'));
    await tester.ensureVisible(find.text('Download TTS Engine'));
    await tester.tap(find.text('Download TTS Engine'));
    await tester.pumpAndSettle();
    expect(calls, contains('installEngine'));
    await tester.ensureVisible(find.text('Device TTS Setting'));
    await tester.tap(find.text('Device TTS Setting'));
    await tester.pumpAndSettle();
    expect(calls, contains('openSettings'));
    expect(tester.takeException(), isNull);
  });
}
