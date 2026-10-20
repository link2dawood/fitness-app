import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/challenge_day.dart';

class ChallengeDayRepository {
  static final instance = ChallengeDayRepository();
  static const storageKey = 'challenge_intense_belly_day1_v1';
  Future<void>? _writes;
  Future<ChallengeDay> load() async {
    final pending = _writes;
    if (pending != null) await pending;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    return raw == null
        ? ChallengeDay.initial()
        : ChallengeDay.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw) as Map),
          );
  }

  Future<void> save(ChallengeDay day) {
    final raw = jsonEncode(day.toJson());
    final previous = _writes;
    late final Future<void> pending;
    pending = () async {
      try {
        if (previous != null) {
          await previous.catchError((Object _) {});
        }
        final prefs = await SharedPreferences.getInstance();
        if (!await prefs.setString(storageKey, raw)) {
          throw StateError('Challenge progress could not be saved');
        }
      } finally {
        if (identical(_writes, pending)) _writes = null;
      }
    }();
    _writes = pending;
    return pending;
  }
}
