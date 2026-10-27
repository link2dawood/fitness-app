import '../../../widgets/app_action.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../core/settings/settings_record.dart';
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
  String? _loadError;
  bool _importingAudio = false;
  SettingsRecord? _prefs;

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
      final prefs = await SettingsRecord.load('settings_');
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
        _loadError = null;
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
      await _audioPlayer
          .setVolume(_mute || !_soundEffect ? 0 : _effectVol)
          .catchError((Object _) {});
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadError = 'Could not load settings. Please retry.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load settings. Please try again.'),
        ),
      );
    }
  }

  bool _savingPreferences = false;
  Future<bool> _savePreferences(Map<String, dynamic> patch) async {
    if (_savingPreferences) return false;
    _savingPreferences = true;
    try {
      final prefs = _prefs ?? await SettingsRecord.load('settings_');
      await prefs.update(patch);
      if (!mounted) return false;
      setState(() {
        _musicOn = prefs.getBool('settings_music') ?? true;
        _prepSeconds = prefs.getInt('settings_prep') ?? 15;
        _restTimerMode = prefs.getString('settings_rest_mode') ?? 'Default';
        _customRestSeconds = prefs.getInt('settings_rest_seconds') ?? 30;
        _mute = prefs.getBool('settings_mute') ?? false;
        _voiceGuide = prefs.getBool('settings_voice') ?? true;
        _coachTips = prefs.getBool('settings_tips') ?? true;
        _soundEffect = prefs.getBool('settings_effect') ?? true;
        _voiceVol = prefs.getDouble('settings_voice_volume') ?? .8;
        _effectVol = prefs.getDouble('settings_effect_volume') ?? .4;
      });
      unawaited(
        _audioPlayer
            .setVolume(_mute || !_soundEffect ? 0 : _effectVol)
            .catchError((Object _) {}),
      );
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not save settings. Your changes are retained; tap Done to retry.',
            ),
          ),
        );
      }
      return false;
    } finally {
      _savingPreferences = false;
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
      final prefs = _prefs ?? await SettingsRecord.load('settings_');
      await prefs.setString('settings_current_track', path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected music could not be saved. Please retry.'),
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    try {
      await _audioPlayer.stop();
      if (!mounted) return;
      await _audioPlayer.play(
        path.startsWith('audio/') ? AssetSource(path) : DeviceFileSource(path),
      );
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
      final prefs = _prefs ?? await SettingsRecord.load('settings_');
      final imported = [
        track,
        ..._musicQueue.where((entry) => !entry['path']!.startsWith('audio/')),
      ];
      if (!await prefs.update({
        'settings_imported_tracks': imported.map(jsonEncode).toList(),
        'settings_music': true,
        'settings_current_track': saved.path,
      })) {
        throw StateError('Could not save music library');
      }
      if (!mounted) return;
      _updateAudio(() {
        _musicQueue.insert(0, track);
        _currentTrackIndex = 0;
        _musicOn = true;
      });
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
          ? Center(
              child: _loadError == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_loadError!),
                        TextButton(
                          onPressed: _loadPreferences,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
            )
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

  String _formatDuration(Duration value) =>
      '${value.inMinutes}:${(value.inSeconds % 60).toString().padLeft(2, '0')}';

  Widget _sheetBody(
    BuildContext ctx, {
    required String title,
    required List<Widget> children,
  }) => SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              ...children,
            ],
          ),
        ),
      ),
    ),
  );

  Widget _doneButton(
    BuildContext ctx,
    StateSetter update,
    Map<String, dynamic> Function() patch,
  ) => FilledButton(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 54),
      backgroundColor: const Color(0xFF0066FF),
      foregroundColor: Colors.white,
    ),
    onPressed: _savingPreferences
        ? null
        : () async {
            final pending = _savePreferences(patch());
            update(() {});
            final saved = await pending;
            if (!ctx.mounted) return;
            if (saved) {
              if (!_musicOn && _isPlaying) {
                unawaited(_audioPlayer.pause().catchError((Object _) {}));
              }
              Navigator.of(ctx).pop();
            } else {
              update(() {});
            }
          },
    child: Text(_savingPreferences ? 'Saving…' : 'Done'),
  );

  void _showMusicModal(BuildContext context) {
    var localMusicOn = _musicOn;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => ValueListenableBuilder<int>(
        valueListenable: _audioRevision,
        builder: (_, revision, child) => StatefulBuilder(
          builder: (ctx, update) => _sheetBody(
            ctx,
            title: 'Music',
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Play music during your workout'),
                value: localMusicOn,
                onChanged: (value) => update(() => localMusicOn = value),
              ),
              if (localMusicOn) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Image.asset(
                    _musicQueue[_currentTrackIndex]['image']!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                  title: Text(_musicQueue[_currentTrackIndex]['title']!),
                  subtitle: Text(_musicQueue[_currentTrackIndex]['subtitle']!),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  children: [
                    IconButton(
                      tooltip: 'Playing queue',
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _showMusicQueueModal(context);
                      },
                      icon: const Icon(Icons.format_list_bulleted_rounded),
                    ),
                    IconButton(
                      tooltip: 'Previous track',
                      onPressed: _playPrevious,
                      icon: const Icon(Icons.skip_previous_rounded),
                    ),
                    IconButton(
                      tooltip: _isPlaying ? 'Pause music' : 'Play music',
                      onPressed: _playPause,
                      icon: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Next track',
                      onPressed: _playNext,
                      icon: const Icon(Icons.skip_next_rounded),
                    ),
                  ],
                ),
                Slider(
                  label: _formatDuration(_audioPosition),
                  semanticFormatterCallback: (value) =>
                      '${_formatDuration(Duration(milliseconds: value.round()))} of ${_formatDuration(_audioDuration)}',
                  value: _audioPosition.inMilliseconds.toDouble().clamp(
                    0,
                    _audioDuration.inMilliseconds > 0
                        ? _audioDuration.inMilliseconds.toDouble()
                        : 1,
                  ),
                  max: _audioDuration.inMilliseconds > 0
                      ? _audioDuration.inMilliseconds.toDouble()
                      : 1,
                  onChanged: (value) =>
                      _audioPlayer.seek(Duration(milliseconds: value.round())),
                ),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_audioPosition)),
                    Text(_formatDuration(_audioDuration)),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _importingAudio ? null : _pickDeviceAudio,
                  icon: const Icon(Icons.library_music_rounded),
                  label: Text(_importingAudio ? 'Loading...' : 'Import music'),
                ),
              ],
              const SizedBox(height: 16),
              _doneButton(ctx, update, () => {'settings_music': localMusicOn}),
            ],
          ),
        ),
      ),
    );
  }

  // ── Music Queue Modal ──────────────────────────────────────────────────────
  void _showMusicQueueModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
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
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Playing Queue',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    AppAction(
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
    return AppAction(
      selected: isActive,
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

  // Timer and sound sheets use natural content heights and a scrollable viewport.
  void _showRestTimerModal(BuildContext context) {
    var useDefault = _restTimerMode == 'Default';
    var enabled = _restTimerMode != 'Off';
    var seconds = _customRestSeconds;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => _sheetBody(
          ctx,
          title: 'Rest timer',
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Default'),
                  selected: useDefault,
                  onSelected: (_) => update(() => useDefault = true),
                ),
                ChoiceChip(
                  label: const Text('Custom'),
                  selected: !useDefault,
                  onSelected: (_) => update(() => useDefault = false),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (useDefault) ...[
              const Icon(
                Icons.local_cafe_rounded,
                size: 64,
                color: Color(0xFF0066FF),
              ),
              const Text(
                'Smart Rest',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              const Text(
                'Follow the coach-recommended intervals for optimal recovery.',
                textAlign: TextAlign.center,
              ),
            ] else ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable rest'),
                value: enabled,
                onChanged: (value) => update(() => enabled = value),
              ),
              if (enabled)
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Shorter rest',
                      onPressed: seconds <= 0
                          ? null
                          : () => update(
                              () => seconds = (seconds - 5).clamp(0, 600),
                            ),
                      icon: const Icon(Icons.remove),
                    ),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        '$seconds seconds',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Longer rest',
                      onPressed: seconds >= 600
                          ? null
                          : () => update(
                              () => seconds = (seconds + 5).clamp(0, 600),
                            ),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
            ],
            const SizedBox(height: 24),
            _doneButton(
              ctx,
              update,
              () => {
                'settings_rest_mode': useDefault
                    ? 'Default'
                    : enabled
                    ? 'Custom'
                    : 'Off',
                'settings_rest_seconds': seconds,
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPrepTimerModal(BuildContext context) {
    var seconds = _prepSeconds;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => _sheetBody(
          ctx,
          title: 'Prep timer',
          children: [
            const Text('Preparation time before your workout'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in [
                  0,
                  5,
                  10,
                  15,
                  20,
                  25,
                  30,
                  35,
                  40,
                  45,
                  50,
                  55,
                  60,
                ])
                  ChoiceChip(
                    label: Text(value == 0 ? 'Off' : '$value secs'),
                    selected: seconds == value,
                    onSelected: (_) => update(() => seconds = value),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _doneButton(ctx, update, () => {'settings_prep': seconds}),
          ],
        ),
      ),
    );
  }

  void _showSoundOptionsModal(BuildContext context) {
    var mute = _mute;
    var effects = _soundEffect;
    var volume = _effectVol;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => _sheetBody(
          ctx,
          title: 'Sound options',
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mute'),
              value: mute,
              onChanged: (value) => update(() => mute = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Voice guide (coming soon)'),
              value: _voiceGuide,
              onChanged: null,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Coach tips (coming soon)'),
              value: _coachTips,
              onChanged: null,
            ),
            const Text('Voice volume (coming soon)'),
            Slider(
              value: _voiceVol,
              onChanged: null,
              semanticFormatterCallback: (value) =>
                  'Voice volume ${(value * 100).round()} percent',
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Music audio'),
              value: effects,
              onChanged: mute ? null : (value) => update(() => effects = value),
            ),
            const Text('Music audio volume'),
            Slider(
              value: volume,
              label: '${(volume * 100).round()}%',
              semanticFormatterCallback: (value) =>
                  'Music audio volume ${(value * 100).round()} percent',
              onChanged: mute || !effects
                  ? null
                  : (value) => update(() => volume = value),
            ),
            const SizedBox(height: 24),
            _doneButton(
              ctx,
              update,
              () => {
                'settings_mute': mute,
                'settings_effect': effects,
                'settings_effect_volume': volume,
              },
            ),
          ],
        ),
      ),
    );
  }
}
