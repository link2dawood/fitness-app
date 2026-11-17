import 'dart:io';

import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/views/home/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

void main() {
  Future<void> showSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => HomeViewModel(OnboardingRepository()),
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('settings-app-version')),
      300,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty package metadata displays an unavailable status', (
    tester,
  ) async {
    PackageInfo.setMockInitialValues(
      appName: 'fitness_pro',
      packageName: 'com.example.fitness_pro',
      version: '',
      buildNumber: '',
      buildSignature: '',
    );
    await showSettings(tester);
    expect(find.text('Version unavailable'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings displays the package version and build from pubspec', (
    tester,
  ) async {
    final declared = RegExp(
      r'^version:\s*([^\s#]+)',
      multiLine: true,
    ).firstMatch(File('pubspec.yaml').readAsStringSync())!.group(1)!.split('+');
    PackageInfo.setMockInitialValues(
      appName: 'fitness_pro',
      packageName: 'com.example.fitness_pro',
      version: declared.first,
      buildNumber: declared.length > 1 ? declared[1] : '',
      buildSignature: '',
    );
    await showSettings(tester);
    final buildLabel = declared.length > 1 ? ' (build ${declared[1]})' : '';
    expect(find.text('Version ${declared.first}$buildLabel'), findsOneWidget);
  });

  testWidgets('installed build metadata overrides the source package version', (
    tester,
  ) async {
    PackageInfo.setMockInitialValues(
      appName: 'fitness_pro',
      packageName: 'com.example.fitness_pro',
      version: '9.8.7',
      buildNumber: '432',
      buildSignature: '',
    );
    await showSettings(tester);
    expect(find.text('Version 9.8.7 (build 432)'), findsOneWidget);
  });

  testWidgets('a package without a build number displays its version', (
    tester,
  ) async {
    PackageInfo.setMockInitialValues(
      appName: 'fitness_pro',
      packageName: 'com.example.fitness_pro',
      version: '2.3.4',
      buildNumber: '',
      buildSignature: '',
    );
    await showSettings(tester);
    expect(find.text('Version 2.3.4'), findsOneWidget);
  });
}
