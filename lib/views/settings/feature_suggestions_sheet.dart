import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';

Future<void> showFeatureSuggestions(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FeatureSuggestionsSheet(),
    );

class FeatureSuggestionsSheet extends StatefulWidget {
  const FeatureSuggestionsSheet({super.key});
  @override
  State<FeatureSuggestionsSheet> createState() =>
      _FeatureSuggestionsSheetState();
}

class _FeatureSuggestionsSheetState extends State<FeatureSuggestionsSheet> {
  static const options = [
    'Update workout & plan',
    'Customize workout',
    'Auto counting',
    'Better voice quality',
    'Extend the 7*4 plan',
    'Search workouts',
    'Others',
  ];
  final _selected = <String>{};
  final _details = TextEditingController();
  bool _saving = false;
  bool _submitted = false;
  String? _error;

  bool get _canSubmit =>
      _selected.isNotEmpty &&
      (!_selected.contains('Others') || _details.text.trim().isNotEmpty) &&
      !_saving;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final requests = [...?prefs.getStringList('feature_requests')];
      requests.add(
        jsonEncode({
          'features': options.where(_selected.contains).toList(),
          'details': _selected.contains('Others') ? _details.text.trim() : '',
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        }),
      );
      if (!await prefs.setStringList('feature_requests', requests)) {
        throw StateError('Save failed');
      }
      if (mounted) setState(() => _submitted = true);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not save your request. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitted = _submitted;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton.filled(
                    tooltip: 'Close',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFD1D1D1),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
                Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: Icon(
                    submitted
                        ? Icons.inventory_2_outlined
                        : Icons.edit_document,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  submitted
                      ? 'Feature request saved!'
                      : "What other features you'd\nlike to add?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  submitted
                      ? 'Thank you for sharing your ideas.\nYour request is saved on this device.'
                      : "Let us know what you'd like to see next!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF999999),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 32),
                if (!submitted) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final option in options)
                          FilterChip(
                            label: Text(
                              option,
                              style: const TextStyle(fontSize: 16),
                            ),
                            selected: _selected.contains(option),
                            showCheckmark: false,
                            backgroundColor: AppColors.surfaceLight,
                            selectedColor: AppColors.primary.withValues(
                              alpha: 0.12,
                            ),
                            side: BorderSide(
                              color: _selected.contains(option)
                                  ? AppColors.primary
                                  : Colors.transparent,
                            ),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            onSelected: _saving
                                ? null
                                : (selected) => setState(() {
                                    if (selected) {
                                      _selected.add(option);
                                    } else {
                                      _selected.remove(option);
                                    }
                                    _error = null;
                                  }),
                          ),
                      ],
                    ),
                  ),
                  if (_selected.contains('Others')) ...[
                    const SizedBox(height: 20),
                    TextField(
                      controller: _details,
                      enabled: !_saving,
                      maxLength: 1000,
                      minLines: 2,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Your feature idea',
                        hintText: 'Tell us what you would like to add',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  const Text(
                    'Requests are saved on this device.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                  ),
                ],
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: submitted || _canSubmit
                          ? AppColors.primary
                          : AppColors.surfaceLight,
                    ),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        foregroundColor: AppColors.onPrimary,
                        disabledForegroundColor: AppColors.textSecondary,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(0, 60),
                        textStyle: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onPressed: submitted
                          ? () => Navigator.of(context).pop()
                          : _canSubmit
                          ? _submit
                          : null,
                      child: Text(
                        submitted
                            ? 'Done'
                            : _saving
                            ? 'Saving...'
                            : 'Submit',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
