import 'package:flutter/foundation.dart';

import '../data/models/user_profile.dart';
import '../data/repositories/onboarding_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._repository);

  final OnboardingRepository _repository;

  UserProfile? _profile;
  bool _isLoading = true;
  int _currentTab = 0;
  String _selectedBodyFocus = 'Abs';
  String _selectedPopularGoal = 'Build Muscle';
  int _selectedDay = 30;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  int get currentTab => _currentTab;
  String get selectedBodyFocus => _selectedBodyFocus;
  String get selectedPopularGoal => _selectedPopularGoal;
  int get selectedDay => _selectedDay;

  void setTab(int index) {
    if (_currentTab != index) {
      _currentTab = index;
      notifyListeners();
    }
  }

  void setBodyFocus(String focus) {
    _selectedBodyFocus = focus;
    notifyListeners();
  }

  void setPopularGoal(String goal) {
    _selectedPopularGoal = goal;
    notifyListeners();
  }

  void selectDay(int day) {
    _selectedDay = day;
    notifyListeners();
  }

  Future<void> load() async {
    _profile = await _repository.loadProfile();
    _isLoading = false;
    notifyListeners();
  }

  /// Handy during development to replay the onboarding flow.
  Future<void> resetOnboarding() => _repository.clear();
}
