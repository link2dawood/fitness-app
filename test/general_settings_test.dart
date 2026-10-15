import 'package:fitness_pro/core/settings/general_settings.dart';
import 'package:fitness_pro/views/settings/general_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];

  setUp(() async {
    calls.clear();
    SharedPreferences.setMockInitialValues({});
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      GeneralSettings.channel,
      (call) async {
        calls.add(call);
        return null;
      },
    );
    await GeneralSettings.instance.load();
  });

  testWidgets('General Settings saves units and controls screen-on state', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: GeneralSettingsView()));
    expect(find.text('Remind me to work out every day'), findsOneWidget);
    await tester.tap(find.text('Metric & Imperial Units'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('lbs'));
    await tester.tap(find.text('ft / in'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('general_weight_imperial'), isTrue);
    expect(prefs.getBool('general_height_imperial'), isTrue);
    expect(prefs.getBool('general_keep_screen_on'), isTrue);
    expect(calls.last.method, 'keepScreenOn');
    expect(calls.last.arguments, isTrue);
    await GeneralSettings.instance.load();
    expect(GeneralSettings.instance.weightImperial, isTrue);
    expect(GeneralSettings.instance.keepScreenOn, isTrue);
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.text('Privacy policy not published'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test(
    'Unavailable screen control does not save a false enabled state',
    () async {
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        GeneralSettings.channel,
        (_) async => throw PlatformException(code: 'unavailable'),
      );
      await expectLater(
        GeneralSettings.instance.setKeepScreenOn(true),
        throwsA(isA<PlatformException>()),
      );
      expect(GeneralSettings.instance.keepScreenOn, isFalse);
    },
  );
}
