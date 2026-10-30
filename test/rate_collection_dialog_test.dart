import 'package:fitness_pro/data/models/challenge_day.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/home_view.dart';
import 'package:fitness_pro/views/home/pages/settings_page.dart';
import 'package:fitness_pro/views/home/pages/training_page.dart';
import 'package:fitness_pro/views/workouts/challenge_session_page.dart';
import 'package:fitness_pro/widgets/rate_collection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget wrap(Widget child, {double textScale = 1.0}) {
    return MaterialApp(
      builder: (context, widget) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: true,
          textScaler: TextScaler.linear(textScale),
        ),
        child: widget!,
      ),
      home: child,
    );
  }

  testWidgets(
    'RateCollectionDialog renders all 5 reference rating states and persists submission',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showRateCollectionDialog(context),
                  child: const Text('Open Rate'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Rate'));
      await tester.pumpAndSettle();

      // Default 5-star state
      expect(find.byType(RateCollectionDialog), findsOneWidget);
      expect(find.text('We like you too!'), findsOneWidget);
      expect(find.text('Thanks for your feedback.'), findsOneWidget);
      expect(find.text('5 stars means a lot!'), findsOneWidget);
      expect(find.text('Rate On Google Play'), findsOneWidget);

      // Tap 4th star
      await tester.tap(find.byKey(const ValueKey<String>('rate-star-4')));
      await tester.pumpAndSettle();
      expect(find.text('We like you too!'), findsOneWidget);
      expect(
        find.text('Please share your feedback so we can\nimprove.'),
        findsOneWidget,
      );
      expect(find.text('Rate'), findsOneWidget);
      expect(find.text('Rate On Google Play'), findsNothing);

      // Tap 3rd star
      await tester.tap(find.byKey(const ValueKey<String>('rate-star-3')));
      await tester.pumpAndSettle();
      expect(find.text('Oh, no!'), findsOneWidget);
      expect(
        find.text('Please share your feedback so we can\nimprove.'),
        findsOneWidget,
      );
      expect(find.text('Rate'), findsOneWidget);

      // Tap 2nd star
      await tester.tap(find.byKey(const ValueKey<String>('rate-star-2')));
      await tester.pumpAndSettle();
      expect(find.text('Oh, no!'), findsOneWidget);
      expect(find.text('Rate'), findsOneWidget);

      // Tap 1st star
      await tester.tap(find.byKey(const ValueKey<String>('rate-star-1')));
      await tester.pumpAndSettle();
      expect(find.text('Oh, no!'), findsOneWidget);
      expect(find.text('Rate'), findsOneWidget);

      // Tap 5th star again and submit
      await tester.tap(find.byKey(const ValueKey<String>('rate-star-5')));
      await tester.pumpAndSettle();
      expect(find.text('Rate On Google Play'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('rate-submit-button')));
      await tester.pumpAndSettle();

      expect(find.byType(RateCollectionDialog), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(RateCollectionDialog.ratingValueKey), 5);
      expect(prefs.getBool(RateCollectionDialog.ratingPromptShownKey), isTrue);
    },
  );

  testWidgets('Settings Rate us tile opens RateCollectionDialog', (tester) async {
    final vm = HomeViewModel(OnboardingRepository());
    await tester.runAsync(vm.load);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
        child: wrap(const SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Rate us'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Rate us'));
    await tester.pumpAndSettle();

    expect(find.byType(RateCollectionDialog), findsOneWidget);
    expect(find.text('We like you too!'), findsOneWidget);
    expect(find.text('Rate On Google Play'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    vm.dispose();
  });

  testWidgets(
    'HomeView with showRateCardOnOpen displays RateCollectionDialog over TrainingPage',
    (tester) async {
      final vm = HomeViewModel(OnboardingRepository());
      await tester.runAsync(vm.load);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: wrap(const HomeView(showRateCardOnOpen: true)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TrainingPage), findsOneWidget);
      expect(find.byType(RateCollectionDialog), findsOneWidget);
      expect(find.text('We like you too!'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      vm.dispose();
    },
  );

  testWidgets(
    'Completing a workout session shows RateCollectionDialog',
    (tester) async {
      final day = ChallengeDay(
        entries: [referenceDayEntries().first.copyWith(seconds: 5)],
      );
      await tester.pumpWidget(
        wrap(
          ChallengeSessionPage(day: day, prep: 0, rest: 0, enableMedia: false),
        ),
      );
      await tester.tap(find.byTooltip('Next exercise'));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();

      expect(find.text('DAY 1 COMPLETE'), findsOneWidget);
      expect(find.byType(RateCollectionDialog), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'RateCollectionDialog fits narrow screens with 200% text scaling across all states',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrap(const Scaffold(body: RateCollectionDialog()), textScale: 2.0),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      for (var star = 1; star <= 5; star++) {
        await tester.ensureVisible(
          find.byKey(ValueKey<String>('rate-star-$star')),
        );
        await tester.tap(find.byKey(ValueKey<String>('rate-star-$star')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    },
  );
}

