import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeightRecord {
  WeightRecord({required DateTime date, required this.kg})
    : date = DateTime(date.year, date.month, date.day) {
    if (!kg.isFinite || kg <= 0) throw ArgumentError('Invalid weight');
  }
  final DateTime date;
  final double kg;
  Map<String, dynamic> toJson() => {
    'date':
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    'kg': kg,
  };
  factory WeightRecord.fromJson(Map<String, dynamic> json) => WeightRecord(
    date: DateTime.parse(json['date'] as String),
    kg: (json['kg'] as num).toDouble(),
  );
}

class WeightHistoryRepository extends ChangeNotifier {
  static final instance = WeightHistoryRepository();
  static const storageKey = 'weight_history_v1';
  List<WeightRecord> _records = [];
  List<WeightRecord> get records => List.unmodifiable(_records);
  Future<void> _writes = Future.value();

  List<WeightRecord> _decode(String? raw) {
    final records = raw == null
        ? <WeightRecord>[]
        : (jsonDecode(raw) as List)
              .map(
                (e) =>
                    WeightRecord.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList();
    records.sort((a, b) => a.date.compareTo(b.date));
    return records;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    _records = _decode(prefs.getString(storageKey));
    notifyListeners();
  }

  Future<void> save(WeightRecord record) {
    final pending = _writes.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final next = _decode(prefs.getString(storageKey))
        ..removeWhere((e) => e.date == record.date)
        ..add(record);
      next.sort((a, b) => a.date.compareTo(b.date));
      if (!await prefs.setString(
        storageKey,
        jsonEncode(next.map((e) => e.toJson()).toList()),
      )) {
        throw StateError('Could not save weight history');
      }
      _records = next;
      notifyListeners();
    });
    _writes = pending.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return pending;
  }
}
