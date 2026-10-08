import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/user_profile.dart';
import '../../data/repositories/onboarding_repository.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/onboarding_viewmodel.dart';
import '../../viewmodels/splash_viewmodel.dart';
import '../../views/home/home_view.dart';
import '../../views/home/pages/build_muscle_more_page.dart';
import '../../views/home/pages/burn_fat_more_page.dart';
import '../../views/home/pages/just_for_you_page.dart';
import '../../views/home/pages/keep_fit_more_page.dart';
import '../../views/home/pages/stretch_warm_up_page.dart';
import '../../views/onboarding/onboarding_view.dart';
import '../../views/plan/plan_generation_view.dart';
import '../../views/plan/plan_ready_view.dart';
import '../../views/pro/pro_plan_view.dart';
import '../../views/search/search_view.dart';
import '../../views/splash/splash_view.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String planGeneration = '/plan-generation';
  static const String planReady = '/plan-ready';
  static const String home = '/home';
  static const String pro = '/pro';
  static const String search = '/search';
  static const String stretchWarmUp = '/stretch-warm-up';
  static const String justForYou = '/just-for-you';
  static const String buildMuscleMore = '/build-muscle-more';
  static const String burnFatMore = '/burn-fat-more';
  static const String keepFitMore = '/keep-fit-more';

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
      case planGeneration:
        final profile = settings.arguments as UserProfile?;
        return _fade(
          settings,
          PlanGenerationView(profile: profile),
        );
      case planReady:
        final profile = settings.arguments as UserProfile?;
        return _fade(
          settings,
          PlanReadyView(profile: profile),
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
      case pro:
        return _fade(settings, const ProPlanView());
      case search:
        return _fade(settings, const SearchView());
      case stretchWarmUp:
        return _fade(settings, const StretchWarmUpPage());
      case justForYou:
        return _fade(settings, const JustForYouPage());
      case buildMuscleMore:
        return _fade(settings, const BuildMuscleMorePage());
      case burnFatMore:
        return _fade(settings, const BurnFatMorePage());
      case keepFitMore:
        return _fade(settings, const KeepFitMorePage());
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
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}
