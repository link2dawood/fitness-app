import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/repositories/onboarding_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  runApp(
    MultiProvider(
      providers: [
        Provider<OnboardingRepository>(create: (_) => OnboardingRepository()),
      ],
      child: const FitnessApp(),
    ),
  );
}
