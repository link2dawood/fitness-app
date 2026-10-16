import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/exercise.dart';
import '../../widgets/exercises/exercise_avatar.dart';

Future<List<ExerciseDefinition>?> pickExercises(BuildContext context) =>
    showModalBottomSheet<List<ExerciseDefinition>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => const _ExercisePicker(),
    );

Future<void> showExercisePreview(
  BuildContext context,
  ExerciseDefinition exercise,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  backgroundColor: Colors.white,
  builder: (ctx) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            exercise.name,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 280,
            height: 280,
            child: ExerciseAvatar(exercise: exercise),
          ),
          const SizedBox(height: 16),
          Text(
            '${exercise.area.label} • ${exercise.timed ? '${exercise.target} seconds' : '${exercise.target} reps'}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            exercise.description,
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    ),
  ),
);

class _ExercisePicker extends StatefulWidget {
  const _ExercisePicker();
  @override
  State<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<_ExercisePicker> {
  final _search = TextEditingController();
  final _selected = <String>{};
  ExerciseArea? _area;
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final filtered = exerciseCatalog
        .where(
          (exercise) =>
              (_area == null || exercise.area == _area) &&
              ('${exercise.name} ${exercise.area.label}'.toLowerCase().contains(
                query,
              )),
        )
        .toList();
    final recommended = filtered
        .where((exercise) => exercise.recommended)
        .toList();
    final others = filtered.where((exercise) => !exercise.recommended).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final rows = <Object>[];
    if (recommended.isNotEmpty) {
      rows.add('Recommended');
      rows.addAll(recommended);
    }
    String? last;
    for (final exercise in others) {
      final letter = exercise.name[0].toUpperCase();
      if (last != letter) {
        rows.add(letter);
        last = letter;
      }
      rows.add(exercise);
    }
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .94,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Exercises',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close exercise picker',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.cancel, color: Colors.grey),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: PopupMenuButton<String>(
                  tooltip: 'Filter body area',
                  onSelected: (value) => setState(
                    () => _area = value == 'all'
                        ? null
                        : ExerciseArea.values.firstWhere(
                            (area) => area.name == value,
                          ),
                  ),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'all', child: Text('All Areas')),
                    for (final area in ExerciseArea.values)
                      PopupMenuItem(value: area.name, child: Text(area.label)),
                  ],
                  child: Chip(
                    avatar: const Icon(Icons.filter_alt, size: 18),
                    label: Text(
                      '${_area?.label ?? 'All Areas'} (${filtered.length})',
                    ),
                    side: BorderSide.none,
                    backgroundColor: AppColors.surface,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search exercises',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () => setState(_search.clear),
                          icon: const Icon(Icons.close),
                        ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: rows.isEmpty
                    ? const Center(
                        child: Text('No exercises match your search.'),
                      )
                    : ListView.builder(
                        itemCount: rows.length,
                        itemBuilder: (context, index) {
                          final row = rows[index];
                          if (row is String) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 8,
                              ),
                              child: Text(
                                row,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          }
                          final exercise = row as ExerciseDefinition;
                          void toggle() => setState(() {
                            if (!_selected.add(exercise.id)) {
                              _selected.remove(exercise.id);
                            }
                          });
                          return ListTile(
                            key: ValueKey(exercise.id),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 5,
                            ),
                            leading: GestureDetector(
                              onTap: () =>
                                  showExercisePreview(context, exercise),
                              child: SizedBox(
                                width: 58,
                                height: 64,
                                child: ExerciseAvatar(exercise: exercise),
                              ),
                            ),
                            title: Text(
                              exercise.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              exercise.targetLabel(),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            onTap: toggle,
                            onLongPress: () =>
                                showExercisePreview(context, exercise),
                            trailing: Checkbox(
                              value: _selected.contains(exercise.id),
                              activeColor: AppColors.primary,
                              onChanged: (_) => toggle(),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                  onPressed: () => Navigator.of(context).pop(
                    _selected.isEmpty
                        ? null
                        : exerciseCatalog
                              .where(
                                (exercise) => _selected.contains(exercise.id),
                              )
                              .toList(),
                  ),
                  child: Text(
                    _selected.isEmpty
                        ? 'Close'
                        : 'Add ${_selected.length} exercise${_selected.length == 1 ? '' : 's'}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
