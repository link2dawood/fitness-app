import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

/// Single source of truth for onboarding data.
/// Swap the internals for an API / Firebase / Supabase later without
/// touching any ViewModel or View.
class OnboardingRepository {
  static const _profileKey = 'user_profile';
  static const _completedKey = 'onboarding_completed';

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_completedKey) ?? false;
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(_profileKey, jsonEncode(profile.toJson()))) {
      throw StateError('Could not save profile');
    }
    if (!await prefs.setBool(_completedKey, true)) {
      throw StateError('Could not save onboarding completion');
    }
  }

  static Future<void> _measurementWrites = Future.value();

  /// Merge isolated measurements without changing onboarding completion status.
  Future<UserProfile> saveMeasurements({num? weightKg, int? heightCm}) {
    final pending = _measurementWrites.then((_) async {
      if (weightKg != null && (!weightKg.isFinite || weightKg <= 0) ||
          heightCm != null && heightCm <= 0) {
        throw ArgumentError('Invalid measurement');
      }
      final current =
          await loadProfile() ?? const UserProfile(weightKg: 0, heightCm: 0);
      final next = current.copyWith(weightKg: weightKg, heightCm: heightCm);
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString(_profileKey, jsonEncode(next.toJson()))) {
        throw StateError('Could not save measurement');
      }
      return next;
    });
    _measurementWrites = pending.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return pending;
  }

  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final raw = prefs.getString(_profileKey);
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<UserProfile> saveTrainingPreferences(int days, String firstDay) async {
    if (days < 1 || days > 7 || !['SUNDAY', 'MONDAY'].contains(firstDay)) {
      throw ArgumentError('Invalid training preferences');
    }
    // Merge the latest persisted profile so editing a goal cannot overwrite
    // demographic edits made in another screen, or mark onboarding complete.
    final current = await loadProfile() ?? const UserProfile();
    final next = current.copyWith(
      workoutDaysPerWeek: days,
      firstDayOfWeek: firstDay,
    );
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(_profileKey, jsonEncode(next.toJson()))) {
      throw StateError('Could not save training preferences');
    }
    return next;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await prefs.remove(_completedKey);
  }
}
