import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'general_settings.dart';

class WorkoutReminder {
  const WorkoutReminder({
    required this.id,
    required this.hour,
    required this.minute,
    required this.days,
    this.enabled = true,
  });
  final int id;
  final int hour;
  final int minute;
  // Calendar weekdays: Sunday = 1, Saturday = 7.
  final List<int> days;
  final bool enabled;

  WorkoutReminder copyWith({
    int? hour,
    int? minute,
    List<int>? days,
    bool? enabled,
  }) => WorkoutReminder(
    id: id,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    days: days ?? this.days,
    enabled: enabled ?? this.enabled,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'hour': hour,
    'minute': minute,
    'days': days,
    'enabled': enabled,
  };
  static WorkoutReminder? parse(dynamic json) {
    if (json is! Map) return null;
    final id = json['id'],
        hour = json['hour'],
        minute = json['minute'],
        days = json['days'];
    if (id is! int ||
        id < 1 ||
        id > 2147483647 ||
        hour is! int ||
        hour < 0 ||
        hour > 23 ||
        minute is! int ||
        minute < 0 ||
        minute > 59 ||
        days is! List ||
        days.isEmpty ||
        days.any((day) => day is! int || day < 1 || day > 7) ||
        json['enabled'] is! bool) {
      return null;
    }
    return WorkoutReminder(
      id: id,
      hour: hour,
      minute: minute,
      days: days.cast<int>().toSet().toList()..sort(),
      enabled: json['enabled'] as bool,
    );
  }
}

class ReminderRepository {
  static const key = 'workout_reminders';

  Future<List<WorkoutReminder>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = <WorkoutReminder>[];
    for (final raw in prefs.getStringList(key) ?? <String>[]) {
      try {
        final reminder = WorkoutReminder.parse(jsonDecode(raw));
        if (reminder != null &&
            !reminders.any((entry) => entry.id == reminder.id)) {
          reminders.add(reminder);
        }
      } catch (_) {
        /* Ignore a malformed entry without losing other reminders. */
      }
    }
    return reminders;
  }

  Future<void> save(List<WorkoutReminder> reminders) async {
    final previous = await load();
    await GeneralSettings.channel.invokeMethod<void>(
      'syncReminders',
      reminders.map((entry) => entry.toJson()).toList(),
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setStringList(
        key,
        reminders.map((entry) => jsonEncode(entry.toJson())).toList(),
      )) {
        throw StateError('Could not save reminders');
      }
    } catch (_) {
      await GeneralSettings.channel.invokeMethod<void>(
        'syncReminders',
        previous.map((entry) => entry.toJson()).toList(),
      );
      rethrow;
    }
  }
}
