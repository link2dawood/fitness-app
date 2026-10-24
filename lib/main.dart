import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/repositories/onboarding_repository.dart';
import 'views/startup/startup_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  runApp(
    MultiProvider(
      providers: [
        Provider<OnboardingRepository>(create: (_) => OnboardingRepository()),
      ],
      child: const StartupGate(child: FitnessApp()),
    ),
  );
}
