import 'dart:convert';

import 'package:fitness_pro/views/settings/feature_suggestions_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showFeatureSuggestions(context),
              child: const Text('Suggest'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Suggest'));
    await tester.pumpAndSettle();
  }

  testWidgets('Feature chips save selected requests and show confirmation', (
    tester,
  ) async {
    await open(tester);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    final option = find.widgetWithText(FilterChip, 'Customize workout');
    await tester.ensureVisible(option);
    await tester.tap(option);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Submit'));
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Feature request saved!'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    final request =
        jsonDecode(prefs.getStringList('feature_requests')!.single) as Map;
    expect(request['features'], ['Customize workout']);
    expect(request['details'], '');
    await tester.ensureVisible(find.text('Done'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.byType(FeatureSuggestionsSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Others requires details and cancel does not save', (
    tester,
  ) async {
    await open(tester);
    final others = find.widgetWithText(FilterChip, 'Others');
    await tester.ensureVisible(others);
    await tester.tap(others);
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Add stretching reminders');
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    await tester.ensureVisible(find.byTooltip('Close'));
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('feature_requests'), isNull);
    expect(tester.takeException(), isNull);
  });
}
