import 'package:flutter/foundation.dart';

import '../data/models/user_profile.dart';
import '../data/repositories/onboarding_repository.dart';

enum OnboardingStep {
  gender,
  focusArea,
  goal,
  motivation,
  fitnessLevel,
  activityLevel,
  weeklyGoal,
  bodyMetrics,
}

class OnboardingViewModel extends ChangeNotifier {
  OnboardingViewModel(this._repository);

  final OnboardingRepository _repository;

  static const List<OnboardingStep> steps = OnboardingStep.values;

  int _index = 0;
  bool _isSaving = false;
  UserProfile _profile = const UserProfile();

  // ---------------------------------------------------------------- getters
  UserProfile get profile => _profile;
  OnboardingStep get currentStep => steps[_index];
  int get stepNumber => _index + 1;
  int get totalSteps => steps.length;
  double get progress => stepNumber / totalSteps;
  bool get isFirst => _index == 0;
  bool get isLast => _index == steps.length - 1;
  bool get isSaving => _isSaving;

  /// Steps with sliders / pickers always have a value, the rest need a choice.
  bool get canProceed {
    switch (currentStep) {
      case OnboardingStep.gender:
        return _profile.gender != null;
      case OnboardingStep.focusArea:
        return _profile.focusAreas.isNotEmpty;
      case OnboardingStep.goal:
        return _profile.goal != null;
      case OnboardingStep.motivation:
        return _profile.motivation != null;
      case OnboardingStep.fitnessLevel:
        return _profile.level != null;
      case OnboardingStep.activityLevel:
        return _profile.activityLevel != null;
      case OnboardingStep.weeklyGoal:
      case OnboardingStep.bodyMetrics:
        return true;
    }
  }

  // ---------------------------------------------------------------- setters
  void selectGender(Gender value) => _update(_profile.copyWith(gender: value));

  void toggleFocusArea(FocusArea area) {
    final areas = Set<FocusArea>.from(_profile.focusAreas);

    if (area == FocusArea.fullBody) {
      // "Full body" is exclusive.
      final wasSelected = areas.contains(area);
      areas.clear();
      if (!wasSelected) areas.add(area);
    } else {
      areas.remove(FocusArea.fullBody);
      if (!areas.remove(area)) areas.add(area);
    }
    _update(_profile.copyWith(focusAreas: areas));
  }

  void selectGoal(FitnessGoal value) => _update(_profile.copyWith(goal: value));

  void selectMotivation(Motivation value) =>
      _update(_profile.copyWith(motivation: value));

  void selectLevel(FitnessLevel value) =>
      _update(_profile.copyWith(level: value));

  void selectActivityLevel(ActivityLevel value) =>
      _update(_profile.copyWith(activityLevel: value));

  void updateAge(int value) => _update(_profile.copyWith(age: value));
  void updateHeight(int value) => _update(_profile.copyWith(heightCm: value));
  void updateWeight(int value) => _update(_profile.copyWith(weightKg: value));

  void selectWorkoutDays(int value) =>
      _update(_profile.copyWith(workoutDaysPerWeek: value));

  void selectFirstDayOfWeek(String value) =>
      _update(_profile.copyWith(firstDayOfWeek: value));

  // ------------------------------------------------------------- navigation
  void next() {
    if (!canProceed || isLast) return;
    _index++;
    notifyListeners();
  }

  void back() {
    if (isFirst) return;
    _index--;
    notifyListeners();
  }

  /// Skips the current step without requiring a selection.
  /// Returns true when the flow is finished.
  Future<bool> skip() async {
    if (isLast) return complete();
    _index++;
    notifyListeners();
    return false;
  }

  /// Saves the collected data. Returns true on success.
  Future<bool> complete() async {
    if (_isSaving) return false;
    _isSaving = true;
    notifyListeners();

    try {
      await _repository.saveProfile(_profile);
      return true;
    } catch (e) {
      debugPrint('Failed to save profile: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _update(UserProfile value) {
    _profile = value;
    notifyListeners();
  }
}
