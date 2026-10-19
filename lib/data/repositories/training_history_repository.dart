import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrainingCompletion {
  const TrainingCompletion({
    required this.id,
    required this.workoutId,
    required this.title,
    required this.finishedAt,
    required this.seconds,
  });
  final String id, workoutId, title;
  final DateTime finishedAt;
  final int seconds;
  Map<String, dynamic> toJson() => {
    'id': id,
    'workoutId': workoutId,
    'title': title,
    'finishedAt': finishedAt.toUtc().toIso8601String(),
    'seconds': seconds,
  };
  factory TrainingCompletion.fromJson(Map<String, dynamic> json) =>
      TrainingCompletion(
        id: json['id'] as String,
        workoutId: json['workoutId'] as String,
        title: json['title'] as String,
        finishedAt: DateTime.parse(json['finishedAt'] as String).toLocal(),
        seconds: json['seconds'] as int,
      );
}

class TrainingHistoryRepository extends ChangeNotifier {
  static final instance = TrainingHistoryRepository();
  static const storageKey = 'training_completions_v1';
  List<TrainingCompletion> _entries = [];
  List<TrainingCompletion> get entries => List.unmodifiable(_entries);
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    _entries = raw == null
        ? []
        : (jsonDecode(raw) as List)
              .map(
                (e) => TrainingCompletion.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
    notifyListeners();
  }

  Future<void> _writes = Future.value();
  Future<void> complete(TrainingCompletion completion) {
    final pending = _writes.then((_) => _complete(completion));
    // Keep the queue usable after failure while the caller still receives the
    // original failed Future and can show a retry action.
    _writes = pending.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return pending;
  }

  Future<void> _complete(TrainingCompletion completion) async {
    // Only mutate observable state after a durable write. Repeated Finish/retry
    // for the same session ID cannot create duplicate completions.
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    final stored = raw == null
        ? <TrainingCompletion>[]
        : (jsonDecode(raw) as List)
              .map(
                (e) => TrainingCompletion.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
    if (stored.any((e) => e.id == completion.id)) return;
    final next = [...stored, completion];
    if (!await prefs.setString(
      storageKey,
      jsonEncode(next.map((e) => e.toJson()).toList()),
    )) {
      throw StateError('Could not save workout completion');
    }
    _entries = next;
    notifyListeners();
  }

  static DateTime day(DateTime value) =>
      DateTime(value.year, value.month, value.day);
  int weeklyDays(DateTime now, {bool sundayFirst = false}) {
    final today = day(now);
    final offset = sundayFirst ? today.weekday % 7 : today.weekday - 1;
    final start = DateTime(today.year, today.month, today.day - offset);
    return _entries
        .map((e) => day(e.finishedAt))
        .where((d) => !d.isBefore(start) && !d.isAfter(today))
        .toSet()
        .length;
  }

  int streak(DateTime now) {
    final days = _entries.map((e) => day(e.finishedAt)).toSet();
    var cursor = day(now);
    if (!days.contains(cursor)) {
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    var count = 0;
    while (days.contains(cursor)) {
      count++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return count;
  }
}
