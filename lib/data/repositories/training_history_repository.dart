import 'dart:async';
import 'dart:convert';
import '../models/training_calendar.dart';
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
  // Reads and writes share a queue so a refresh cannot publish an older
  // snapshot while a completion is being committed.
  Future<void>? _operations;
  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final previous = _operations;
    final finished = Completer<void>();
    final marker = finished.future;
    _operations = marker;
    return () async {
      try {
        if (previous != null) await previous;
        return await operation();
      } finally {
        // Release before the caller observes completion, including failure.
        // Idle operations start immediately without retaining a stale Future.
        if (identical(_operations, marker)) _operations = null;
        finished.complete();
      }
    }();
  }

  Future<List<TrainingCompletion>> _readDurable(SharedPreferences prefs) async {
    // A failed SharedPreferences write can still change its process cache.
    // Never use that cache to display history or deduplicate a retry.
    await prefs.reload();
    final raw = prefs.getString(storageKey);
    return raw == null
        ? <TrainingCompletion>[]
        : (jsonDecode(raw) as List)
              .map(
                (e) => TrainingCompletion.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
  }

  Future<void> load() => _enqueue(() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = await _readDurable(prefs);
    _entries = stored;
    notifyListeners();
  });

  Future<void> complete(TrainingCompletion completion) =>
      _enqueue(() => _complete(completion));

  Future<void> _complete(TrainingCompletion completion) async {
    // Only mutate observable state after a durable write. Repeated Finish/retry
    // for the same session ID cannot create duplicate completions.
    final prefs = await SharedPreferences.getInstance();
    final stored = await _readDurable(prefs);
    if (stored.any((e) => e.id == completion.id)) {
      _entries = stored;
      notifyListeners();
      return;
    }
    final next = [...stored, completion];
    try {
      if (!await prefs.setString(
        storageKey,
        jsonEncode(next.map((e) => e.toJson()).toList()),
      )) {
        throw StateError('Could not save workout completion');
      }
    } catch (_) {
      try {
        await prefs.reload();
      } catch (_) {
        // Preserve the write error. Future operations must reload successfully
        // before they can trust any cached value or publish history.
      }
      rethrow;
    }
    _entries = next;
    notifyListeners();
  }

  static DateTime day(DateTime value) =>
      DateTime(value.year, value.month, value.day);
  int weeklyDays(DateTime now, {bool sundayFirst = false, String? firstDay}) {
    final today = day(now);
    final start = TrainingCalendar.week(today, firstDay ?? (sundayFirst ? 'SUNDAY' : 'MONDAY')).first;
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
