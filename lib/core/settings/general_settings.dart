import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/app_language.dart';

class GeneralSettings extends ChangeNotifier {
  GeneralSettings._();
  static final instance = GeneralSettings._();
  static const channel = MethodChannel('fitness_pro/general_settings');
  bool weightImperial = false;
  bool heightImperial = false;
  bool keepScreenOn = false;
  AppLanguage language = AppLanguage.english;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final weight = prefs.getBool('general_weight_imperial') ?? false;
    final height = prefs.getBool('general_height_imperial') ?? false;
    var screen = prefs.getBool('general_keep_screen_on') ?? false;
    final selectedLanguage = AppLanguage.fromCode(
      prefs.getString('general_language'),
    );
    try {
      await channel.invokeMethod<void>('keepScreenOn', screen);
    } on MissingPluginException {
      // Native screen control is currently available on Android.
    } on PlatformException {
      screen = false;
    }
    weightImperial = weight;
    heightImperial = height;
    keepScreenOn = screen;
    language = selectedLanguage;
    notifyListeners();
  }

  Future<void> resetPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      'general_weight_imperial',
      'general_height_imperial',
      'general_keep_screen_on',
      'general_language',
    ]) {
      if (!await prefs.remove(key)) {
        throw StateError('Could not reset app settings');
      }
    }
  }

  Future<void> setUnits({required bool weight, required bool height}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setBool('general_weight_imperial', weight) ||
        !await prefs.setBool('general_height_imperial', height)) {
      throw StateError('Could not save units');
    }
    weightImperial = weight;
    heightImperial = height;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage value) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString('general_language', value.code)) {
      throw StateError('Could not save language');
    }
    language = value;
    notifyListeners();
  }

  Future<void> setKeepScreenOn(bool enabled) async {
    await channel.invokeMethod<void>('keepScreenOn', enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('general_keep_screen_on', enabled);
    keepScreenOn = enabled;
    notifyListeners();
  }
}
