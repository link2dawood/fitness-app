import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_pro/app.dart';
import 'package:fitness_pro/core/settings/general_settings.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/views/startup/startup_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Fresh install starts through settings and reaches onboarding', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(GeneralSettings.channel, (_) async => null);
    await tester.pumpWidget(
      Provider<OnboardingRepository>(
        create: (_) => OnboardingRepository(),
        child: const StartupGate(child: FitnessApp()),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 8'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
