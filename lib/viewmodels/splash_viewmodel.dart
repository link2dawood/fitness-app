import 'package:flutter/foundation.dart';

import '../core/routes/app_routes.dart';
import '../data/repositories/onboarding_repository.dart';

class SplashViewModel extends ChangeNotifier {
  SplashViewModel(this._repository);

  final OnboardingRepository _repository;

  static const Duration _minimumDuration = Duration(milliseconds: 2600);

  /// Decides where the app should go after the splash animation.
  Future<String> resolveNextRoute() async {
    final completed = await _repository.isOnboardingCompleted();
    await Future<void>.delayed(_minimumDuration);
    return completed ? AppRoutes.home : AppRoutes.onboarding;
  }
}
