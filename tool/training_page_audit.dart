import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_pro/core/theme/app_theme.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/pages/training_page.dart';

void main() {
  setUpAll(() async {
    final text = FontLoader('Roboto')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File('C:/Windows/Fonts/arial.ttf').readAsBytesSync(),
          ),
        ),
      );
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
    await text.load();
    await icons.load();
  });
  for (final spec in [
    (390.0, 844.0, 1.0),
    (320.0, 640.0, 1.0),
    (390.0, 844.0, 2.0),
  ]) {
    testWidgets('Training audit ${spec.$1}x${spec.$2} scale ${spec.$3}', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = Size(spec.$1, spec.$2);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final errors = <String>[];
      final old = FlutterError.onError;
      FlutterError.onError = (details) {
        errors.add(
          '${details.exceptionAsString()}\n${details.context}\n${details.informationCollector?.call().join('\n')}',
        );
      };
      final vm = HomeViewModel(OnboardingRepository());
      await tester.runAsync(vm.load);
      final key = GlobalKey();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: RepaintBoundary(
            key: key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(spec.$3),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              home: const TrainingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final scroll = tester
          .widgetList<Scrollable>(find.byType(Scrollable))
          .firstWhere((s) => s.axisDirection == AxisDirection.down);
      final state = tester.state<ScrollableState>(find.byWidget(scroll));
      final max = state.position.maxScrollExtent;
      final prefix = '${spec.$1.toInt()}-${spec.$3.toInt()}';
      for (double offset = 0; offset <= max; offset += 420) {
        state.position.jumpTo(offset);
        await tester.pumpAndSettle();
        if (offset <= 1260) {
          await tester.runAsync(() async {
            final image =
                await (key.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage(pixelRatio: 1.5);
            final png = await image.toByteData(format: ui.ImageByteFormat.png);
            await File(
              'build/training-audit/$prefix-${offset.toInt()}.png',
            ).writeAsBytes(png!.buffer.asUint8List());
            image.dispose();
          });
        }
      }
      state.position.jumpTo(0);
      await tester.pumpAndSettle();
      if (spec.$3 == 1) {
        await tester.tap(
          find.byIcon(Icons.local_fire_department_rounded).first,
        );
        await tester.pumpAndSettle();
        expect(find.text('0 Day Streak!'), findsOneWidget);
        await tester.tap(find.text('KEEP GOING'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('${DateTime.now().day}').first);
        await tester.pumpAndSettle();
        expect(find.textContaining('History •'), findsOneWidget);
      }
      await tester.runAsync(() async {
        await File('build/training-audit/$prefix.json').writeAsString(
          jsonEncode({
            'width': spec.$1,
            'height': spec.$2,
            'textScale': spec.$3,
            'maxScrollExtent': max,
            'errors': errors,
          }),
        );
      });
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      FlutterError.onError = old;
      vm.dispose();
      expect(
        errors,
        isEmpty,
        reason: 'Training must fit this screen and text scale',
      );
      print('AUDIT $prefix: ${errors.length} captured layout/framework errors');
    });
  }
}
