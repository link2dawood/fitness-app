import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/exercise.dart';
import '../../widgets/exercises/exercise_focus_illustration.dart';

/// OR within a category; AND between categories. Empty sets mean any value.
class ExerciseFilters {
  ExerciseFilters({
    Set<ExerciseFocus>? focus,
    Set<ExerciseDifficulty>? difficulty,
    Set<ExerciseType>? type,
    Set<ExerciseEquipment>? equipment,
  }) : focus = {...?focus},
       difficulty = {...?difficulty},
       type = {...?type},
       equipment = {...?equipment};

  final Set<ExerciseFocus> focus;
  final Set<ExerciseDifficulty> difficulty;
  final Set<ExerciseType> type;
  final Set<ExerciseEquipment> equipment;
  int get count =>
      focus.length + difficulty.length + type.length + equipment.length;
  ExerciseFilters copy() => ExerciseFilters(
    focus: focus,
    difficulty: difficulty,
    type: type,
    equipment: equipment,
  );

  bool matches(ExerciseDefinition exercise) =>
      (focus.isEmpty || exercise.focus.any(focus.contains)) &&
      (difficulty.isEmpty || difficulty.contains(exercise.difficulty)) &&
      (type.isEmpty || type.contains(exercise.type)) &&
      (equipment.isEmpty || exercise.equipment.any(equipment.contains));
}

Future<ExerciseFilters?> showExerciseFilters(
  BuildContext context,
  ExerciseFilters current, {
  String query = '',
  ExerciseArea? area,
}) => showModalBottomSheet<ExerciseFilters>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.white,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  ),
  builder: (_) => _FilterPanel(initial: current, query: query, area: area),
);

class _FilterPanel extends StatefulWidget {
  const _FilterPanel({required this.initial, required this.query, this.area});
  final ExerciseFilters initial;
  final String query;
  final ExerciseArea? area;
  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  late ExerciseFilters draft = widget.initial.copy();

  void toggle<T>(Set<T> selected, T value) => setState(() {
    if (!selected.add(value)) selected.remove(value);
  });

  Widget choices<T>(
    String title,
    List<T> values,
    Set<T> selected,
    String Function(T) label,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 24),
      Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          for (final value in values)
            FilterChip(
              label: Text(label(value)),
              selected: selected.contains(value),
              selectedColor: AppColors.primary.withValues(alpha: .15),
              checkmarkColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: selected.contains(value)
                    ? AppColors.primary
                    : Colors.transparent,
              ),
              onSelected: (_) => toggle(selected, value),
            ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final count = exerciseCatalog
        .where(
          (exercise) =>
              draft.matches(exercise) &&
              (widget.area == null || widget.area == exercise.area) &&
              '${exercise.name} ${exercise.area.label}'.toLowerCase().contains(
                widget.query,
              ),
        )
        .length;
    final chips = <Widget>[
      for (final value in draft.focus)
        InputChip(
          backgroundColor: AppColors.primary.withValues(alpha: .12),
          side: BorderSide.none,
          deleteIcon: const Icon(Icons.cancel),
          label: Text(value.label),
          onDeleted: () => toggle(draft.focus, value),
        ),
      for (final value in draft.difficulty)
        InputChip(
          backgroundColor: AppColors.primary.withValues(alpha: .12),
          side: BorderSide.none,
          deleteIcon: const Icon(Icons.cancel),
          label: Text(value.label),
          onDeleted: () => toggle(draft.difficulty, value),
        ),
      for (final value in draft.type)
        InputChip(
          backgroundColor: AppColors.primary.withValues(alpha: .12),
          side: BorderSide.none,
          deleteIcon: const Icon(Icons.cancel),
          label: Text(value.label),
          onDeleted: () => toggle(draft.type, value),
        ),
      for (final value in draft.equipment)
        InputChip(
          backgroundColor: AppColors.primary.withValues(alpha: .12),
          side: BorderSide.none,
          deleteIcon: const Icon(Icons.cancel),
          label: Text(value.label),
          onDeleted: () => toggle(draft.equipment, value),
        ),
    ];
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .88,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      draft.count == 0 ? 'All Exercises' : 'Filtered',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Clear all filters',
                    onPressed: () => setState(() => draft = ExerciseFilters()),
                    icon: const Icon(Icons.delete_outline),
                  ),
                  Text(
                    '$count exercises',
                    key: const ValueKey('filter-result-count'),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (chips.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: SingleChildScrollView(
                    child: Wrap(spacing: 8, children: chips),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Focus Area',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) => Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final value in ExerciseFocus.values)
                              SizedBox(
                                width: (constraints.maxWidth - 10) / 2,
                                child: Semantics(
                                  selected: draft.focus.contains(value),
                                  child: Material(
                                    color: draft.focus.contains(value)
                                        ? AppColors.primary.withValues(
                                            alpha: .12,
                                          )
                                        : AppColors.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      side: BorderSide(
                                        color: draft.focus.contains(value)
                                            ? AppColors.primary
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: () => toggle(draft.focus, value),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 14,
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 38,
                                              height: 48,
                                              child: ExerciseFocusIllustration(
                                                focus: value,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                value.label,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
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
                          ],
                        ),
                      ),
                      choices(
                        'Difficulty',
                        ExerciseDifficulty.values,
                        draft.difficulty,
                        (v) => v.label,
                      ),
                      choices(
                        'Type',
                        ExerciseType.values,
                        draft.type,
                        (v) => v.label,
                      ),
                      choices(
                        'Equipment',
                        ExerciseEquipment.values,
                        draft.equipment,
                        (v) => v.label,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 54),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 54),
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                      ),
                      onPressed: () => Navigator.pop(context, draft),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
