import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fitness_pro/app.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(
      Provider<OnboardingRepository>(
        create: (_) => OnboardingRepository(),
        child: const FitnessApp(),
      ),
    );
    expect(find.text('FitPulse'), findsNothing); // splash text fades in
  });
}