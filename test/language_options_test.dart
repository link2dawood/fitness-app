import 'package:fitness_pro/core/settings/general_settings.dart';
import 'package:fitness_pro/data/models/app_language.dart';
import 'package:fitness_pro/views/settings/language_options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      GeneralSettings.channel,
      (_) async => null,
    );
    await GeneralSettings.instance.load();
  });

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showLanguageOptions(context),
              child: const Text('Languages'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Languages'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Language selection saves and right-to-left names align correctly',
    (tester) async {
      await open(tester);
      final arabic = tester.widget<Text>(find.text('العربية'));
      expect(arabic.textDirection, TextDirection.rtl);
      expect(arabic.textAlign, TextAlign.right);
      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();
      expect(find.byType(LanguageOptionsDialog), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('general_language'), 'ar');
      await GeneralSettings.instance.load();
      expect(GeneralSettings.instance.language, AppLanguage.arabic);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Scrollable list includes final languages and restores selection',
    (tester) async {
      await open(tester);
      await tester.scrollUntilVisible(find.text('ไทย'), 250);
      await tester.tap(find.text('ไทย'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Languages'));
      await tester.pumpAndSettle();
      expect(find.text('ไทย'), findsOneWidget);
      expect(GeneralSettings.instance.language, AppLanguage.thai);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'All screenshot languages have unique codes and unknown values fall back',
    () {
      expect(AppLanguage.values.length, 19);
      expect(
        AppLanguage.values.map((language) => language.code).toSet().length,
        19,
      );
      expect(AppLanguage.fromCode('invalid'), AppLanguage.english);
    },
  );
}
