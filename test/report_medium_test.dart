import 'dart:convert';
import 'dart:io';
import 'package:fitness_pro/core/settings/general_settings.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/data/repositories/weight_history_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/pages/report_page.dart';
import 'package:fitness_pro/views/home/widgets/bmi_scale_bar.dart';
import 'package:fitness_pro/views/workouts/training_history_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await WeightHistoryRepository.instance.load();
    final file = File('C:/Windows/Fonts/arial.ttf');
    if (file.existsSync()) {
      await (FontLoader('ReportAudit')..addFont(
            Future.value(ByteData.sublistView(file.readAsBytesSync())),
          ))
          .load();
    }
  });

  Future<void> open(
    WidgetTester tester, {
    double scale = 1,
    DateTime Function()? now,
  }) async {
    final today = now?.call() ?? DateTime.now();
    SharedPreferences.setMockInitialValues({
      'user_profile': jsonEncode({
        'weightKg': 80,
        'heightCm': 180,
        'firstDayOfWeek': 'MONDAY',
      }),
      WeightHistoryRepository.storageKey: jsonEncode([
        WeightRecord(date: today, kg: 80).toJson(),
      ]),
    });
    GeneralSettings.instance.weightImperial = false;
    GeneralSettings.instance.heightImperial = false;
    final model = HomeViewModel(OnboardingRepository());
    addTearDown(model.dispose);
    await tester.runAsync(model.load);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: model,
        child: MaterialApp(
          theme: ThemeData(fontFamily: 'ReportAudit'),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: ReportPage(now: now),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> reveal(WidgetTester tester, Finder target) async {
    await tester.scrollUntilVisible(
      target,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
  }

  testWidgets('shared units drive Report; picker units are temporary', (
    tester,
  ) async {
    await open(tester);
    await reveal(tester, find.byKey(const ValueKey('report-height-edit')));
    expect(find.text('180 cm'), findsOneWidget);
    await tester.runAsync(
      () => GeneralSettings.instance.setUnits(weight: true, height: true),
    );
    await tester.pumpAndSettle();
    expect(find.text('5 ft 11 in'), findsOneWidget);
    expect(find.text('176.4 lbs'), findsOneWidget);
    await reveal(tester, find.text('Log'));
    await tester.tap(find.text('Log'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'kg'));
    await tester.pumpAndSettle();
    expect(
      find.text('Picker units only. Report uses General Settings.'),
      findsOneWidget,
    );
    await reveal(tester, find.text('Save'));
    await tester.runAsync(() async {
      await tester.tap(find.text('Save'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    expect(GeneralSettings.instance.weightImperial, isTrue);
    expect(find.text('176.4 lbs'), findsOneWidget);
  });

  for (final config in [
    (390.0, 844.0, 1.0),
    (320.0, 640.0, 1.0),
    (320.0, 640.0, 2.0),
    (844.0, 390.0, 1.0),
    (844.0, 390.0, 2.0),
    (768.0, 1024.0, 1.0),
  ]) {
    testWidgets('cards, pickers and All records fit $config', (tester) async {
      tester.view.physicalSize = Size(config.$1, config.$2);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await open(tester, scale: config.$3);
      await reveal(tester, find.byKey(const ValueKey('report-height-edit')));
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('report-height-edit')));
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Save'));
      expect(
        tester
            .getRect(find.text('Save'))
            .overlaps(Offset.zero & Size(config.$1, config.$2)),
        isTrue,
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Log'));
      await tester.tap(find.text('Log'));
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Save'));
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await reveal(tester, find.text('All records'));
      await tester.tap(find.text('All records'));
      await tester.pumpAndSettle();
      await reveal(tester, find.text('No completed workouts on this day.'));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Report and open logger refresh across midnight and save under the new date',
    (tester) async {
      var now = DateTime(2026, 10, 31, 23, 59, 59);
      await open(tester, now: () => now);
      await reveal(tester, find.text('Log'));
      await tester.tap(find.text('Log'));
      await tester.pumpAndSettle();
      expect(find.text('Oct 31, 2026'), findsOneWidget);
      now = DateTime(2026, 11, 1, 0, 0, 1);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(find.text('Nov 1, 2026'), findsOneWidget);
      await reveal(tester, find.text('Save'));
      await tester.runAsync(() async {
        await tester.tap(find.text('Save'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
      expect(
        WeightHistoryRepository.instance.records.last.date,
        DateTime(2026, 11, 1),
      );
      expect(find.text('November'), findsOneWidget);
    },
  );

  testWidgets('retained history follows today across year rollover', (
    tester,
  ) async {
    var now = DateTime(2026, 12, 31, 23, 59, 59);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrainingHistorySheet(
            date: now,
            firstDay: 'MONDAY',
            now: () => now,
          ),
        ),
      ),
    );
    expect(find.text('2026/12'), findsOneWidget);
    now = DateTime(2027, 1, 1, 0, 0, 1);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('2027/01'), findsOneWidget);
    expect(find.text('History • 2027/1/1'), findsOneWidget);
  });

  testWidgets(
    'resume refreshes Report dates while retaining a selected historical day',
    (tester) async {
      var now = DateTime(2026, 10, 31, 12);
      await open(tester, now: () => now);
      now = DateTime(2026, 11, 2, 12);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('November'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == '2026-11-2',
        ),
        findsOneWidget,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrainingHistorySheet(
              date: DateTime(2026, 10, 10),
              firstDay: 'MONDAY',
              now: () => now,
            ),
          ),
        ),
      );
      now = DateTime(2027, 1, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('History • 2026/10/10'), findsOneWidget);
      expect(find.text('2026/10'), findsOneWidget);
    },
  );

  testWidgets('Log supports keyboard focus and Enter activation', (
    tester,
  ) async {
    await open(tester);
    bool focused = false;
    for (var i = 0; i < 15 && !focused; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.context?.visitAncestorElements((
        element,
      ) {
        if (element.widget.key == const ValueKey('report-action-Log')) {
          focused = true;
          return false;
        }
        return true;
      });
    }
    expect(focused, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(
      find.text('Picker units only. Report uses General Settings.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'actions have button roles, minimum targets, and chart descriptions',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await open(tester);
      for (final label in ['Log', 'All records']) {
        final button = find
            .ancestor(
              of: find.text(label),
              matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
            )
            .first;
        expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
        expect(tester.getSize(button).width, greaterThanOrEqualTo(48));
        expect(
          tester.getSemantics(button),
          matchesSemantics(
            isButton: true,
            hasTapAction: true,
            hasFocusAction: true,
            isFocusable: true,
            hasEnabledState: true,
            isEnabled: true,
            label: label,
          ),
        );
      }
      await reveal(tester, find.byKey(const ValueKey('report-height-edit')));
      expect(
        tester.getSize(find.byKey(const ValueKey('report-height-edit'))).height,
        greaterThanOrEqualTo(48),
      );
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label?.startsWith('Weight history.') ?? false),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label?.startsWith('BMI 24.7.') ?? false),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('report-height-edit')));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.selected == true,
        ),
        findsOneWidget,
      );
      semantics.dispose();
    },
  );

  for (final width in [252.0, 322.0, 700.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'BMI label centers share numeric mapping at width $width and scale $scale',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(fontFamily: 'ReportAudit'),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: Center(
                child: SizedBox(
                  width: width,
                  child: const BmiScaleBar(bmi: 25),
                ),
              ),
            ),
          );
          final bar = tester.getRect(
            find.byKey(const ValueKey('bmi-scale-track')),
          );
          final rects = <Rect>[];
          for (final value in BmiScaleGeometry.labels) {
            final rect = tester.getRect(
              find.byKey(ValueKey('bmi-label-$value')),
            );
            expect(
              rect.center.dx,
              closeTo(
                bar.left + BmiScaleGeometry.fraction(value) * bar.width,
                .01,
              ),
            );
            expect(rects.any(rect.overlaps), isFalse);
            rects.add(rect);
          }
          expect(BmiScaleGeometry.fraction(25), .4);
        },
      );
    }
  }
}
