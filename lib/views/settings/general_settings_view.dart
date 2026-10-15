import 'package:flutter/material.dart';

import '../../core/settings/general_settings.dart';
import '../../core/routes/app_routes.dart';

class GeneralSettingsView extends StatefulWidget {
  const GeneralSettingsView({super.key});
  @override
  State<GeneralSettingsView> createState() => _GeneralSettingsViewState();
}

class _GeneralSettingsViewState extends State<GeneralSettingsView> {
  final settings = GeneralSettings.instance;
  bool _busy = false;

  Future<void> _perform(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This action could not be completed on this device. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _reminder() {
    Navigator.of(context).pushNamed(AppRoutes.reminders);
  }

  Future<void> _units() async {
    var weight = settings.weightImperial;
    var height = settings.heightImperial;
    final save = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Metric & Imperial Units',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 24),
                const Text('Weight'),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('kg')),
                    ButtonSegment(value: true, label: Text('lbs')),
                  ],
                  selected: {weight},
                  onSelectionChanged: (value) =>
                      update(() => weight = value.single),
                ),
                const SizedBox(height: 24),
                const Text('Height'),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('cm')),
                    ButtonSegment(value: true, label: Text('ft / in')),
                  ],
                  selected: {height},
                  onSelectionChanged: (value) =>
                      update(() => height = value.single),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || save != true) return;
    await _perform(() => settings.setUnits(weight: weight, height: height));
  }

  void _privacy() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(title: const Text('Privacy Policy')),
          body: const SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy policy not published',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 16),
                Text(
                  'An official privacy policy has not been provided for this app yet. It will be available here when published.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text(
            'General Settings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _row(
              Icons.alarm_outlined,
              'Remind me to work out every day',
              _reminder,
            ),
            _row(Icons.straighten_outlined, 'Metric & Imperial Units', _units),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 14,
              ),
              secondary: const Icon(
                Icons.stay_current_portrait,
                color: Color(0xFF9A9D99),
                size: 28,
              ),
              title: const Text(
                'Keep the screen on',
                style: TextStyle(fontSize: 17),
              ),
              value: settings.keepScreenOn,
              activeTrackColor: const Color(0xFF0066FF),
              onChanged: _busy
                  ? null
                  : (value) => _perform(() => settings.setKeepScreenOn(value)),
            ),
            const Divider(height: 1, color: Color(0xFFFAFAFA)),
            _row(Icons.visibility_outlined, 'Privacy Policy', _privacy),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String title, VoidCallback onTap) => Column(
    children: [
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        leading: Icon(icon, color: const Color(0xFF9A9D99), size: 28),
        title: Text(title, style: const TextStyle(fontSize: 17)),
        onTap: _busy ? null : onTap,
      ),
      const Divider(height: 1, color: Color(0xFFFAFAFA)),
    ],
  );
}
