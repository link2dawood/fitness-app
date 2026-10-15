import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/settings/reminder_repository.dart';

class ReminderView extends StatefulWidget {
  const ReminderView({super.key});
  @override
  State<ReminderView> createState() => _ReminderViewState();
}

class _ReminderViewState extends State<ReminderView> {
  static const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final repository = ReminderRepository();
  List<WorkoutReminder> _reminders = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final reminders = await repository.load();
      if (mounted) {
        setState(() {
          _reminders = reminders;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load reminders. Please reopen this page.';
        });
      }
    }
  }

  Future<void> _save(List<WorkoutReminder> reminders) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await repository.save(reminders);
      if (mounted) setState(() => _reminders = reminders);
    } catch (error) {
      if (!mounted) return;
      final message =
          error is PlatformException && error.code == 'notifications_denied'
          ? 'Allow notifications in Android settings to enable workout reminders.'
          : 'Could not save reminders on this device. Please try again.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _edit([WorkoutReminder? reminder]) async {
    var time = TimeOfDay(
      hour: reminder?.hour ?? 20,
      minute: reminder?.minute ?? 0,
    );
    final days = {...?reminder?.days};
    if (reminder == null) days.addAll([1, 2, 3, 4, 5, 6, 7]);
    final save = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder == null ? 'Add reminder' : 'Edit reminder',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _time(time.hour, time.minute),
                      style: const TextStyle(fontSize: 32),
                    ),
                    trailing: const Icon(Icons.schedule),
                    onTap: () async {
                      final selected = await showTimePicker(
                        context: ctx,
                        initialTime: time,
                      );
                      if (ctx.mounted && selected != null) {
                        update(() => time = selected);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Repeat',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (var day = 1; day <= 7; day++)
                        FilterChip(
                          label: Text(dayNames[day - 1]),
                          selected: days.contains(day),
                          onSelected: (selected) => update(() {
                            if (selected) {
                              days.add(day);
                            } else {
                              days.remove(day);
                            }
                          }),
                        ),
                    ],
                  ),
                  if (days.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Choose at least one repeat day.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24),
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
                          onPressed: days.isEmpty
                              ? null
                              : () => Navigator.of(ctx).pop(true),
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
      ),
    );
    if (!mounted || save != true) return;
    var id = (DateTime.now().millisecondsSinceEpoch ~/ 1000) % 2147483647;
    while (id == 0 || _reminders.any((entry) => entry.id == id)) {
      id = (id + 1) % 2147483647;
    }
    final updated = WorkoutReminder(
      id: reminder?.id ?? id,
      hour: time.hour,
      minute: time.minute,
      days: days.toList()..sort(),
      enabled: reminder?.enabled ?? true,
    );
    await _save(
      reminder == null
          ? [..._reminders, updated]
          : [
              for (final entry in _reminders)
                entry.id == reminder.id ? updated : entry,
            ],
    );
  }

  String _time(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: const Text(
        'Reminder',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
      ),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: SizedBox(
      width: 68,
      height: 68,
      child: FloatingActionButton(
        tooltip: 'Add reminder',
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFF064BFF),
        foregroundColor: Colors.white,
        onPressed: _loading || _saving || _error != null ? null : () => _edit(),
        child: const Icon(Icons.add, size: 34),
      ),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(child: Text(_error!))
        : _reminders.isEmpty
        ? const Center(
            child: Text(
              'Tap + to add a workout reminder.',
              style: TextStyle(color: Colors.grey),
            ),
          )
        : ListView(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 110),
            children: [
              for (final reminder in _reminders)
                Card(
                  color: Colors.white,
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _saving ? null : () => _edit(reminder),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    _time(reminder.hour, reminder.minute),
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                ),
                              ),
                            ),
                            Switch(
                              value: reminder.enabled,
                              activeTrackColor: const Color(0xFF064BFF),
                              onChanged: _saving
                                  ? null
                                  : (value) => _save([
                                      for (final entry in _reminders)
                                        entry.id == reminder.id
                                            ? entry.copyWith(enabled: value)
                                            : entry,
                                    ]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _saving ? null : () => _edit(reminder),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Repeat',
                                      style: TextStyle(fontSize: 22),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      reminder.days
                                          .map((day) => dayNames[day - 1])
                                          .join(', '),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete reminder',
                              onPressed: _saving
                                  ? null
                                  : () => _save(
                                      _reminders
                                          .where(
                                            (entry) => entry.id != reminder.id,
                                          )
                                          .toList(),
                                    ),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
  );
}
