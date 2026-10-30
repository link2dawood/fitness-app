import 'package:flutter/material.dart';
import '../../core/settings/general_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/storage_recovery_view.dart';

/// Mount a usable UI before touching settings storage.
class StartupGate extends StatefulWidget {
  const StartupGate({
    super.key,
    required this.child,
    this.loadSettings,
    this.resetSettings,
  });
  final Widget child;
  final Future<void> Function()? loadSettings, resetSettings;
  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool _loading = true, _failed = false, _busy = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_busy) return;
    _busy = true;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      await (widget.loadSettings ?? GeneralSettings.instance.load)().timeout(
        const Duration(seconds: 10),
      );
    } catch (_) {
      if (mounted) _failed = true;
    } finally {
      _busy = false;
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reset() async {
    await (widget.resetSettings ?? GeneralSettings.instance.resetPreferences)();
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && !_failed) return widget.child;
    final page = _loading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : StorageRecoveryView(
            title: 'Could not load app settings',
            message:
                'Your saved profile and workout records have not been changed. Retry, or reset only general app settings.',
            onRetry: _load,
            onReset: _reset,
            resetLabel: 'Reset app settings',
            resetDescription:
                'Reset units, language preference and screen-on settings? Your profile, workouts, weight history and reminders will be kept.',
          );
    return MaterialApp(
      key: const ValueKey('startup-recovery-app'),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      onGenerateInitialRoutes: (_) => [
        MaterialPageRoute<void>(builder: (_) => page),
      ],
      onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => page),
    );
  }
}
