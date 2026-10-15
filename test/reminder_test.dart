import 'dart:convert';

import 'package:fitness_pro/core/settings/general_settings.dart';
import 'package:fitness_pro/core/settings/reminder_repository.dart';
import 'package:fitness_pro/views/settings/reminder_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  const reminder = WorkoutReminder(
    id: 1,
    hour: 20,
    minute: 0,
    days: [1, 2, 3, 4, 5, 6, 7],
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({
      ReminderRepository.key: [jsonEncode(reminder.toJson())],
    });
    calls.clear();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      GeneralSettings.channel,
      (call) async {
        calls.add(call);
        return null;
      },
    );
  });

  testWidgets(
    'Saved reminder cards support toggle, repeat editing, add, and delete',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ReminderView()));
      await tester.pumpAndSettle();
      expect(find.text('20:00'), findsOneWidget);
      expect(find.text('Sun, Mon, Tue, Wed, Thu, Fri, Sat'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect((await ReminderRepository().load()).single.enabled, isFalse);
      expect(calls.last.method, 'syncReminders');
      await tester.tap(find.text('Repeat'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Sun'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect((await ReminderRepository().load()).single.days, [
        2,
        3,
        4,
        5,
        6,
        7,
      ]);
      await tester.tap(find.byTooltip('Add reminder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final saved = await ReminderRepository().load();
      expect(saved.length, 2);
      expect(saved.last.enabled, isTrue);
      await tester.tap(find.byTooltip('Delete reminder').first);
      await tester.pumpAndSettle();
      expect((await ReminderRepository().load()).length, 1);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(const MaterialApp(home: ReminderView()));
      await tester.pumpAndSettle();
      expect(find.text('20:00'), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  test('Denied notifications do not save an enabled reminder', () async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      GeneralSettings.channel,
      (_) async => throw PlatformException(code: 'notifications_denied'),
    );
    final repository = ReminderRepository();
    await expectLater(
      repository.save([reminder.copyWith(hour: 7)]),
      throwsA(isA<PlatformException>()),
    );
    expect((await repository.load()).single.hour, 20);
  });

  test('Malformed reminders and invalid days are excluded', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(ReminderRepository.key, [
      'null',
      '{}',
      '{invalid',
      jsonEncode({
        ...reminder.toJson(),
        'days': [8],
      }),
      jsonEncode(reminder.toJson()),
    ]);
    expect((await ReminderRepository().load()).length, 1);
  });
}
