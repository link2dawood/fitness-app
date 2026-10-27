import 'package:fitness_pro/views/plan/plan_generation_view.dart';
import 'dart:ui' as ui;
import 'package:fitness_pro/views/onboarding/widgets/ruler_picker.dart';
import 'dart:io';
import 'package:fitness_pro/core/theme/app_theme.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/data/models/user_profile.dart';
import 'package:fitness_pro/viewmodels/onboarding_viewmodel.dart';
import 'package:fitness_pro/views/onboarding/onboarding_view.dart';
import 'package:fitness_pro/views/plan/plan_ready_view.dart';
import 'package:fitness_pro/views/pro/pro_plan_view.dart';
import 'package:fitness_pro/views/settings/workout_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final file = File('C:/Windows/Fonts/arial.ttf');
    if (file.existsSync()) {
      await (FontLoader('AppLayout')..addFont(
            Future.value(ByteData.sublistView(file.readAsBytesSync())),
          ))
          .load();
    }
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({});
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
          final id = (call.arguments as Map)['playerId'];
          messenger.setMockStreamHandler(
            EventChannel('xyz.luan/audioplayers/events/$id'),
            MockStreamHandler.inline(onListen: (_, sink) {}),
          );
        }
        return call.method == 'getDuration' ||
                call.method == 'getCurrentPosition'
            ? 0
            : null;
      },
    );
  });
  Widget app(Widget child, double scale) => MaterialApp(
    theme: AppTheme.light.copyWith(
      textTheme: AppTheme.light.textTheme.apply(fontFamily: 'AppLayout'),
    ),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: child,
  );
  OnboardingViewModel model() => OnboardingViewModel(OnboardingRepository());
  for (final config in [
    (390.0, 844.0, 1.0),
    (320.0, 640.0, 2.0),
    (844.0, 390.0, 1.0),
    (768.0, 1024.0, 1.0),
  ]) {
    testWidgets('All onboarding steps and Plan Ready fit $config', (
      tester,
    ) async {
      tester.view.physicalSize = Size(config.$1, config.$2);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final vm = model();
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: app(const OnboardingView(), config.$3),
        ),
      );
      for (var index = 0; index < OnboardingStep.values.length; index++) {
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${vm.currentStep} at $config',
        );
        expect(
          find.text(index == 7 ? 'Save preferences' : 'NEXT').hitTestable(),
          findsOneWidget,
        );
        if (index < 7) await vm.skip();
      }
      await tester.pumpWidget(app(const PlanGenerationView(), config.$3));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      for (var stage = 0; stage < 4; stage++) {
        await tester.pump(const Duration(milliseconds: 900));
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Preference review stage $stage at $config',
        );
        if (stage < 3) {
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pump();
        }
      }
      await tester.pumpWidget(
        app(
          const PlanReadyView(
            profile: UserProfile(
              level: FitnessLevel.beginner,
              goal: FitnessGoal.buildMuscle,
              focusAreas: {FocusArea.arms, FocusArea.chest},
            ),
          ),
          config.$3,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Plan Ready at $config');
      await tester.ensureVisible(find.text('Go to homepage'));
      await tester.pumpAndSettle();
      expect(find.text('Go to homepage').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
    testWidgets(
      'Pro content fits and legal controls are reachable at $config',
      (tester) async {
        tester.view.physicalSize = Size(config.$1, config.$2);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(app(const ProPlanView(), config.$3));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Privacy Policy'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('COMING SOON').hitTestable(), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      },
    );
    for (final title in [
      'Music',
      'Rest timer',
      'Prep timer',
      'Sound options',
    ]) {
      testWidgets('$title sheet fits and Done is reachable at $config', (
        tester,
      ) async {
        tester.view.physicalSize = Size(config.$1, config.$2);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(app(const WorkoutSettingsView(), config.$3));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(title));
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Done'));
        await tester.pumpAndSettle();
        expect(find.text('Done').hitTestable(), findsOneWidget);
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
  testWidgets(
    'Gender cards expose selected button state and keyboard activation',
    (tester) async {
      final handle = tester.ensureSemantics();
      final vm = model();
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: app(const OnboardingView(), 1),
        ),
      );
      await tester.pumpAndSettle();
      final male = find.bySemanticsLabel('Male');
      expect(tester.getSemantics(male).flagsCollection.isButton, true);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(vm.profile.gender, Gender.male);
      expect(
        tester.getSemantics(male).flagsCollection.isSelected ==
            ui.Tristate.isTrue,
        true,
      );
      handle.dispose();
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'Prep Done is a named focusable button and supports keyboard submission',
    (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(app(const WorkoutSettingsView(), 1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Prep timer'));
      await tester.pumpAndSettle();
      final done = find.bySemanticsLabel('Done');
      expect(tester.getSemantics(done).flagsCollection.isButton, true);
      expect(
        tester.getSemantics(done).flagsCollection.isFocused != ui.Tristate.none,
        true,
      );
      for (
        var i = 0;
        i < 30 &&
            tester.getSemantics(done).flagsCollection.isFocused !=
                ui.Tristate.isTrue;
        i++
      ) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }
      expect(
        tester.getSemantics(done).flagsCollection.isFocused ==
            ui.Tristate.isTrue,
        true,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsNothing);
      expect(tester.takeException(), isNull);
      handle.dispose();
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'Measurement ruler supports named adjust actions, keyboard and bounds',
    (tester) async {
      final handle = tester.ensureSemantics();
      var value = 180;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, update) => Scaffold(
              body: RulerPicker(
                semanticLabel: 'Height in centimeters',
                value: value,
                min: 180,
                max: 182,
                onChanged: (next) => update(() => value = next),
              ),
            ),
          ),
          1,
        ),
      );
      await tester.pumpAndSettle();
      final ruler = find.bySemanticsLabel('Height in centimeters');
      expect(
        tester
            .getSemantics(ruler)
            .getSemanticsData()
            .hasAction(SemanticsAction.decrease),
        false,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(value, 181);
      tester.binding.performSemanticsAction(
        ui.SemanticsActionEvent(
          type: ui.SemanticsAction.increase,
          viewId: tester.view.viewId,
          nodeId: tester.getSemantics(ruler).id,
        ),
      );
      await tester.pumpAndSettle();
      expect(value, 182);
      expect(
        tester
            .getSemantics(ruler)
            .getSemanticsData()
            .hasAction(SemanticsAction.increase),
        false,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(value, 182);
      handle.dispose();
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('Pro plan cards expose selection and close has a name', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(app(const ProPlanView(), 1));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Close Pro plans'), findsOneWidget);
    await tester.ensureVisible(find.text('Monthly'));
    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    final monthly = tester.getSemantics(
      find.bySemanticsLabel(RegExp('Monthly')),
    );
    expect(monthly.flagsCollection.isButton, true);
    expect(monthly.flagsCollection.isSelected, ui.Tristate.isTrue);
    handle.dispose();
    await tester.pumpWidget(const SizedBox());
  });
}
