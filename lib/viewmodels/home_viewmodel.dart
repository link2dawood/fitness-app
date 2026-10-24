import 'package:flutter/foundation.dart';

import '../data/models/user_profile.dart';
import '../data/repositories/training_history_repository.dart';
import '../data/repositories/onboarding_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._repository) {
    TrainingHistoryRepository.instance.addListener(_historyChanged);
  }
  String? historyError;
  String? profileError;
  bool _loadActive = false, _disposed = false;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _historyChanged() => _notify();
  @override
  void dispose() {
    _disposed = true;
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
      _notify();
    }
  }

  void setBodyFocus(String focus) {
    _selectedBodyFocus = focus;
    _notify();
  }

  void setPopularGoal(String goal) {
    _selectedPopularGoal = goal;
    _notify();
  }

  void selectDay(int day) {
    _selectedDay = day;
    _notify();
  }

  Future<void> load() async {
    if (_loadActive || _disposed) return;
    _loadActive = true;
    _isLoading = true;
    profileError = null;
    _notify();
    try {
      final profile = await _repository.loadProfile().timeout(
        const Duration(seconds: 10),
      );
      if (profile == null &&
          await _repository.isOnboardingCompleted().timeout(
            const Duration(seconds: 10),
          )) {
        throw const FormatException('Completed profile is missing');
      }
      if (_disposed) return;
      _profile = profile;
      try {
        await TrainingHistoryRepository.instance.load().timeout(
          const Duration(seconds: 10),
        );
        historyError = null;
      } catch (_) {
        historyError =
            'Could not load training history. Retry before starting a session.';
      }
    } catch (_) {
      profileError =
          'Could not load your saved profile. Your data has not been changed.';
    } finally {
      _loadActive = false;
      if (!_disposed) {
        _isLoading = false;
        _notify();
      }
    }
  }

  Future<void> updateWeight(num weightKg) async {
    final next = await _repository.saveMeasurements(weightKg: weightKg);
    _profile = next;
    _notify();
  }

  Future<void> updateHeight(int heightCm) async {
    final next = await _repository.saveMeasurements(heightCm: heightCm);
    _profile = next;
    _notify();
  }

  Future<void> updateTrainingPreferences(int days, String firstDay) async {
    final saved = await _repository.saveTrainingPreferences(days, firstDay);
    _profile = saved;
    _notify();
  }

  /// Handy during development to replay the onboarding flow.
  Future<void> resetOnboarding() => _repository.clear();
}
