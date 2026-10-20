import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:fitness_pro/core/theme/app_theme.dart';
import 'package:fitness_pro/data/models/challenge_day.dart';
import 'package:fitness_pro/data/models/exercise.dart';
import 'package:fitness_pro/data/repositories/challenge_day_repository.dart';
import 'package:fitness_pro/data/repositories/training_history_repository.dart';
import 'package:fitness_pro/viewmodels/challenge_session_controller.dart';
import 'package:fitness_pro/views/workouts/challenge_day_page.dart';
import 'package:fitness_pro/views/workouts/challenge_plan_editor.dart';
import 'package:fitness_pro/views/workouts/challenge_session_page.dart';
import 'package:fitness_pro/widgets/exercises/challenge_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget app(Widget child, {double scale = 1}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: const bool.fromEnvironment('EXPORT_CHALLENGE_PREVIEWS')
      ? AppTheme.light.copyWith(
          textButtonTheme: TextButtonThemeData(
            style: AppTheme.light.textButtonTheme.style!.copyWith(
              textStyle: const WidgetStatePropertyAll(
                TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600),
              ),
            ),
          ),
        )
      : AppTheme.light,
  builder: (context, widget) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(disableAnimations: true, textScaler: TextScaler.linear(scale)),
    child: widget!,
  ),
  home: child,
);
Future<void> flush(WidgetTester tester) async {
  await tester.runAsync(() async {
    await Future<void>.delayed(Duration.zero);
  });
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    if (const bool.fromEnvironment('EXPORT_CHALLENGE_PREVIEWS')) {
      for (final name in ['Roboto', 'Ahem']) {
        final font = FontLoader(name)
          ..addFont(
            Future.value(
              ByteData.sublistView(
                File('C:/Windows/Fonts/arial.ttf').readAsBytesSync(),
              ),
            ),
          );
        await font.load();
      }
      final icons = FontLoader('MaterialIcons')
        ..addFont(
          Future.value(
            ByteData.sublistView(
              File(
                'C:/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
              ).readAsBytesSync(),
            ),
          ),
        );
      await icons.load();
    }
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TrainingHistoryRepository.instance.load();
  });
  test(
    'Reference Day 1 has 21 timed entries, intentional repeats and avatar coverage',
    () {
      final day = ChallengeDay.initial();
      expect(day.entries, hasLength(21));
      expect(day.entries.map((e) => e.id).toSet(), hasLength(21));
      expect(
        day.entries.every(
          (e) =>
              e.seconds == 30 &&
              e.exercise.timed &&
              challengeAvatarFrames.containsKey(e.exerciseId),
        ),
        isTrue,
      );
      expect(day.entries.take(9).map((e) => e.exercise.name).toList(), [
        'Jumping Jacks',
        'Oblique Crossover Crunch Left',
        'Oblique Crossover Crunch Right',
        'Inchworms',
        'Single Leg Drops',
        'Body Saw',
        'Bicycle Crunches',
        'Side Crunches Left',
        'Side Crunches Right',
      ]);
      expect(day.entries.last.exercise.name, 'Lying Twist Stretch Right');
      expect(day.estimatedMinutes(30, 15), 21);
      for (var i = 1; i <= 5; i++) {
        expect(
          File('assets/images/challenge_avatars/atlas_$i.png').existsSync(),
          isTrue,
        );
      }
    },
  );
  test(
    'Controller automatically advances prep, exercise, rest and honors pause and rest editing',
    () {
      final c = ChallengeSessionController(
        day: ChallengeDay.initial(),
        prepSeconds: 15,
        restSeconds: 30,
        sessionId: 'timer',
      );
      c.tick(const Duration(seconds: 15));
      expect(c.phase, ChallengePhase.exercise);
      expect(c.remainingSeconds, 30);
      c.tick(const Duration(seconds: 30));
      expect(c.phase, ChallengePhase.rest);
      expect(c.displayIndex, 1);
      c.addRest();
      expect(c.remainingSeconds, 50);
      c.pause();
      c.tick(const Duration(minutes: 10));
      expect(c.remainingSeconds, 50);
      c.setRest(10);
      c.pause(false);
      c.tick(const Duration(seconds: 10));
      expect(c.phase, ChallengePhase.exercise);
      expect(c.index, 1);
      c.previous();
      expect(c.index, 0);
      expect(c.remainingSeconds, 30);
      c.dispose();
    },
  );
  test(
    'Continue restores exact phase/time while Restart preserves edits and resets progress',
    () {
      final c = ChallengeSessionController(
        day: ChallengeDay.initial(),
        prepSeconds: 0,
        restSeconds: 30,
        sessionId: 'same-session',
      );
      c.tick(const Duration(seconds: 37));
      final decoded = ChallengeDay.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(jsonEncode(c.snapshot().toJson())) as Map,
        ),
      );
      final resume = ChallengeSessionController(
        day: decoded,
        prepSeconds: 15,
        restSeconds: 30,
      );
      expect(resume.id, 'same-session');
      expect(resume.phase, ChallengePhase.rest);
      expect(resume.remainingSeconds, 23);
      expect(resume.paused, isTrue);
      resume.tick(const Duration(minutes: 3));
      expect(resume.remainingSeconds, 23);
      final restart = ChallengeSessionController(
        day: decoded,
        prepSeconds: 15,
        restSeconds: 30,
        restart: true,
        sessionId: 'new-session',
      );
      expect(restart.id, 'new-session');
      expect(restart.phase, ChallengePhase.prep);
      expect(restart.index, 0);
      expect(restart.progress, 0);
      c.dispose();
      resume.dispose();
      restart.dispose();
    },
  );
  test(
    'Automatic full sequence completes once, retains session identity and ignores extra ticks',
    () {
      final c = ChallengeSessionController(
        day: ChallengeDay.initial(),
        prepSeconds: 15,
        restSeconds: 30,
        sessionId: 'complete',
      );
      c.tick(const Duration(hours: 1));
      expect(c.phase, ChallengePhase.complete);
      expect(c.index, 20);
      expect(c.progress, 1);
      expect(c.activeMs, 1245000);
      c.tick(const Duration(hours: 1));
      expect(c.activeMs, 1245000);
      expect(c.finishedAt, isNotNull);
      c.dispose();
    },
  );
  test(
    'Edited/reordered plan and partial progress persist; corrupt data is not replaced',
    () async {
      final entries = referenceDayEntries();
      final first = entries.removeAt(0);
      entries.insert(2, first.copyWith(seconds: 35));
      final c = ChallengeSessionController(
        day: ChallengeDay(entries: entries),
        prepSeconds: 0,
        restSeconds: 30,
        sessionId: 'persist',
      );
      c.tick(const Duration(seconds: 4));
      await ChallengeDayRepository.instance.save(c.snapshot());
      final saved = await ChallengeDayRepository.instance.load();
      expect(saved.entries[2].id, first.id);
      expect(saved.entries[2].seconds, 35);
      expect(saved.progress!.remainingMs, 26000);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ChallengeDayRepository.storageKey, 'invalid');
      await expectLater(
        ChallengeDayRepository.instance.load(),
        throwsFormatException,
      );
      expect(prefs.getString(ChallengeDayRepository.storageKey), 'invalid');
      c.dispose();
    },
  );
  testWidgets(
    'Editor changes duration/reorders and Save returns draft; Cancel discards it',
    (tester) async {
      List<ChallengeEntry>? result;
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await Navigator.push<List<ChallengeEntry>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ChallengePlanEditor(entries: referenceDayEntries()),
                  ),
                );
              },
              child: const Text('Edit test'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Edit test'));
      await flush(tester);
      await tester.tap(find.byTooltip('Increase day1-0'));
      await tester.pump();
      tester
          .widget<ReorderableListView>(find.byType(ReorderableListView))
          .onReorderItem!(0, 2);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await flush(tester);
      expect(result![2].id, 'day1-0');
      expect(result![2].seconds, 35);
      await tester.tap(find.text('Edit test'));
      await flush(tester);
      await tester.tap(find.byTooltip('Increase day1-0'));
      await tester.tap(find.text('Cancel'));
      await flush(tester);
      expect(result, isNull);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Day details edit duration and session leave saves Continue progress',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: app(const ChallengeDayPage(enableMedia: false)),
        ),
      );
      await flush(tester);
      if (const bool.fromEnvironment('EXPORT_CHALLENGE_PREVIEWS')) {
        await tester.runAsync(() async {
          final context = boundary.currentContext!;
          for (var i = 1; i <= 5; i++) {
            await precacheImage(
              AssetImage('assets/images/challenge_avatars/atlas_$i.png'),
              context,
            );
          }
        });
        await tester.pumpAndSettle();
        await screenshot(tester, boundary, 'day1');
      }
      await tester.scrollUntilVisible(
        find.text('Jumping Jacks').first,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Jumping Jacks').first);
      await flush(tester);
      await tester.ensureVisible(find.byTooltip('Increase duration'));
      await tester.tap(find.byTooltip('Increase duration'));
      await tester.pump();
      await tester.tap(find.text('Close'));
      await flush(tester);
      expect(
        (await tester.runAsync(
          () => ChallengeDayRepository.instance.load(),
        ))!.entries.first.seconds,
        35,
      );
      await tester.tap(find.text('Start workout'));
      await flush(tester);
      expect(find.text('READY TO GO!'), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Skip preparation'));
      await tester.tap(find.byTooltip('Skip preparation'));
      await tester.pump();
      if (const bool.fromEnvironment('EXPORT_CHALLENGE_PREVIEWS')) {
        await screenshot(tester, boundary, 'exercise');
      }
      await tester.ensureVisible(find.byTooltip('Next exercise'));
      await tester.tap(find.byTooltip('Next exercise'));
      await tester.pump();
      expect(find.text('REST'), findsOneWidget);
      await tester.tap(find.text('+20s'));
      await tester.pump();
      if (const bool.fromEnvironment('EXPORT_CHALLENGE_PREVIEWS')) {
        await screenshot(tester, boundary, 'rest');
      }
      await tester.tap(find.text('Skip'));
      await tester.pump();
      await tester.tap(find.byTooltip('Save and leave challenge'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save and leave'));
      await flush(tester);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Restart'), findsOneWidget);
      final saved = await tester.runAsync(
        () => ChallengeDayRepository.instance.load(),
      );
      expect(saved!.progress!.index, 1);
      expect(saved.progress!.credited, isFalse);
      expect(TrainingHistoryRepository.instance.entries, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await flush(tester);
    },
  );
  testWidgets(
    'Replacement uses a single exercise choice and retains the entry identity',
    (tester) async {
      ExerciseDefinition? result;
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await replaceChallengeExercise(context);
              },
              child: const Text('Replace test'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Replace test'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Cat Cow');
      await tester.pumpAndSettle();
      expect(find.text('Cat Cow Pose'), findsOneWidget);
      await tester.tap(find.text('Cat Cow Pose'));
      await tester.pumpAndSettle();
      expect(find.text('Replace test'), findsOneWidget);
      expect(result!.id, 'cat_cow_pose');
      expect(
        referenceDayEntries().first.copyWith(exerciseId: result!.id).id,
        'day1-0',
      );
    },
  );
  testWidgets('Completion is recorded once and remains saved after reopening', (
    tester,
  ) async {
    final day = ChallengeDay(
      entries: [referenceDayEntries().first.copyWith(seconds: 5)],
    );
    await tester.pumpWidget(
      app(ChallengeSessionPage(day: day, prep: 0, rest: 0, enableMedia: false)),
    );
    await tester.tap(find.byTooltip('Next exercise'));
    await flush(tester);
    expect(find.text('DAY 1 COMPLETE'), findsOneWidget);
    expect(find.text('Workout saved to your history'), findsOneWidget);
    expect(TrainingHistoryRepository.instance.entries, hasLength(1));
    final saved = await tester.runAsync(
      () => ChallengeDayRepository.instance.load(),
    );
    expect(saved!.progress!.credited, isTrue);
    await tester.pumpWidget(const SizedBox());
    await flush(tester);
    await tester.pumpWidget(
      app(
        ChallengeSessionPage(day: saved, prep: 0, rest: 0, enableMedia: false),
      ),
    );
    await flush(tester);
    expect(TrainingHistoryRepository.instance.entries, hasLength(1));
    await tester.pumpWidget(const SizedBox());
    await flush(tester);
  });
  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'Reference challenge fits narrow screens at text scale $scale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          app(const ChallengeDayPage(enableMedia: false), scale: scale),
        );
        await flush(tester);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(
          app(
            ChallengePlanEditor(entries: referenceDayEntries()),
            scale: scale,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(
          app(
            Builder(
              builder: (context) => TextButton(
                onPressed: () => showChallengeExerciseDetails(
                  context,
                  referenceDayEntries(),
                  1,
                ),
                child: const Text('Details'),
              ),
            ),
            scale: scale,
          ),
        );
        await tester.tap(find.text('Details'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        await tester.pumpWidget(
          app(
            ChallengeSessionPage(
              day: ChallengeDay.initial(),
              prep: 15,
              rest: 30,
              enableMedia: false,
            ),
            scale: scale,
          ),
        );
        await flush(tester);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Skip preparation'));
        await tester.pump();
        await tester.tap(find.byTooltip('Next exercise'));
        await tester.pump();
        expect(find.text('Skip').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await flush(tester);
        await tester.pumpWidget(
          app(
            Scaffold(
              body: ChallengeAvatar(
                exercise: referenceDayEntries().first.exercise,
              ),
            ),
            scale: scale,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Future<void> screenshot(
  WidgetTester tester,
  GlobalKey boundary,
  String name,
) async {
  await tester.runAsync(() async {
    final image =
        await (boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory('build/challenge-previews').create(recursive: true);
    await File(
      'build/challenge-previews/$name.png',
    ).writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}
