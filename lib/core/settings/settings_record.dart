import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A checked, single-record commit. Legacy keys are read until the first save.
class SettingsRecord {
  SettingsRecord._(this.prefix, this.values);
  final String prefix;
  Map<String, dynamic> values;
  static Future<void>? _operations;
  static Future<T> _serial<T>(Future<T> Function() action) {
    final previous = _operations;
    final done = Completer<void>();
    _operations = done.future;
    return () async {
      try {
        if (previous != null) await previous;
        return await action();
      } finally {
        if (identical(_operations, done.future)) _operations = null;
        done.complete();
      }
    }();
  }

  static Future<SettingsRecord> load(String prefix) => _serial(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return SettingsRecord._(prefix, _read(prefs, prefix));
  });
  static Map<String, dynamic> _read(SharedPreferences prefs, String prefix) {
    final raw = prefs.getString('${prefix}record_v1');
    if (raw != null) return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    return {
      for (final key in prefs.getKeys())
        if (key.startsWith(prefix)) key: prefs.get(key),
    };
  }

  bool? getBool(String key) => values[key] as bool?;
  int? getInt(String key) => values[key] as int?;
  double? getDouble(String key) => (values[key] as num?)?.toDouble();
  String? getString(String key) => values[key] as String?;
  List<String>? getStringList(String key) =>
      (values[key] as List?)?.cast<String>();
  int restFor(int routineSeconds) {
    final mode = getString('settings_rest_mode') ?? 'Default';
    if (mode == 'Off') return 0;
    if (mode == 'Default') return routineSeconds;
    return (getInt('settings_rest_seconds') ??
            int.tryParse(mode.replaceAll('s', '')) ??
            30)
        .clamp(0, 600);
  }

  Future<bool> update(Map<String, dynamic> patch) => _serial(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final next = {..._read(prefs, prefix), ...patch};
    try {
      if (!await prefs.setString('${prefix}record_v1', jsonEncode(next))) {
        throw StateError('Settings could not be saved');
      }
    } catch (_) {
      try {
        await prefs.reload();
      } catch (_) {
        /* Next operation must reload before trusting cache. */
      }
      rethrow;
    }
    values = next;
    return true;
  });
  Future<bool> setBool(String key, bool value) => update({key: value});
  Future<bool> setInt(String key, int value) => update({key: value});
  Future<bool> setDouble(String key, double value) => update({key: value});
  Future<bool> setString(String key, String value) => update({key: value});
  Future<bool> setStringList(String key, List<String> value) =>
      update({key: value});
}
