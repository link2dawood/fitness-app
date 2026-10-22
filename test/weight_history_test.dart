import 'dart:convert';
import 'package:fitness_pro/data/models/user_profile.dart';
import 'package:fitness_pro/data/repositories/weight_history_repository.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'decimal logs survive reload, replace same date, and preserve months and years',
    () async {
      final repo = WeightHistoryRepository();
      await repo.save(WeightRecord(date: DateTime(2025, 12, 1), kg: 80));
      await repo.save(WeightRecord(date: DateTime(2026, 1, 1), kg: 72.6));
      await repo.save(WeightRecord(date: DateTime(2026, 1, 1, 23), kg: 72.4));
      final reopened = WeightHistoryRepository();
      await reopened.load();
      expect(reopened.records.map((e) => e.kg), [80, 72.4]);
      expect(reopened.records.last.date, DateTime(2026, 1, 1));
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(WeightHistoryRepository.storageKey),
        contains('2025-12-01'),
      );
    },
  );

  test('corrupt history is not silently replaced by a save', () async {
    SharedPreferences.setMockInitialValues({
      WeightHistoryRepository.storageKey: 'broken',
    });
    final repo = WeightHistoryRepository();
    await expectLater(repo.load(), throwsFormatException);
    await expectLater(
      repo.save(WeightRecord(date: DateTime(2026), kg: 72.6)),
      throwsFormatException,
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(WeightHistoryRepository.storageKey), 'broken');
  });

  test(
    'profile supports legacy integers and new decimals without rounding',
    () async {
      expect(UserProfile.fromJson({'weightKg': 73}).weightKg, 73);
      final profile = const UserProfile(weightKg: 72.6, heightCm: 180);
      final repo = OnboardingRepository();
      await repo.saveProfile(profile);
      expect((await repo.loadProfile())!.weightKg, 72.6);
      expect(
        UserProfile.fromJson(jsonDecode(jsonEncode(profile.toJson()))).weightKg,
        72.6,
      );
    },
  );
}
