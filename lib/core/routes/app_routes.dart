import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/onboarding_repository.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/onboarding_viewmodel.dart';
import '../../viewmodels/splash_viewmodel.dart';
import '../../views/home/home_view.dart';
import '../../views/onboarding/onboarding_view.dart';
import '../../views/splash/splash_view.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return _fade(
          settings,
          ChangeNotifierProvider(
            create: (ctx) => OnboardingViewModel(ctx.read<OnboardingRepository>()),
            child: const OnboardingView(),
          ),
        );
      case home:
        return _fade(
          settings,
          ChangeNotifierProvider(
            create: (ctx) =>
                HomeViewModel(ctx.read<OnboardingRepository>())..load(),
            child: const HomeView(),
          ),
        );
      case splash:
      default:
        return _fade(
          settings,
          ChangeNotifierProvider(
            create: (ctx) => SplashViewModel(ctx.read<OnboardingRepository>()),
            child: const SplashView(),
          ),
        );
    }
  }

  static PageRouteBuilder<dynamic> _fade(RouteSettings settings, Widget page) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}
