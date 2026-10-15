import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Backup explains that cloud synchronization is unavailable', (tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => HomeViewModel(OnboardingRepository()),
      child: const MaterialApp(home: SettingsPage()),
    ));
    await tester.tap(find.text('Backup & Restore'));
    await tester.pumpAndSettle();
    expect(find.text('Cloud backup is not available yet. Your profile is stored only on this device.'), findsOneWidget);
    expect(find.text('Continue with Google'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Built-in music assets are bundled at playback paths', (tester) async {
    for (final name in ['Dancing_All_Night', 'Cant_Stop', 'Holiday_Wishes']) {
      final bytes = await rootBundle.load('assets/audio/$name.wav');
      expect(bytes.lengthInBytes, greaterThan(0));
    }
  });
}
