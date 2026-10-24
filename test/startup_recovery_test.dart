import 'dart:async';
import 'dart:convert';
import 'package:fitness_pro/app.dart';
import 'package:fitness_pro/core/settings/general_settings.dart';
import 'package:fitness_pro/core/routes/app_routes.dart';
import 'package:fitness_pro/data/models/user_profile.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/viewmodels/splash_viewmodel.dart';
import 'package:fitness_pro/views/home/home_view.dart';
import 'package:fitness_pro/views/startup/startup_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class DelayedProfileRepository extends OnboardingRepository {
  final pending = Completer<UserProfile?>();
  int calls = 0;
  @override
  Future<UserProfile?> loadProfile() {
    calls++;
    return pending.future;
  }
}

class ResetFailStore extends InMemorySharedPreferencesStore {
  ResetFailStore(super.data) : super.withData();
  bool fail = true;
  @override
  Future<bool> remove(String key) async => fail ? false : super.remove(key);
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      GeneralSettings.channel,
      (_) async => null,
    );
  });
  tearDown(() => SharedPreferences.setMockInitialValues({}));

  Widget app() => Provider(
    create: (_) => OnboardingRepository(),
    child: const StartupGate(child: FitnessApp()),
  );

  Future<void> confirm(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, label));
    await tester.pumpAndSettle();
  }

  test(
    'malformed profile finishes loading with an error and retry does not replace data',
    () async {
      SharedPreferences.setMockInitialValues({
        'user_profile': 'broken',
        'onboarding_completed': true,
      });
      final model = HomeViewModel(OnboardingRepository());
      addTearDown(model.dispose);
      await model.load();
      expect(model.isLoading, isFalse);
      expect(model.profileError, isNotNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_profile'), 'broken');
      await prefs.setString(
        'user_profile',
        jsonEncode(const UserProfile(weightKg: 72.6).toJson()),
      );
      await model.load();
      expect(model.isLoading, isFalse);
      expect(model.profileError, isNull);
      expect(model.profile!.weightKg, 72.6);
    },
  );

  for (final fixture in <Map<String, Object>>[
    {'user_profile': '[]', 'onboarding_completed': true},
    {'user_profile': '{"heightCm":"bad"}', 'onboarding_completed': true},
    {'onboarding_completed': true},
    {'onboarding_completed': 'wrong-type'},
  ]) {
    test(
      'splash detects unreadable or missing completed profile: $fixture',
      () async {
        SharedPreferences.setMockInitialValues(fixture);
        final model = SplashViewModel(OnboardingRepository());
        addTearDown(model.dispose);
        await expectLater(model.resolveNextRoute(), throwsA(anything));
        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.get('onboarding_completed'),
          fixture['onboarding_completed'],
        );
      },
    );
  }

  testWidgets(
    'main startup renders UI before storage completes and retry recovers',
    (tester) async {
      var calls = 0;
      final pending = Completer<void>();
      await tester.pumpWidget(
        StartupGate(
          loadSettings: () {
            calls++;
            return calls == 1 ? pending.future : Future.value();
          },
          child: const MaterialApp(home: Text('Ready app')),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.completeError(StateError('Storage unavailable'));
      await tester.pumpAndSettle();
      expect(find.text('Could not load app settings'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(find.text('Ready app'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('hung settings load times out into retryable UI', (tester) async {
    final pending = Completer<void>();
    await tester.pumpWidget(
      StartupGate(
        loadSettings: () => pending.future,
        child: const MaterialApp(home: Text('Ready app')),
      ),
    );
    await tester.pump(const Duration(seconds: 11));
    await tester.pumpAndSettle();
    expect(find.text('Could not load app settings'), findsOneWidget);
    pending.complete();
    await tester.pump();
    expect(find.text('Ready app'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'corrupt general settings are preserved until confirmed reset; user records survive',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'general_weight_imperial': 'invalid',
        'user_profile': 'original-profile',
        'training_completions_v1': 'workouts',
        'weight_history_v1': 'weights',
        'workout_reminders': <String>['reminder'],
      });
      await tester.pumpWidget(
        const StartupGate(child: MaterialApp(home: Text('Ready app'))),
      );
      await tester.pumpAndSettle();
      final prefs = await SharedPreferences.getInstance();
      expect(find.text('Could not load app settings'), findsOneWidget);
      expect(prefs.get('general_weight_imperial'), 'invalid');
      await tester.tap(find.text('Reset app settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(prefs.get('general_weight_imperial'), 'invalid');
      await confirm(tester, 'Reset app settings');
      expect(find.text('Ready app'), findsOneWidget);
      expect(prefs.containsKey('general_weight_imperial'), isFalse);
      expect(prefs.getString('user_profile'), 'original-profile');
      expect(prefs.getString('training_completions_v1'), 'workouts');
      expect(prefs.getString('weight_history_v1'), 'weights');
      expect(prefs.getStringList('workout_reminders'), ['reminder']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'cold-start corrupt profile shows retry and recovers after storage is repaired',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'user_profile': 'broken',
        'onboarding_completed': true,
      });
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.text('Could not open your profile'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_profile'), 'broken');
      await prefs.setString(
        'user_profile',
        jsonEncode(const UserProfile().toJson()),
      );
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('HOME WORKOUT'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'confirmed profile reset reaches onboarding and preserves all history',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'user_profile': 'broken',
        'onboarding_completed': true,
        'training_completions_v1': 'keep-workouts',
        'weight_history_v1': 'keep-weights',
      });
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_profile'), 'broken');
      await confirm(tester, 'Reset profile');
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Step 1 of 8'), findsOneWidget);
      expect(prefs.containsKey('user_profile'), isFalse);
      expect(prefs.getBool('onboarding_completed'), isNull);
      expect(prefs.getString('training_completions_v1'), 'keep-workouts');
      expect(prefs.getString('weight_history_v1'), 'keep-weights');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'direct Home route catches profile failure instead of mounting broken tabs',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'user_profile': 'broken',
        'onboarding_completed': true,
      });
      await tester.pumpWidget(
        Provider(
          create: (_) => OnboardingRepository(),
          child: MaterialApp(
            initialRoute: AppRoutes.home,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Could not load your profile'), findsOneWidget);
      expect(find.byType(HomeView), findsOneWidget);
      expect(find.text('HOME WORKOUT'), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'user_profile',
        jsonEncode(const UserProfile().toJson()),
      );
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('HOME WORKOUT'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'hung profile load times out; duplicate loads and disposal are safe',
    (tester) async {
      final repo = DelayedProfileRepository();
      final model = HomeViewModel(repo);
      final loading = model.load();
      await model.load();
      expect(repo.calls, 1);
      await tester.pump(const Duration(seconds: 11));
      await loading;
      expect(model.isLoading, isFalse);
      expect(model.profileError, isNotNull);
      model.dispose();
      repo.pending.complete(const UserProfile());
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('late profile result after Home model disposal does not notify', (
    tester,
  ) async {
    final repo = DelayedProfileRepository();
    final model = HomeViewModel(repo);
    final loading = model.load();
    model.dispose();
    repo.pending.complete(const UserProfile());
    await tester.pump();
    await loading;
    expect(tester.takeException(), isNull);
  });

  testWidgets('reset storage failure remains retryable and does not navigate', (
    tester,
  ) async {
    final store = ResetFailStore({
      'flutter.general_weight_imperial': 'bad',
      'flutter.user_profile': 'keep',
    });
    SharedPreferencesStorePlatform.instance = store;
    await tester.pumpWidget(
      const StartupGate(child: MaterialApp(home: Text('Ready app'))),
    );
    await tester.pumpAndSettle();
    await confirm(tester, 'Reset app settings');
    expect(
      find.text('Could not complete recovery. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Ready app'), findsNothing);
    expect((await store.getAll())['flutter.user_profile'], 'keep');
    store.fail = false;
    await confirm(tester, 'Reset app settings');
    expect(find.text('Ready app'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
