import 'package:flutter/foundation.dart';

import '../data/models/user_profile.dart';
import '../data/repositories/training_history_repository.dart';
import '../data/repositories/onboarding_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._repository) {
    TrainingHistoryRepository.instance.addListener(_historyChanged);
  }
  String? historyError;
  void _historyChanged() => notifyListeners();
  @override
  void dispose() {
    TrainingHistoryRepository.instance.removeListener(_historyChanged);
    super.dispose();
  }

  final OnboardingRepository _repository;

  UserProfile? _profile;
  bool _isLoading = true;
  int _currentTab = 0;
  String _selectedBodyFocus = 'Abs';
  String _selectedPopularGoal = 'Burn Fat';
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
    try {
      await TrainingHistoryRepository.instance.load();
      historyError = null;
    } catch (_) {
      historyError =
          'Could not load training history. Retry before starting a session.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateWeight(int weightKg) async {
    final current = _profile ?? const UserProfile();
    _profile = current.copyWith(weightKg: weightKg);
    await _repository.saveProfile(_profile!);
    notifyListeners();
  }

  Future<void> updateHeight(int heightCm) async {
    final current = _profile ?? const UserProfile();
    _profile = current.copyWith(heightCm: heightCm);
    await _repository.saveProfile(_profile!);
    notifyListeners();
  }

  Future<void> updateTrainingPreferences(int days, String firstDay) async {
    final saved = await _repository.saveTrainingPreferences(days, firstDay);
    _profile = saved;
    notifyListeners();
  }

  /// Handy during development to replay the onboarding flow.
  Future<void> resetOnboarding() => _repository.clear();
}
