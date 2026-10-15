import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/settings/general_settings.dart';
import 'data/repositories/onboarding_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  await GeneralSettings.instance.load();

  runApp(
    MultiProvider(
      providers: [
        Provider<OnboardingRepository>(create: (_) => OnboardingRepository()),
      ],
      child: const FitnessApp(),
    ),
  );
}
