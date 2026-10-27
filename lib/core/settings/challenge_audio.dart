import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'settings_record.dart';

class ChallengeAudio extends ChangeNotifier {
  final player = AudioPlayer();
  StreamSubscription<PlayerState>? subscription;
  StreamSubscription<void>? completedSubscription;
  String? loadedPath;
  String get cover => index < 3
      ? [
          'assets/images/workouts/dancing_all_night_cover.png',
          'assets/images/workouts/cant_stop_cover.png',
          'assets/images/workouts/holiday_wishes_cover.png',
        ][index]
      : 'assets/images/workouts/hiit_fat_burning.jpg';
  final tracks = <(String, String)>[
    ('Dancing All Night', 'audio/Dancing_All_Night.wav'),
    ("Can't Stop", 'audio/Cant_Stop.wav'),
    ('Holiday Wishes', 'audio/Holiday_Wishes.wav'),
  ];
  int index = 0;
  bool enabled = true, playing = false, repeat = true, disposed = false;
  double volume = .4;
  String? error;
  Future<void> load() async {
    final prefs = await SettingsRecord.load('settings_');
    if (disposed) return;
    enabled = prefs.getBool('settings_music') ?? true;
    volume = (prefs.getDouble('settings_music_volume') ?? .4).clamp(0, 1);
    for (final raw
        in prefs.getStringList('settings_imported_tracks') ?? <String>[]) {
      try {
        final item = jsonDecode(raw) as Map;
        final title = item['title'] as String, path = item['path'] as String;
        if (title.trim().isNotEmpty &&
            await File(path).exists() &&
            !tracks.any((t) => t.$2 == path)) {
          tracks.add((title, path));
        }
      } catch (_) {
        /* Leave an invalid imported track out of playback. */
      }
    }
    if (disposed) return;
    final saved = prefs.getString('settings_current_track');
    final found = tracks.indexWhere((t) => t.$2 == saved);
    if (found >= 0) index = found;
    subscription ??= player.onPlayerStateChanged.listen((state) {
      if (!disposed) {
        playing = state == PlayerState.playing;
        notifyListeners();
      }
    });
    repeat = prefs.getBool('settings_music_repeat') ?? true;
    completedSubscription ??= player.onPlayerComplete.listen((_) {
      if (!disposed && enabled && !repeat) unawaited(select(index + 1));
    });
    await player.setReleaseMode(repeat ? ReleaseMode.loop : ReleaseMode.stop);
    if (disposed) return;
    await player.setVolume(prefs.getBool('settings_mute') == true ? 0 : volume);
    if (!disposed) notifyListeners();
  }

  Future<void> play([bool value = true]) async {
    if (disposed) return;
    try {
      if (!value || !enabled) {
        await player.pause();
      } else {
        final path = tracks[index].$2;
        if (loadedPath == path && player.state == PlayerState.paused) {
          await player.resume();
        } else {
          loadedPath = path;
          await player.play(
            path.startsWith('audio/')
                ? AssetSource(path)
                : DeviceFileSource(path),
          );
        }
      }
      error = null;
    } catch (_) {
      error =
          'Music is unavailable on this device. You can continue the workout.';
    }
    if (!disposed) notifyListeners();
  }

  Future<void> select(int value) async {
    if (disposed) return;
    final selected = (value + tracks.length) % tracks.length;
    try {
      final prefs = await SettingsRecord.load('settings_');
      await prefs.setString('settings_current_track', tracks[selected].$2);
      if (disposed) return;
      index = selected;
    } catch (_) {
      error = 'The selected music could not be saved.';
      if (!disposed) notifyListeners();
      return;
    }
    await play();
  }

  Future<void> toggle(bool value) async {
    try {
      await (await SettingsRecord.load(
        'settings_',
      )).setBool('settings_music', value);
      if (disposed) return;
      enabled = value;
      await play(value);
    } catch (_) {
      error = 'Music preference could not be saved.';
      if (!disposed) notifyListeners();
    }
  }

  Future<void> setVolume(double value) async {
    if (disposed) return;
    final nextVolume = value.clamp(0.0, 1.0);
    try {
      final prefs = await SettingsRecord.load('settings_');
      await prefs.setDouble('settings_music_volume', nextVolume);
      if (disposed) return;
      volume = nextVolume;
      await player.setVolume(
        prefs.getBool('settings_mute') == true ? 0 : volume,
      );
    } catch (_) {
      error = 'Music volume could not be changed on this device.';
    }
    if (!disposed) notifyListeners();
  }

  Future<void> toggleRepeat() async {
    if (disposed) return;
    final nextRepeat = !repeat;
    try {
      await (await SettingsRecord.load(
        'settings_',
      )).setBool('settings_music_repeat', nextRepeat);
      if (disposed) return;
      repeat = nextRepeat;
      await player.setReleaseMode(repeat ? ReleaseMode.loop : ReleaseMode.stop);
    } catch (_) {
      error = 'Music repeat could not be changed on this device.';
    }
    if (!disposed) notifyListeners();
  }

  @override
  void dispose() {
    disposed = true;
    subscription?.cancel();
    completedSubscription?.cancel();
    player.dispose().catchError((Object _) {});
    super.dispose();
  }
}
