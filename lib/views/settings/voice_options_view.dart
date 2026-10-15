import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/settings/tts_service.dart';
import '../../core/theme/app_colors.dart';

class VoiceOptionsView extends StatefulWidget {
  const VoiceOptionsView({super.key});
  @override
  State<VoiceOptionsView> createState() => _VoiceOptionsViewState();
}

class _VoiceOptionsViewState extends State<VoiceOptionsView>
    with WidgetsBindingObserver {
  final service = TtsService();
  Map<String, dynamic> _state = {};
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    service.action('stop').catchError((Object _) {});
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_busy && !_loading) {
      _load(refresh: true);
    }
  }

  Future<void> _load({bool refresh = false}) async {
    setState(() => _loading = true);
    try {
      final state = await service.state(refresh: refresh);
      if (mounted) {
        setState(() {
          _state = state;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is PlatformException
              ? error.message
              : 'Device TTS is not available.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _action(String method, [dynamic arguments]) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await service.action(method, arguments);
      if (mounted &&
          ![
            'installEngine',
            'installLanguage',
            'openSettings',
            'testVoice',
          ].contains(method)) {
        await _load();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is PlatformException
                  ? error.message ?? 'Could not update voice settings.'
                  : 'This voice action is not available on this device.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _choose({required bool engine}) async {
    final raw = _state[engine ? 'engines' : 'languages'] as List? ?? [];
    final items = raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    if (!engine) items.insert(0, {'id': '', 'label': 'Default'});
    if (items.isEmpty) {
      await _action('installEngine');
      return;
    }
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(engine ? 'Select TTS Engine' : 'Voice language'),
        children: [
          for (final item in items)
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(item['id'] as String),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      _state[engine ? 'engine' : 'language'] == item['id']
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Text(item['label'] as String)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
    if (!mounted || selected == null) return;
    await _action(engine ? 'setEngine' : 'setLanguage', selected);
  }

  Widget _tile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? subtitle,
    Widget? trailing,
    bool nested = false,
  }) => Padding(
    padding: EdgeInsets.only(left: nested ? 50 : 0),
    child: Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          leading: Icon(icon, color: const Color(0xFF999999), size: 28),
          title: Text(title, style: const TextStyle(fontSize: 19)),
          subtitle: subtitle == null
              ? null
              : Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    color: nested
                        ? const Color(0xFF294154)
                        : const Color(0xFF999999),
                  ),
                ),
          trailing: trailing,
          onTap: _busy ? null : onTap,
        ),
        const Divider(height: 1, color: Color(0xFFF0F1F4)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final natural = _state['natural'] == true;
    final available = _state['naturalAvailable'] == true;
    Widget checked(bool selected) => Icon(
      selected ? Icons.check_circle : Icons.radio_button_off,
      color: selected ? AppColors.primary : const Color(0xFF999999),
      size: 30,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Voice Options (TTS)',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFF0F1F4)),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (_busy)
                  const LinearProgressIndicator(color: AppColors.primary),
                _tile(
                  Icons.record_voice_over_outlined,
                  'Natural Voice',
                  () => _action(
                    available ? 'setNatural' : 'installLanguage',
                    available ? true : null,
                  ),
                  subtitle: 'Advanced & more fluid voice',
                  trailing: available
                      ? checked(natural)
                      : const Icon(Icons.download_for_offline, size: 30),
                ),
                _tile(
                  Icons.graphic_eq,
                  'Device TTS Engine',
                  () => _action('setNatural', false),
                  trailing: checked(!natural && _state['engine'] != null),
                ),
                _tile(
                  Icons.surround_sound,
                  'Test Voice',
                  () => _action('testVoice'),
                  nested: true,
                ),
                _tile(
                  Icons.navigation,
                  'Select TTS Engine',
                  () => _choose(engine: true),
                  nested: true,
                  subtitle:
                      _state['engineLabel'] as String? ?? 'No engine available',
                ),
                _tile(
                  Icons.download_for_offline_outlined,
                  'Download TTS Engine',
                  () => _action('installEngine'),
                  nested: true,
                ),
                _tile(
                  Icons.mic,
                  'Voice language',
                  () => _choose(engine: false),
                  nested: true,
                  subtitle: _state['languageLabel'] as String? ?? 'Default',
                ),
                _tile(
                  Icons.file_download_outlined,
                  'Download more TTS language data',
                  () => _action('installLanguage'),
                  nested: true,
                ),
                _tile(
                  Icons.tune,
                  'Device TTS Setting',
                  () => _action('openSettings'),
                  nested: true,
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
