import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/routes/app_routes.dart';

class WorkoutSettingsView extends StatefulWidget {
  const WorkoutSettingsView({super.key});

  @override
  State<WorkoutSettingsView> createState() => _WorkoutSettingsViewState();
}

class _WorkoutSettingsViewState extends State<WorkoutSettingsView> {
  final ValueNotifier<int> _audioRevision = ValueNotifier(0);
  final List<StreamSubscription<dynamic>> _audioSubscriptions = [];
  bool _preferencesReady = false;
  bool _importingAudio = false;
  SharedPreferences? _prefs;

  void _updateAudio(VoidCallback update) {
    if (!mounted) return;
    setState(update);
    _audioRevision.value++;
  }

  bool _mute = false;
  bool _voiceGuide = true;
  bool _coachTips = true;
  bool _soundEffect = true;
  double _voiceVol = 0.8;
  double _effectVol = 0.4;

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTracks = <Map<String, String>>[];
      for (final raw
          in prefs.getStringList('settings_imported_tracks') ?? <String>[]) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is! Map) continue;
          final path = decoded['path'];
          final title = decoded['title'];
          if (path is! String ||
              path.isEmpty ||
              title is! String ||
              title.trim().isEmpty ||
              title.trim().toLowerCase() == 'null') {
            continue;
          }
          if (!await File(path).exists()) continue;
          savedTracks.add({
            'title': title,
            'path': path,
            'subtitle': 'Saved device audio',
            'image': 'assets/images/workouts/hiit_fat_burning.jpg',
          });
        } catch (_) {
          // Skip invalid saved entries while retaining the built-in songs.
        }
      }
      if (!mounted) return;
      setState(() {
        _musicQueue.insertAll(0, savedTracks);
        final savedPath = prefs.getString('settings_current_track');
        final index = _musicQueue.indexWhere(
          (track) => track['path'] == savedPath,
        );
        _currentTrackIndex = index < 0 ? 0 : index;
        _preferencesReady = true;
        _prefs = prefs;
        _musicOn = prefs.getBool('settings_music') ?? true;
        _prepSeconds = prefs.getInt('settings_prep') ?? 15;
        _restTimerMode = prefs.getString('settings_rest_mode') ?? 'Default';
        _customRestSeconds = prefs.getInt('settings_rest_seconds') ?? 30;
        _mute = prefs.getBool('settings_mute') ?? false;
        _voiceGuide = prefs.getBool('settings_voice') ?? true;
        _coachTips = prefs.getBool('settings_tips') ?? true;
        _soundEffect = prefs.getBool('settings_effect') ?? true;
        _voiceVol = prefs.getDouble('settings_voice_volume') ?? 0.8;
        _effectVol = prefs.getDouble('settings_effect_volume') ?? 0.4;
      });
      await _audioPlayer.setVolume(_mute || !_soundEffect ? 0 : _effectVol);
    } catch (_) {
      if (!mounted) return;
      setState(() => _preferencesReady = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load settings. Please try again.'),
        ),
      );
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setBool('settings_music', _musicOn);
      await prefs.setInt('settings_prep', _prepSeconds);
      await prefs.setString('settings_rest_mode', _restTimerMode);
      await prefs.setInt('settings_rest_seconds', _customRestSeconds);
      await prefs.setBool('settings_mute', _mute);
      await prefs.setBool('settings_voice', _voiceGuide);
      await prefs.setBool('settings_tips', _coachTips);
      await prefs.setBool('settings_effect', _soundEffect);
      await prefs.setDouble('settings_voice_volume', _voiceVol);
      await prefs.setDouble('settings_effect_volume', _effectVol);
      await _audioPlayer.setVolume(_mute || !_soundEffect ? 0 : _effectVol);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save settings. Please try again.'),
          ),
        );
      }
    }
  }

  bool _musicOn = true;
  int _prepSeconds = 15;
  String _restTimerMode = 'Default'; // 'Default' or 'Custom'
  int _customRestSeconds = 30;

  // Audio Player State
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int _currentTrackIndex = 0;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;

  // Built-in Music Queue
  final List<Map<String, String>> _musicQueue = [
    {
      'title': 'Dancing All Night',
      'subtitle': 'Home Workout Music',
      'image': 'assets/images/workouts/dancing_all_night_cover.png',
      'path': 'audio/Dancing_All_Night.wav',
    },
    {
      'title': "Can't Stop",
      'subtitle': 'Home Workout Music',
      'image': 'assets/images/workouts/cant_stop_cover.png',
      'path': 'audio/Cant_Stop.wav',
    },
    {
      'title': 'Holiday Wishes',
      'subtitle': 'Home Workout Music',
      'image': 'assets/images/workouts/holiday_wishes_cover.png',
      'path': 'audio/Holiday_Wishes.wav',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _loadPreferences();
  }

  void _initAudioPlayer() {
    _audioSubscriptions.add(
      _audioPlayer.onPlayerStateChanged.listen((state) {
        _updateAudio(() => _isPlaying = state == PlayerState.playing);
      }),
    );
    _audioSubscriptions.add(
      _audioPlayer.onDurationChanged.listen((duration) {
        _updateAudio(() => _audioDuration = duration);
      }),
    );
    _audioSubscriptions.add(
      _audioPlayer.onPositionChanged.listen((position) {
        _updateAudio(() => _audioPosition = position);
      }),
    );
    _audioSubscriptions.add(
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted && _musicOn) _playNext();
      }),
    );
  }

  Future<void> _playPauseAfterSelection() => _playSelected();

  Future<void> _playSelected() async {
    if (!mounted) return;
    final path = _musicQueue[_currentTrackIndex]['path']!;
    _updateAudio(() {
      _audioPosition = Duration.zero;
      _audioDuration = Duration.zero;
    });
    try {
      await _audioPlayer.stop();
      if (!mounted) return;
      await _audioPlayer.play(
        path.startsWith('audio/') ? AssetSource(path) : DeviceFileSource(path),
      );
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString('settings_current_track', path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not play this audio file.')),
        );
      }
    }
  }

  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else if (_audioPosition > Duration.zero) {
        await _audioPlayer.resume();
      } else {
        await _playSelected();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update audio playback.')),
        );
      }
    }
  }

  Future<void> _playNext() async {
    if (!mounted) return;
    _updateAudio(
      () => _currentTrackIndex = (_currentTrackIndex + 1) % _musicQueue.length,
    );
    await _playSelected();
  }

  Future<void> _playPrevious() async {
    if (!mounted) return;
    _updateAudio(
      () => _currentTrackIndex =
          (_currentTrackIndex - 1 + _musicQueue.length) % _musicQueue.length,
    );
    await _playSelected();
  }

  Future<void> _pickDeviceAudio() async {
    if (_importingAudio) return;
    _updateAudio(() => _importingAudio = true);
    try {
      final result = await FilePicker.pickFiles(type: FileType.audio);
      if (!mounted || result.isEmpty) return;
      final picked = result.single;
      final directory = Directory(
        '${(await getApplicationDocumentsDirectory()).path}/workout_music',
      );
      await directory.create(recursive: true);
      final name = picked.name.trim();
      final title = name.isEmpty || name.toLowerCase() == 'null'
          ? 'Imported song'
          : name;
      final safeName = title.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final saved = File(
        '${directory.path}/${DateTime.now().microsecondsSinceEpoch}_$safeName',
      );
      final output = saved.openWrite();
      try {
        await output.addStream(picked.readAsByteStream());
      } finally {
        await output.close();
      }
      if (await saved.length() == 0) {
        await saved.delete();
        throw const FileSystemException('Audio file is empty.');
      }
      if (!mounted) return;
      final track = {
        'title': title,
        'subtitle': 'Saved device audio',
        'image': 'assets/images/workouts/hiit_fat_burning.jpg',
        'path': saved.path,
      };
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final imported = [
        track,
        ..._musicQueue.where((entry) => !entry['path']!.startsWith('audio/')),
      ];
      if (!await prefs.setStringList(
        'settings_imported_tracks',
        imported.map(jsonEncode).toList(),
      )) {
        throw StateError('Could not save music library');
      }
      if (!mounted) return;
      _updateAudio(() {
        _musicQueue.insert(0, track);
        _currentTrackIndex = 0;
        _musicOn = true;
      });
      await prefs.setBool('settings_music', true);
      await _playSelected();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not import this song. Choose a readable audio file and try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) _updateAudio(() => _importingAudio = false);
    }
  }

  @override
  void dispose() {
    for (final subscription in _audioSubscriptions) {
      subscription.cancel();
    }
    _audioRevision.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF111827),
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Workout Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF3F4F6), height: 1),
        ),
      ),
      body: !_preferencesReady
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                _buildItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Gender',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pushNamed(AppRoutes.genderSettings);
                  },
                ),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                _buildItem(
                  icon: Icons.music_note_rounded,
                  title: 'Music',
                  valueText: _musicOn ? 'on >' : 'off >',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _showMusicModal(context);
                  },
                ),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                _buildItem(
                  icon: Icons.coffee_rounded,
                  title: 'Rest timer',
                  valueText: '$_restTimerMode >',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _showRestTimerModal(context);
                  },
                ),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                _buildItem(
                  icon: Icons.history_toggle_off_rounded,
                  title: 'Prep timer',
                  valueText: '$_prepSeconds secs >',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _showPrepTimerModal(context);
                  },
                ),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                _buildItem(
                  icon: Icons.record_voice_over_rounded,
                  title: 'Sound options',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _showSoundOptionsModal(context);
                  },
                ),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                _buildItem(
                  icon: Icons.replay_rounded,
                  title: 'Restart progress',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _showRestartProgressDialog(context);
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    String? valueText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF8E97A5)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            if (valueText != null)
              Text(
                valueText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0066FF),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Music Modal ────────────────────────────────────────────────────────────
  void _showMusicModal(BuildContext context) {
    bool localMusicOn = _musicOn;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return ValueListenableBuilder<int>(
          valueListenable: _audioRevision,
          builder: (_, revision, child) => StatefulBuilder(
            builder: (ctx, setSheet) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Switch Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Music',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Switch(
                          value: localMusicOn,
                          activeTrackColor: const Color(0xFF0066FF),
                          onChanged: (val) {
                            setSheet(() => localMusicOn = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    const Text(
                      'Play music during your workout to stay motivated!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Active Music Player UI
                    if (localMusicOn) ...[
                      // Song Info
                      Row(
                        children: [
                          ClipOval(
                            child: Container(
                              width: 56,
                              height: 56,
                              color: const Color(0xFFF3F4F6),
                              child: Image.asset(
                                _musicQueue[_currentTrackIndex]['image']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _musicQueue[_currentTrackIndex]['title']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _musicQueue[_currentTrackIndex]['subtitle']!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.repeat_rounded,
                            color: Color(0xFF111827),
                            size: 24,
                          ),
                          GestureDetector(
                            onTap: () async {
                              await _playPrevious();
                              if (ctx.mounted) setSheet(() {});
                            },
                            child: const Icon(
                              Icons.fast_rewind_rounded,
                              color: Color(0xFF111827),
                              size: 32,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await _playPause();
                              if (ctx.mounted) setSheet(() {});
                            },
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0066FF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await _playNext();
                              if (ctx.mounted) setSheet(() {});
                            },
                            child: const Icon(
                              Icons.fast_forward_rounded,
                              color: Color(0xFF111827),
                              size: 32,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              // Pop current music modal and show queue
                              Navigator.of(ctx).pop();
                              _showMusicQueueModal(context);
                            },
                            child: const Icon(
                              Icons.format_list_bulleted_rounded,
                              color: Color(0xFF111827),
                              size: 24,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Progress Slider
                      Row(
                        children: [
                          const Icon(
                            Icons.volume_down_rounded,
                            color: Color(0xFFD1D5DB),
                            size: 20,
                          ),
                          Expanded(
                            child: Slider(
                              value: _audioDuration.inMilliseconds > 0
                                  ? _audioPosition.inMilliseconds
                                        .toDouble()
                                        .clamp(
                                          0.0,
                                          _audioDuration.inMilliseconds
                                              .toDouble(),
                                        )
                                  : 0.0,
                              max: _audioDuration.inMilliseconds > 0
                                  ? _audioDuration.inMilliseconds.toDouble()
                                  : 1.0,
                              activeColor: const Color(0xFF0066FF),
                              inactiveColor: const Color(0xFFE5E7EB),
                              onChanged: (v) {
                                _audioPlayer.seek(
                                  Duration(milliseconds: v.toInt()),
                                );
                              },
                            ),
                          ),
                          const Icon(
                            Icons.volume_up_rounded,
                            color: Color(0xFFD1D5DB),
                            size: 20,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Stream Audio Link -> Choose from device
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            HapticFeedback.selectionClick();
                            await _pickDeviceAudio();
                            if (ctx.mounted) setSheet(() {});
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Choose from device',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF4B5563),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      // When music is off, just give some space
                      const SizedBox(height: 48),
                    ],

                    // DONE Button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _musicOn = localMusicOn;
                        });
                        _savePreferences();
                        if (!_musicOn && _isPlaying) {
                          _audioPlayer.pause();
                        }
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        height: 54,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066FF),
                          borderRadius: BorderRadius.circular(27),
                        ),
                        child: const Center(
                          child: Text(
                            'DONE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── Music Queue Modal ──────────────────────────────────────────────────────
  void _showMusicQueueModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return ValueListenableBuilder<int>(
          valueListenable: _audioRevision,
          builder: (_, revision, child) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Playing Queue',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await _pickDeviceAudio();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _importingAudio ? 'Loading...' : 'Import',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Queue List
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _musicQueue.length,
                    separatorBuilder: (ctx, i) => Column(
                      children: const [
                        SizedBox(height: 8),
                        Divider(color: Color(0xFFF3F4F6), height: 1),
                        SizedBox(height: 8),
                      ],
                    ),
                    itemBuilder: (ctx, i) {
                      final track = _musicQueue[i];
                      return _buildQueueItem(
                        imagePath: track['image']!,
                        title: track['title']!,
                        subtitle: track['subtitle']!,
                        isActive: i == _currentTrackIndex,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _updateAudio(() => _currentTrackIndex = i);
                          Navigator.of(context).pop(); // Close queue
                          _showMusicModal(context); // Reopen active player
                          _playPauseAfterSelection(); // Auto play when selected from queue
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQueueItem({
    required String imagePath,
    required String title,
    required String subtitle,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipOval(
              child: Container(
                width: 56,
                height: 56,
                color: const Color(0xFFF3F4F6),
                child: imagePath.contains('assets')
                    ? Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.music_note,
                              color: Color(0xFFD1D5DB),
                            ),
                      )
                    : const Icon(Icons.music_note, color: Color(0xFF0066FF)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? const Color(0xFF0066FF)
                          : const Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.more_vert_rounded,
              color: isActive ? Colors.transparent : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  // ── Rest Timer Modal ───────────────────────────────────────────────────────
  void _showRestTimerModal(BuildContext context) {
    bool localModeIsDefault = _restTimerMode == 'Default';
    bool localEnableRest = _restTimerMode != 'Off';
    int localCustomSeconds = _customRestSeconds;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Container(
              height: 520,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Rest timer',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Segmented Control (Default | Custom)
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setSheet(() => localModeIsDefault = true);
                            },
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: localModeIsDefault
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: localModeIsDefault
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.04,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Default',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: localModeIsDefault
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: localModeIsDefault
                                        ? const Color(0xFF111827)
                                        : const Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setSheet(() => localModeIsDefault = false);
                            },
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: !localModeIsDefault
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: !localModeIsDefault
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.04,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Custom',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: !localModeIsDefault
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: !localModeIsDefault
                                        ? const Color(0xFF111827)
                                        : const Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Default Content ──────────────────────────────────────────
                  if (localModeIsDefault)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.local_cafe_rounded,
                              size: 40,
                              color: Color(0xFF0066FF),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Smart Rest',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Follow the coach-recommended intervals for optimal recovery.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  // ── Custom Content ───────────────────────────────────────────
                  else
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Enable rest',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              Switch(
                                value: localEnableRest,
                                activeTrackColor: const Color(0xFF0066FF),
                                onChanged: (val) {
                                  setSheet(() => localEnableRest = val);
                                },
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (localEnableRest)
                            SizedBox(
                              height: 140,
                              child: ListWheelScrollView.useDelegate(
                                itemExtent: 48,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (i) {
                                  HapticFeedback.selectionClick();
                                  setSheet(
                                    () => localCustomSeconds = (i + 1) * 5,
                                  );
                                },
                                controller: FixedExtentScrollController(
                                  initialItem: (localCustomSeconds ~/ 5) - 1,
                                ),
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: 18,
                                  builder: (ctx, i) {
                                    final seconds = (i + 1) * 5;
                                    final isSelected =
                                        seconds == localCustomSeconds;
                                    return Center(
                                      child: Container(
                                        decoration: isSelected
                                            ? BoxDecoration(
                                                color: const Color(0xFFF3F4F6),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              )
                                            : null,
                                        alignment: Alignment.center,
                                        width: double.infinity,
                                        child: Text(
                                          '${seconds}s',
                                          style: TextStyle(
                                            fontSize: isSelected ? 22 : 18,
                                            fontWeight: isSelected
                                                ? FontWeight.w800
                                                : FontWeight.w600,
                                            color: isSelected
                                                ? const Color(0xFF0066FF)
                                                : const Color(0xFFD1D5DB),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          else
                            const Center(
                              child: Text(
                                'Rest disabled',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          const Spacer(),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Bottom Done Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (localModeIsDefault) {
                          _restTimerMode = 'Default';
                        } else {
                          _restTimerMode = localEnableRest
                              ? '${localCustomSeconds}s'
                              : 'Off';
                          _customRestSeconds = localCustomSeconds;
                        }
                      });
                      _savePreferences();
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      height: 54,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066FF),
                        borderRadius: BorderRadius.circular(27),
                      ),
                      child: const Center(
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Prep Timer Modal ───────────────────────────────────────────────────────
  void _showPrepTimerModal(BuildContext context) {
    int localPrepSeconds = _prepSeconds;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Container(
              height: 400,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Prep timer',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    'Set the prep time before workouts',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),

                  const Spacer(),

                  // Scroll Picker
                  SizedBox(
                    height: 140,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 48,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (i) {
                        HapticFeedback.selectionClick();
                        setSheet(
                          () => localPrepSeconds = (i + 1) * 5,
                        ); // 5, 10, 15...
                      },
                      controller: FixedExtentScrollController(
                        initialItem: (localPrepSeconds ~/ 5) - 1,
                      ),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 12, // Up to 60s
                        builder: (ctx, i) {
                          final seconds = (i + 1) * 5;
                          final isSelected = seconds == localPrepSeconds;
                          return Center(
                            child: Container(
                              decoration: isSelected
                                  ? BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(16),
                                    )
                                  : null,
                              alignment: Alignment.center,
                              width: double.infinity,
                              child: Text(
                                '${seconds}s',
                                style: TextStyle(
                                  fontSize: isSelected ? 22 : 18,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFF0066FF)
                                      : const Color(0xFFD1D5DB),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Bottom Done Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _prepSeconds = localPrepSeconds;
                        _savePreferences();
                      });
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      height: 54,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066FF),
                        borderRadius: BorderRadius.circular(27),
                      ),
                      child: const Center(
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Sound Options Modal ────────────────────────────────────────────────────
  void _showSoundOptionsModal(BuildContext context) {
    bool localMute = _mute;
    bool localVoiceGuide = _voiceGuide;
    bool localCoachTips = _coachTips;
    bool localSoundEffect = _soundEffect;
    double localVoiceVol = _voiceVol;
    double localEffectVol = _effectVol;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sound options',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // Mute Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Mute',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              Switch(
                                value: localMute,
                                activeTrackColor: const Color(0xFF0066FF),
                                onChanged: (val) {
                                  setSheet(() => localMute = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Voice Guide & Tips Card
                        Opacity(
                          opacity: localMute ? 0.5 : 1.0,
                          child: IgnorePointer(
                            ignoring: localMute,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Voice guide (coming soon)',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      Switch(
                                        value: localVoiceGuide,
                                        activeTrackColor: const Color(
                                          0xFF0066FF,
                                        ),
                                        onChanged: null,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Coach tips (coming soon)',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      Switch(
                                        value: localCoachTips,
                                        activeTrackColor: const Color(
                                          0xFF0066FF,
                                        ),
                                        onChanged: null,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.volume_down_rounded,
                                        color: Color(0xFFD1D5DB),
                                        size: 20,
                                      ),
                                      Expanded(
                                        child: Slider(
                                          value: localVoiceVol,
                                          activeColor: const Color(0xFF0066FF),
                                          inactiveColor: const Color(
                                            0xFFE5E7EB,
                                          ),
                                          onChanged: null,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.volume_up_rounded,
                                        color: Color(0xFFD1D5DB),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Sound Effect Card
                        Opacity(
                          opacity: localMute ? 0.5 : 1.0,
                          child: IgnorePointer(
                            ignoring: localMute,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Music audio',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      Switch(
                                        value: localSoundEffect,
                                        activeTrackColor: const Color(
                                          0xFF0066FF,
                                        ),
                                        onChanged: (val) => setSheet(
                                          () => localSoundEffect = val,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.volume_down_rounded,
                                        color: Color(0xFFD1D5DB),
                                        size: 20,
                                      ),
                                      Expanded(
                                        child: Slider(
                                          value: localEffectVol,
                                          activeColor: const Color(0xFF0066FF),
                                          inactiveColor: const Color(
                                            0xFFE5E7EB,
                                          ),
                                          onChanged: (v) => setSheet(
                                            () => localEffectVol = v,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.volume_up_rounded,
                                        color: Color(0xFFD1D5DB),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Button Area
                  Container(
                    color: const Color(0xFFF3F4F6),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _mute = localMute;
                          _voiceGuide = localVoiceGuide;
                          _coachTips = localCoachTips;
                          _soundEffect = localSoundEffect;
                          _voiceVol = localVoiceVol;
                          _effectVol = localEffectVol;
                        });
                        _savePreferences();
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        height: 54,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066FF),
                          borderRadius: BorderRadius.circular(27),
                        ),
                        child: const Center(
                          child: Text(
                            'DONE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRestartProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Restart Progress?'),
        content: const Text(
          'There is no saved workout progress to restart. Workout progress tracking is not available yet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
