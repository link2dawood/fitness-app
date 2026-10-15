import 'package:flutter/cupertino.dart';
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
        if (profile == null) {
          _error = 'Complete your profile before editing it.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not load your profile. Please try again.');
    }
  }

  Future<void> _save(UserProfile profile) async {
    setState(() => _saving = true);
    try {
      await context.read<OnboardingRepository>().saveProfile(profile);
      if (!mounted) return;
      setState(() => _profile = profile);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your profile. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _editGender() async {
    var selected = _profile!.gender ?? Gender.male;
    final result = await showModalBottomSheet<Gender>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => _editorSheet(
          title: 'Gender',
          onSave: () => Navigator.of(ctx).pop(selected),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final gender in Gender.values)
                ListTile(
                  title: Text(gender.label),
                  trailing: Icon(
                    selected == gender
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected == gender
                        ? const Color(0xFF0066FF)
                        : Colors.grey,
                  ),
                  onTap: () => update(() => selected = gender),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || result == null) return;
    await _save(_profile!.copyWith(gender: result));
  }

  Future<void> _editBirthDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final minimum = DateTime(1900);
    var selected =
        _profile!.dateOfBirth ?? DateTime(today.year - _profile!.age, 1, 1);
    if (selected.isBefore(minimum)) selected = minimum;
    if (selected.isAfter(today)) selected = today;
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _editorSheet(
        title: 'Date',
        onSave: () => Navigator.of(ctx).pop(selected),
        child: SizedBox(
          height: 240,
          child: CupertinoTheme(
            data: const CupertinoThemeData(
              textTheme: CupertinoTextThemeData(
                dateTimePickerTextStyle: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF20242C),
                ),
              ),
            ),
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              dateOrder: DatePickerDateOrder.mdy,
              initialDateTime: selected,
              minimumDate: minimum,
              maximumDate: today,
              minimumYear: 1900,
              maximumYear: today.year,
              onDateTimeChanged: (date) =>
                  selected = DateTime(date.year, date.month, date.day),
            ),
          ),
        ),
      ),
    );
    if (!mounted || result == null) return;
    await _save(_profile!.copyWith(dateOfBirth: result));
  }

  Widget _editorSheet({
    required String title,
    required Widget child,
    required VoidCallback onSave,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            child,
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5F5),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(0, 56),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      minimumSize: const Size(0, 56),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onPressed: onSave,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF9CA3AF),
        ),
        onTap: _saving ? null : onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final birth = _profile?.dateOfBirth;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Gender',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _error != null
          ? Center(child: Text(_error!))
          : _profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _card(
                  title: 'Gender',
                  value: _profile!.gender?.label ?? 'Not set',
                  onTap: _editGender,
                ),
                _card(
                  title: 'Date of Birth',
                  value: birth == null
                      ? 'Not set'
                      : MaterialLocalizations.of(
                          context,
                        ).formatMediumDate(birth),
                  onTap: _editBirthDate,
                ),
                if (_saving) const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}
