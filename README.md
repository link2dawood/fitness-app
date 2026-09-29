# fitness_app: Splash + Onboarding (MVVM)

## Setup
1. Replace your project's `lib/` folder with the `lib/` folder from this archive.
2. Add the dependencies:
   flutter pub add provider shared_preferences
3. Delete or update `test/widget_test.dart` (it references the old `MyApp` counter).
4. flutter run

## Structure
lib/
  main.dart, app.dart
  core/       theme, constants, routes
  data/       models (UserProfile + enums), repositories (local storage)
  viewmodels/ splash, onboarding, home (ChangeNotifier)
  views/      splash, onboarding (7 steps + widgets), home
