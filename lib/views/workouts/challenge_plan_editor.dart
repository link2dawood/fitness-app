import 'package:flutter/material.dart';
import '../../data/models/challenge_day.dart';
import '../../data/models/exercise.dart';
import '../../widgets/exercises/challenge_avatar.dart';
import 'exercise_detail.dart';
import '../../widgets/training_feature_cards.dart';

String challengeTime(int seconds) =>
    '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

Future<ExerciseDefinition?> replaceChallengeExercise(BuildContext context) =>
    showModalBottomSheet<ExerciseDefinition>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ReplacementPicker(),
    );

class _ReplacementPicker extends StatefulWidget {
  const _ReplacementPicker();
  @override
  State<_ReplacementPicker> createState() => _ReplacementPickerState();
}

class _ReplacementPickerState extends State<_ReplacementPicker> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final options = [challengeBodySaw, ...exerciseCatalog]
      ..sort((a, b) {
        final art = (challengeAvatarFrames.containsKey(b.id) ? 1 : 0).compareTo(
          challengeAvatarFrames.containsKey(a.id) ? 1 : 0,
        );
        return art == 0 ? a.name.compareTo(b.name) : art;
      });
    final filtered = options
        .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .88,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Replace exercise',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cancel replacement',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              TextField(
                onChanged: (value) => setState(() => query = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search exercises',
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, index) {
                    final exercise = filtered[index];
                    return ListTile(
                      leading: SizedBox(
                        width: 60,
                        height: 60,
                        child: ChallengeAvatar(
                          exercise: exercise,
                          animate: false,
                        ),
                      ),
                      title: Text(exercise.name),
                      subtitle: Text(
                        challengeAvatarFrames.containsKey(exercise.id)
                            ? 'Realistic avatar'
                            : 'Original illustrated avatar',
                      ),
                      trailing: const Icon(Icons.swap_horiz),
                      onTap: () => Navigator.pop(context, exercise),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List<ChallengeEntry>?> showChallengeExerciseDetails(
  BuildContext context,
  List<ChallengeEntry> entries,
  int initialIndex, {
  bool editable = true,
}) {
  final draft = [...entries];
  var index = initialIndex;
  return showModalBottomSheet<List<ChallengeEntry>>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, update) {
        final entry = draft[index];
        void close() => Navigator.pop(ctx, draft);
        Future<void> replace() async {
          final replacement = await replaceChallengeExercise(ctx);
          if (replacement != null && ctx.mounted) {
            update(
              () => draft[index] = entry.copyWith(exerciseId: replacement.id),
            );
          }
        }

        return ExerciseDetailCard(
          key: ValueKey('${entry.id}-${entry.exerciseId}'),
          exercise: entry.exercise,
          accent: trainingCardBlue,
          avatar: ChallengeAvatar(exercise: entry.exercise),
          onClose: close,
          headerAction: editable
              ? IconButton(
                  tooltip: 'Replace exercise',
                  onPressed: replace,
                  icon: const Icon(Icons.swap_horiz),
                )
              : null,
          targetControls: editable
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Decrease duration',
                      onPressed: entry.seconds <= 5
                          ? null
                          : () => update(
                              () => draft[index] = entry.copyWith(
                                seconds: entry.seconds - 5,
                              ),
                            ),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      challengeTime(entry.seconds),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      tooltip: 'Increase duration',
                      onPressed: entry.seconds >= 3600
                          ? null
                          : () => update(
                              () => draft[index] = entry.copyWith(
                                seconds: entry.seconds + 5,
                              ),
                            ),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                )
              : null,
          footer: Row(
            children: [
              IconButton(
                tooltip: 'Previous exercise detail',
                onPressed: index == 0 ? null : () => update(() => index--),
                icon: const Icon(Icons.skip_previous),
              ),
              SizedBox(
                width: 52,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('${index + 1}/${draft.length}'),
                ),
              ),
              IconButton(
                tooltip: 'Next exercise detail',
                onPressed: index == draft.length - 1
                    ? null
                    : () => update(() => index++),
                icon: const Icon(Icons.skip_next),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: trainingCardBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: close,
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class ChallengePlanEditor extends StatefulWidget {
  const ChallengePlanEditor({super.key, required this.entries});
  final List<ChallengeEntry> entries;
  @override
  State<ChallengePlanEditor> createState() => _ChallengePlanEditorState();
}

class _ChallengePlanEditorState extends State<ChallengePlanEditor> {
  late List<ChallengeEntry> draft = [...widget.entries];
  bool leaving = false;
  bool get dirty =>
      draft.map((e) => '${e.id}:${e.exerciseId}:${e.seconds}').join('|') !=
      widget.entries
          .map((e) => '${e.id}:${e.exerciseId}:${e.seconds}')
          .join('|');
  void finish([bool save = false]) {
    setState(() => leaving = true);
    Navigator.pop(context, save ? draft : null);
  }

  Future<void> exit() async {
    if (!dirty) {
      finish();
      return;
    }
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save changes?'),
        content: const Text('Keep your edits to this challenge day?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'stay'),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'save'),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (!mounted || choice == null || choice == 'stay') return;
    finish(choice == 'save');
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: leaving,
    onPopInvokedWithResult: (popped, _) {
      if (!popped) exit();
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Edit plan'),
        leading: IconButton(
          tooltip: 'Back from plan editor',
          onPressed: exit,
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => draft = referenceDayEntries()),
            child: const Text('Reset'),
          ),
        ],
      ),
      body: ReorderableListView.builder(
        buildDefaultDragHandles: false,
        padding: const EdgeInsets.all(12),
        itemCount: draft.length,
        onReorderItem: (oldIndex, newIndex) => setState(() {
          draft.insert(newIndex, draft.removeAt(oldIndex));
        }),
        itemBuilder: (context, index) {
          final entry = draft[index];
          return Card(
            key: ValueKey(entry.id),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.drag_handle),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: ChallengeAvatar(
                          exercise: entry.exercise,
                          animate: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(entry.exercise.name)),
                      IconButton(
                        tooltip: 'Replace ${entry.exercise.name}',
                        onPressed: () async {
                          final replacement = await replaceChallengeExercise(
                            context,
                          );
                          if (replacement != null && mounted) {
                            setState(
                              () => draft[index] = entry.copyWith(
                                exerciseId: replacement.id,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.swap_horiz),
                      ),
                    ],
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Decrease ${entry.id}',
                        onPressed: entry.seconds <= 5
                            ? null
                            : () => setState(
                                () => draft[index] = entry.copyWith(
                                  seconds: entry.seconds - 5,
                                ),
                              ),
                        icon: const Icon(Icons.remove),
                      ),
                      Text(challengeTime(entry.seconds)),
                      IconButton(
                        tooltip: 'Increase ${entry.id}',
                        onPressed: entry.seconds >= 3600
                            ? null
                            : () => setState(
                                () => draft[index] = entry.copyWith(
                                  seconds: entry.seconds + 5,
                                ),
                              ),
                        icon: const Icon(Icons.add),
                      ),
                      IconButton(
                        tooltip: 'Remove ${entry.exercise.name}',
                        onPressed: draft.length == 1
                            ? null
                            : () => setState(() => draft.removeAt(index)),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => finish(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: trainingCardBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => finish(true),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
