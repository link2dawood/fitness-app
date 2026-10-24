import 'package:flutter/material.dart';
import '../../data/models/training_calendar.dart';
import '../../viewmodels/home_viewmodel.dart';

Future<void> editTrainingGoal(BuildContext context, HomeViewModel model) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TrainingGoalSheet(
        days: model.profile?.workoutDaysPerWeek ?? 4,
        firstDay: model.profile?.firstDayOfWeek ?? 'SUNDAY',
        onSave: model.updateTrainingPreferences,
      ),
    );

class TrainingGoalSheet extends StatefulWidget {
  const TrainingGoalSheet({
    super.key,
    required this.days,
    required this.firstDay,
    required this.onSave,
  });
  final int days;
  final String firstDay;
  final Future<void> Function(int, String) onSave;
  @override
  State<TrainingGoalSheet> createState() => _TrainingGoalSheetState();
}

class _TrainingGoalSheetState extends State<TrainingGoalSheet> {
  late int days = widget.days;
  late String firstDay = widget.firstDay;
  bool saving = false;
  String? error;
  Future<void> save() async {
    if (saving) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.onSave(days, firstDay);
      if (mounted) {
        setState(() => saving = false);
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          error = 'Could not save your goal. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving,
    child: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Weekly training goal',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            const Text('Workout days per week'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var value = 1; value <= 7; value++)
                  ChoiceChip(
                    label: Text('$value'),
                    selected: days == value,
                    onSelected: saving
                        ? null
                        : (_) => setState(() => days = value),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('First day of the week'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                for (final value in TrainingCalendar.firstDays)
                  ChoiceChip(
                    label: Text(value[0] + value.substring(1).toLowerCase()),
                    selected: firstDay == value,
                    onSelected: saving
                        ? null
                        : (_) => setState(() => firstDay = value),
                  ),
              ],
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                OutlinedButton(
                  onPressed: saving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving ? null : save,
                  child: Text(saving ? 'Saving…' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
