import 'package:flutter/services.dart';

class TtsService {
  static const channel = MethodChannel('fitness_pro/tts');
  Future<Map<String, dynamic>> state({bool refresh = false}) async =>
      Map<String, dynamic>.from(
        await channel.invokeMapMethod<String, dynamic>(
              refresh ? 'refresh' : 'getState',
            ) ??
            {},
      );
  Future<void> action(String method, [dynamic arguments]) =>
      channel.invokeMethod<void>(method, arguments);
}
