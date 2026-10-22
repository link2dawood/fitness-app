import 'dart:io';
import 'dart:ui' as ui;
import 'package:fitness_pro/core/theme/app_theme.dart';
import 'package:fitness_pro/data/models/discover_catalog.dart';
import 'package:fitness_pro/views/home/pages/discover_page.dart';
import 'package:fitness_pro/views/home/pages/training_collection_page.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget app({double scale = 1, bool rtl = false}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light.copyWith(
    textTheme: AppTheme.light.textTheme.apply(fontFamily: 'DiscoverAudit'),
  ),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(disableAnimations: true, textScaler: TextScaler.linear(scale)),
    child: Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: child!,
    ),
  ),
  home: const DiscoverPage(),
);

bool focusedOn(Key key) {
  var found = false;
  FocusManager.instance.primaryFocus?.context?.visitAncestorElements((element) {
    if (element.widget.key == key) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
}

Future<void> focusCard(WidgetTester tester, Key key) async {
  for (var i = 0; i < 70 && !focusedOn(key); i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
  }
  expect(focusedOn(key), isTrue);
}

void main() {
  setUpAll(() async {
    if (!File('C:/Windows/Fonts/arial.ttf').existsSync()) return;
    final loader = FontLoader('DiscoverAudit')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File('C:/Windows/Fonts/arial.ttf').readAsBytesSync(),
          ),
        ),
      );
    await loader.load();
    if (const bool.fromEnvironment('EXPORT_DISCOVER_PREVIEWS')) {
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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  for (final config in [
    (320.0, 640.0, 1.0, false),
    (390.0, 844.0, 1.0, false),
    (320.0, 640.0, 2.0, false),
    (320.0, 640.0, 3.0, false),
    (390.0, 844.0, 2.0, false),
    (844.0, 390.0, 2.0, false),
    (768.0, 1024.0, 2.0, false),
    (320.0, 640.0, 2.0, true),
  ]) {
    testWidgets('Discover all carousel positions fit $config', (tester) async {
      tester.view.physicalSize = Size(config.$1, config.$2);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: app(scale: config.$3, rtl: config.$4),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // All carousel children are built; visit every horizontal position and
      // the complete vertical page rather than checking only the first pair.
      for (final scroll
          in tester
              .stateList<ScrollableState>(find.byType(Scrollable))
              .toList()) {
        for (
          var offset = 0.0;
          offset < scroll.position.maxScrollExtent;
          offset += 160
        ) {
          scroll.position.jumpTo(offset);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        scroll.position.jumpTo(scroll.position.maxScrollExtent);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      if (const bool.fromEnvironment('EXPORT_DISCOVER_PREVIEWS') &&
          ((config.$1 == 320 && config.$3 == 2) ||
              (config.$1 == 390 && config.$3 == 1)) &&
          !config.$4) {
        await tester.runAsync(() async {
          final context = tester.element(find.byType(DiscoverPage));
          final paths = {
            ...DiscoverCatalog.workoutCards.map((c) => c.image),
            'assets/images/workouts/stretch_warmup.jpg',
            'assets/images/workouts/massive_body.jpg',
          };
          for (final path in paths) {
            await precacheImage(AssetImage(path), context);
          }
        });
        for (final scroll in tester.stateList<ScrollableState>(
          find.byType(Scrollable),
        )) {
          scroll.position.jumpTo(0);
        }
        final vertical = tester
            .stateList<ScrollableState>(find.byType(Scrollable))
            .first;
        vertical.position.jumpTo(0);
        await tester.pumpAndSettle();
        await export(
          tester,
          boundary,
          config.$3 == 2 ? 'top-large' : 'top-normal',
        );
        vertical.position.jumpTo(vertical.position.maxScrollExtent);
        await tester.pumpAndSettle();
        await export(
          tester,
          boundary,
          config.$3 == 2 ? 'body-large' : 'body-normal',
        );
      }
    });
  }
  testWidgets('All 51 cards expose one named button with a 48px target', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      final cards = tester
          .widgetList(
            find.byWidgetPredicate(
              (w) =>
                  w.key is ValueKey<String> &&
                  (w.key as ValueKey<String>).value.startsWith('discover-'),
            ),
          )
          .toList();
      expect(cards, hasLength(51));
      for (final card in cards) {
        final finder = find.byWidget(card);
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        final node = tester.getSemantics(finder),
            data = tester.getSemantics(finder).getSemanticsData();
        expect(data.flagsCollection.isButton, isTrue, reason: '${card.key}');
        expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
        expect(data.label, startsWith('Open '));
        expect(
          node.childrenCount,
          0,
          reason: 'Avoid duplicate image/text/button announcements',
        );
        final size = tester.getSize(finder);
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
      for (final label in ['Search workouts', 'Workout history']) {
        final action = find.byTooltip(label);
        final size = tester.getSize(action);
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
    } finally {
      handle.dispose();
    }
  });
  testWidgets(
    'Screen-reader activation opens the named workout and collection',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(app());
        await tester.pumpAndSettle();
        final hero = find.byKey(const ValueKey('discover-hero'));
        tester.semantics.tap(
          find.semantics.byLabel(tester.getSemantics(hero).label).first,
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TrainingWorkoutPage>(find.byType(TrainingWorkoutPage))
              .workout
              .id,
          DiscoverCatalog.heroWorkoutId,
        );
        await tester.pageBack();
        await tester.pumpAndSettle();
        final equipment = find.byKey(
          const ValueKey('discover-collection-with_equipment'),
        );
        await tester.ensureVisible(equipment);
        await tester.pumpAndSettle();
        tester.semantics.tap(
          find.semantics.byLabel(tester.getSemantics(equipment).label),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TrainingCollectionPage>(
                find.byType(TrainingCollectionPage),
              )
              .title,
          'With Equipment',
        );
      } finally {
        handle.dispose();
      }
    },
  );
  testWidgets('Tab focus and Enter and Space activate a card', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    const hero = ValueKey('discover-hero');
    await focusCard(tester, hero);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(TrainingWorkoutPage), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await focusCard(tester, hero);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(find.byType(TrainingWorkoutPage), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await focusCard(
      tester,
      const ValueKey('discover-collection-with_equipment'),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TrainingCollectionPage>(find.byType(TrainingCollectionPage))
          .title,
      'With Equipment',
    );
  });
}

Future<void> export(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    final image =
        await (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
            .toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory('build/discover-previews').create(recursive: true);
    await File(
      'build/discover-previews/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
