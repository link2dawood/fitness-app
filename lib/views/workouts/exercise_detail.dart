import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_guidance.dart';
import '../../widgets/exercises/challenge_avatar.dart';
import '../../widgets/exercises/exercise_focus_illustration.dart';

Future<void> showExercisePreview(
  BuildContext context,
  ExerciseDefinition exercise,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.white,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  ),
  builder: (_) => ExerciseDetailCard(exercise: exercise),
);

class ExerciseDetailCard extends StatefulWidget {
  const ExerciseDetailCard({
    super.key,
    required this.exercise,
    this.avatar,
    this.footer,
    this.headerAction,
    this.targetControls,
    this.onClose,
    this.accent = AppColors.primary,
  });
  final Widget? avatar, footer, headerAction, targetControls;
  final Color accent;
  final VoidCallback? onClose;
  final ExerciseDefinition exercise;
  @override
  State<ExerciseDetailCard> createState() => _ExerciseDetailCardState();
}

class _ExerciseDetailCardState extends State<ExerciseDetailCard> {
  int view = 0;

  Widget heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(
      text,
      style: TextStyle(
        color: widget.accent,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  Widget paragraph(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: const TextStyle(height: 1.5, fontSize: 15)),
  );

  Widget muscles(ExerciseDefinition exercise) => Wrap(
    spacing: 18,
    runSpacing: 12,
    children: [
      for (final focus in exercise.focus)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 76,
              height: 114,
              child: ExerciseFocusIllustration(focus: focus),
            ),
            const SizedBox(height: 6),
            Text(
              focus.label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final guidance = ExerciseGuidance.forExercise(exercise);
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .92,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (widget.headerAction != null) widget.headerAction!,
                  IconButton(
                    tooltip: 'Close exercise details',
                    onPressed: widget.onClose ?? () => Navigator.pop(context),
                    icon: const Icon(Icons.cancel, color: Colors.grey),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: view == 0
                            ? Center(
                                child: SizedBox(
                                  width: 260,
                                  height: 260,
                                  child:
                                      widget.avatar ??
                                      ChallengeAvatar(exercise: exercise),
                                ),
                              )
                            : view == 1
                            ? Center(child: muscles(exercise))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  paragraph('1. ${guidance.setup}'),
                                  paragraph('2. ${guidance.movement}'),
                                  paragraph(
                                    '3. ${exercise.timed ? 'Continue for ${exercise.target} seconds.' : 'Repeat ${exercise.target} times.'}',
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          for (final (index, label) in [
                            'Animation',
                            'Muscle',
                            'How to do',
                          ].indexed)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: ChoiceChip(
                                  label: Text(label),
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    color: view == index
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                  selected: view == index,
                                  showCheckmark: false,
                                  selectedColor: widget.accent,
                                  onSelected: (_) =>
                                      setState(() => view = index),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            Text(
                              exercise.timed ? 'DURATION' : 'REPEATS',
                              style: TextStyle(
                                color: widget.accent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              exercise.timed
                                  ? '${exercise.target} seconds'
                                  : '×${exercise.target}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.targetControls != null) widget.targetControls!,
                      heading('INSTRUCTIONS'),
                      paragraph(guidance.setup),
                      paragraph(guidance.movement),
                      paragraph(exercise.description),
                      heading('FOCUS AREA'),
                      muscles(exercise),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Chip(label: Text(exercise.difficulty.label)),
                          Chip(label: Text(exercise.type.label)),
                          for (final item in exercise.equipment)
                            Chip(label: Text(item.label)),
                        ],
                      ),
                      heading('COMMON MISTAKES'),
                      for (final (index, mistake) in guidance.mistakes.indexed)
                        paragraph('${index + 1}. $mistake'),
                      heading('BREATHING TIPS'),
                      paragraph(guidance.breathing),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              widget.footer ??
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.accent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: widget.onClose ?? () => Navigator.pop(context),
                      child: const Text('Done'),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
