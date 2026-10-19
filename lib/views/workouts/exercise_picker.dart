import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/exercise.dart';
import 'exercise_filters.dart';
export 'exercise_detail.dart' show showExercisePreview;
import 'exercise_detail.dart';
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

class _ExercisePicker extends StatefulWidget {
  const _ExercisePicker();
  @override
  State<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<_ExercisePicker> {
  final _search = TextEditingController();
  final _selected = <String>{};
  ExerciseFilters _filters = ExerciseFilters();
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
              _filters.matches(exercise) &&
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_filters.count == 0 ? 'All Exercises' : 'Filtered'} (${filtered.length})',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final result = await showExerciseFilters(
                        context,
                        _filters,
                        query: query,
                      );
                      if (result != null && mounted) {
                        setState(() => _filters = result);
                      }
                    },
                    icon: const Icon(Icons.tune),
                    label: Text(
                      'Filters${_filters.count == 0 ? '' : ' (${_filters.count})'}',
                    ),
                  ),
                ],
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
                        child: Text(
                          'No exercises match. Try changing your search or filters.',
                        ),
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
                            onTap: () => showExercisePreview(context, exercise),
                            onLongPress: () =>
                                showExercisePreview(context, exercise),
                            trailing: Checkbox(
                              key: ValueKey('select_${exercise.id}'),
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
