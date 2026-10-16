import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/custom_workout_repository.dart';
import '../../widgets/exercises/exercise_avatar.dart';
import 'exercise_picker.dart';

Future<(String, String)?> configureWorkout(
  BuildContext context, {
  String name = '',
  String difficulty = 'Beginner',
}) async {
  final controller = TextEditingController(text: name);
  final form = GlobalKey<FormState>();
  var level = difficulty;
  final result = await showModalBottomSheet<(String, String)>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, update) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? 'New Custom Workout' : 'Workout details',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controller,
                    maxLength: 60,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Workout name',
                      hintText: 'e.g. Morning Workout',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a workout name.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Difficulty',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final item in [
                        'Beginner',
                        'Intermediate',
                        'Advanced',
                      ])
                        ChoiceChip(
                          label: Text(item),
                          selected: item == level,
                          onSelected: (_) => update(() => level = item),
                          selectedColor: AppColors.primary.withValues(
                            alpha: .2,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (form.currentState!.validate()) {
                          Navigator.of(
                            ctx,
                          ).pop((controller.text.trim(), level));
                        }
                      },
                      child: Text(
                        name.isEmpty ? 'Choose exercises' : 'Update details',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  // Wait until the modal's closing transition has stopped using its text field.
  await Future<void>.delayed(const Duration(milliseconds: 350));
  controller.dispose();
  return result;
}

class WorkoutEditorPage extends StatefulWidget {
  const WorkoutEditorPage({
    super.key,
    required this.workout,
    this.isNew = false,
  });
  final CustomWorkout workout;
  final bool isNew;
  @override
  State<WorkoutEditorPage> createState() => _WorkoutEditorPageState();
}

class _WorkoutEditorPageState extends State<WorkoutEditorPage> {
  final repository = CustomWorkoutRepository();
  late List<WorkoutEntry> _entries;
  late String _name, _difficulty;
  bool _dirty = false, _saving = false, _allowPop = false;
  int _serial = 0;
  @override
  void initState() {
    super.initState();
    _entries = [...widget.workout.entries];
    _name = widget.workout.name;
    _difficulty = widget.workout.difficulty;
  }

  Future<void> _add() async {
    final selected = await pickExercises(context);
    if (!mounted || selected == null || selected.isEmpty) return;
    final rest = await repository.defaultRest();
    if (!mounted) return;
    setState(() {
      for (final exercise in selected) {
        _entries.add(
          WorkoutEntry(
            id: '${DateTime.now().microsecondsSinceEpoch}_${_serial++}',
            exerciseId: exercise.id,
            target: exercise.target,
            restSeconds: rest,
          ),
        );
      }
      _dirty = true;
    });
  }

  Future<void> _details() async {
    final result = await configureWorkout(
      context,
      name: _name,
      difficulty: _difficulty,
    );
    if (!mounted || result == null) return;
    setState(() {
      _name = result.$1;
      _difficulty = result.$2;
      _dirty = true;
    });
  }

  Future<void> _editEntry(WorkoutEntry entry) async {
    final target = TextEditingController(text: '${entry.target}');
    final rest = TextEditingController(text: '${entry.restSeconds}');
    final form = GlobalKey<FormState>();
    final max = entry.exercise.timed ? 3600 : 999;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(entry.exercise.name),
        content: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: target,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: entry.exercise.timed
                        ? 'Duration (seconds)'
                        : 'Repetitions',
                  ),
                  validator: (value) {
                    final number = int.tryParse(value ?? '');
                    return number == null || number < 1 || number > max
                        ? 'Enter 1–$max.'
                        : null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: rest,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Rest after exercise (seconds)',
                  ),
                  validator: (value) {
                    final number = int.tryParse(value ?? '');
                    return number == null || number < 0 || number > 600
                        ? 'Enter 0–600.'
                        : null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.of(ctx).pop(true);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (mounted && result == true) {
      setState(() {
        _entries = [
          for (final item in _entries)
            item.id == entry.id
                ? item.copyWith(
                    target: int.parse(target.text),
                    restSeconds: int.parse(rest.text),
                  )
                : item,
        ];
        _dirty = true;
      });
    }
    await Future<void>.delayed(const Duration(milliseconds: 350));
    target.dispose();
    rest.dispose();
  }

  Future<void> _save() async {
    if (_saving || _entries.isEmpty) return;
    setState(() => _saving = true);
    final workout = CustomWorkout(
      id: widget.workout.id,
      name: _name,
      difficulty: _difficulty,
      entries: [..._entries],
      createdAt: widget.workout.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    try {
      await repository.save(workout);
      if (!mounted) return;
      setState(() {
        _allowPop = true;
        _dirty = false;
      });
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) Navigator.of(context).pop(workout);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not save your workout. Your edits are still here.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _discard() async {
    if (_saving) return;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your unsaved workout changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (!mounted || discard != true) return;
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _allowPop || (!_dirty && !_saving),
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _discard();
    },
    child: Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(_name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Edit workout details',
            onPressed: _saving ? null : _details,
            icon: const Icon(Icons.edit_outlined),
          ),
          TextButton(
            onPressed: _entries.isEmpty || _saving ? null : _save,
            child: Text(_saving ? 'Saving...' : 'Save'),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _saving ? null : _add,
            icon: const Icon(Icons.add),
            label: const Text('Add Exercises'),
          ),
        ),
      ),
      body: _entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.fitness_center,
                      size: 64,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Add your first exercise',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose from 11 original animated demonstrations.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ReorderableListView.builder(
              buildDefaultDragHandles: false,
              padding: const EdgeInsets.all(12),
              itemCount: _entries.length,
              onReorderItem: (oldIndex, newIndex) {
                if (_saving) return;
                setState(() {
                  final entry = _entries.removeAt(oldIndex);
                  _entries.insert(newIndex, entry);
                  _dirty = true;
                });
              },
              header: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                child: Text(
                  '$_difficulty • ${_entries.length} exercises',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return Card(
                  key: ValueKey(entry.id),
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              showExercisePreview(context, entry.exercise),
                          child: SizedBox(
                            width: 70,
                            height: 88,
                            child: ExerciseAvatar(exercise: entry.exercise),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _saving ? null : () => _editEntry(entry),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.exercise.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${entry.exercise.targetLabel(entry.target)} • Rest ${entry.restSeconds}s',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Tap to edit',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove ${entry.exercise.name}',
                          onPressed: _saving
                              ? null
                              : () => setState(() {
                                  _entries.removeAt(index);
                                  _dirty = true;
                                }),
                          icon: const Icon(Icons.close, size: 20),
                        ),
                        ReorderableDragStartListener(
                          index: index,
                          enabled: !_saving,
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.drag_handle, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    ),
  );
}
