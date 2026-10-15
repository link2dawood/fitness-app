import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/user_profile.dart';
import '../../data/repositories/onboarding_repository.dart';

class GenderSettingsView extends StatefulWidget {
  const GenderSettingsView({super.key});

  @override
  State<GenderSettingsView> createState() => _GenderSettingsViewState();
}

class _GenderSettingsViewState extends State<GenderSettingsView> {
  UserProfile? _profile;
  Gender? _selected;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await context.read<OnboardingRepository>().loadProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _selected = profile?.gender;
        if (profile == null) {
          _error = 'Complete your profile before editing gender.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not load your profile. Please try again.');
    }
  }

  Future<void> _save() async {
    if (_profile == null || _selected == null || _saving) return;
    setState(() => _saving = true);
    try {
      await context.read<OnboardingRepository>().saveProfile(
        _profile!.copyWith(gender: _selected),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save gender. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gender')),
      body: _error != null
          ? Center(child: Text(_error!))
          : _profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                for (final gender in Gender.values)
                  ListTile(
                    title: Text(gender.label),
                    selected: _selected == gender,
                    trailing: _selected == gender
                        ? const Icon(Icons.check)
                        : null,
                    onTap: _saving
                        ? null
                        : () => setState(() => _selected = gender),
                  ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving || _selected == null ? null : _save,
                  child: Text(_saving ? 'Saving...' : 'Save'),
                ),
              ],
            ),
    );
  }
}
