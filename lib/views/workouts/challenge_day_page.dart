import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/challenge_day.dart';
import '../../data/repositories/challenge_day_repository.dart';
import '../../widgets/exercises/challenge_avatar.dart';
import '../../widgets/training_feature_cards.dart';
import 'challenge_plan_editor.dart';
import 'challenge_session_page.dart';

class ReferenceChallengeCard extends StatefulWidget {
  const ReferenceChallengeCard({super.key});
  @override
  State<ReferenceChallengeCard> createState() => _ReferenceChallengeCardState();
}

class _ReferenceChallengeCardState extends State<ReferenceChallengeCard> {
  late Future<ChallengeDay> future = ChallengeDayRepository.instance.load();
  Future<void> open() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const ChallengeDayPage()),
    );
    if (mounted) {
      setState(() => future = ChallengeDayRepository.instance.load());
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<ChallengeDay>(
    future: future,
    builder: (context, snapshot) {
      final day = snapshot.data;
      return TrainingPhotoCard(
        title: 'INTENSE\nBELLY FAT BURN',
        image: 'assets/images/workouts/belly_fat_burn.jpg',
        subtitle: snapshot.hasError
            ? 'Open Day 1 to retry loading your saved plan.'
            : 'DAY 1 • ${day?.entries.length ?? 21} Exercises\nTimed training, exercise editing and saved progress',
        actionLabel: day?.progress == null
            ? 'START DAY 1'
            : day!.progress!.credited
            ? 'VIEW DAY 1'
            : 'CONTINUE DAY 1',
        onTap: open,
      );
    },
  );
}

class ChallengeDayPage extends StatefulWidget {
  const ChallengeDayPage({super.key, this.enableMedia = true});
  final bool enableMedia;
  @override
  State<ChallengeDayPage> createState() => _ChallengeDayPageState();
}

class _ChallengeDayPageState extends State<ChallengeDayPage> {
  final repository = ChallengeDayRepository.instance;
  ChallengeDay? day;
  List<ChallengeEntry>? pendingPlan;
  int prep = 15, rest = 30;
  bool busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final saved = await repository.load();
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          day = saved;
          prep = (prefs.getInt('settings_prep') ?? 15).clamp(0, 60);
          rest = prefs.getString('settings_rest_mode') == 'Custom'
              ? (prefs.getInt('settings_rest_seconds') ?? 30).clamp(0, 600)
              : 30;
          error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Could not load this challenge. Your saved plan has not been replaced.',
        );
      }
    }
  }

  bool get inProgress => day?.progress != null && !day!.progress!.credited;
  Future<bool> confirmReset() async =>
      !inProgress ||
      await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Restart this session?'),
              content: const Text(
                'Changing the exercise plan will clear the current session countdown. Completed workout history is kept.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ) ==
          true;
  Future<void> savePlan(List<ChallengeEntry> entries) async {
    setState(() => busy = true);
    try {
      final next = ChallengeDay(entries: entries);
      await repository.save(next);
      if (mounted) {
        setState(() {
          day = next;
          pendingPlan = null;
          error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          pendingPlan = entries;
          error = 'Could not save your plan. Your edits are ready to retry.';
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> edit() async {
    if (busy || day == null || !await confirmReset() || !mounted) return;
    final entries = await Navigator.push<List<ChallengeEntry>>(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengePlanEditor(entries: day!.entries),
      ),
    );
    if (entries != null && mounted) await savePlan(entries);
  }

  Future<void> details(int index) async {
    final entries = await showChallengeExerciseDetails(
      context,
      day!.entries,
      index,
      editable: !inProgress,
    );
    if (!mounted || entries == null || inProgress) return;
    final before = day!.entries.map((e) => e.toJson().toString()).join('|'),
        after = entries.map((e) => e.toJson().toString()).join('|');
    if (before != after) await savePlan(entries);
  }

  Future<void> start({bool restart = false}) async {
    if (busy || day == null) return;
    if (restart && day!.progress != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Restart Day 1?'),
          content: const Text(
            'Your exercise edits are kept. Only the current session progress will restart.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Restart'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengeSessionPage(
          day: day!,
          prep: prep,
          rest: rest,
          restart: restart,
          enableMedia: widget.enableMedia,
        ),
      ),
    );
    if (mounted) await load();
  }

  Future<void> settings() async {
    await Navigator.pushNamed(context, AppRoutes.workoutSettings);
    if (mounted) await load();
  }

  Widget startButtons() {
    final saved = day!.progress;
    final fraction = saved == null
        ? 0.0
        : saved.phase == ChallengePhase.complete
        ? 1.0
        : ((saved.index +
                      (saved.phase == ChallengePhase.rest
                          ? 1
                          : saved.phase == ChallengePhase.exercise
                          ? 1 -
                                saved.remainingMs /
                                    (day!.entries[saved.index].seconds * 1000)
                          : 0)) /
                  day!.entries.length)
              .clamp(0, 1);
    return LayoutBuilder(
      builder: (context, box) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          if (saved != null)
            SizedBox(
              width: MediaQuery.textScalerOf(context).scale(16) > 24
                  ? box.maxWidth
                  : (box.maxWidth - 12) / 2,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF242424),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 56),
                ),
                onPressed: busy ? null : () => start(restart: true),
                child: const Text('Restart'),
              ),
            ),
          SizedBox(
            width:
                saved == null || MediaQuery.textScalerOf(context).scale(16) > 24
                ? box.maxWidth
                : (box.maxWidth - 12) / 2,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: trainingCardBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 56),
              ),
              onPressed: busy ? null : () => start(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Text(
                      saved == null
                          ? 'Start'
                          : saved.credited
                          ? 'Completed'
                          : saved.phase == ChallengePhase.complete
                          ? 'Save completion'
                          : 'Continue',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (saved != null)
                      Text('${(fraction * 100).round()}% completed'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: day == null
        ? SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: BackButton(onPressed: () => Navigator.pop(context)),
                ),
                Expanded(
                  child: Center(
                    child: error == null
                        ? const CircularProgressIndicator()
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(error!, textAlign: TextAlign.center),
                              TextButton(
                                onPressed: load,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          )
        : CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  tooltip: 'Back to training',
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black38,
                  ),
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                expandedHeight: 240,
                pinned: true,
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF242424),
                title: const Text('Day 1'),
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    'assets/images/workouts/belly_fat_burn.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                actions: [
                  PopupMenuButton<String>(
                    tooltip: 'Challenge options',
                    onSelected: (_) => edit(),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit plan'),
                      ),
                    ],
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'DAY 1',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Day workout settings',
                            onPressed: settings,
                            icon: const Icon(Icons.tune),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 18,
                        runSpacing: 8,
                        children: [
                          Text(
                            '~${day!.estimatedMinutes(rest, prep)} mins',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${day!.entries.length} Exercises',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      if (error != null) ...[
                        Text(error!, style: const TextStyle(color: Colors.red)),
                        TextButton(
                          onPressed: pendingPlan == null
                              ? load
                              : () => savePlan(pendingPlan!),
                          child: Text(
                            pendingPlan == null
                                ? 'Reload saved plan'
                                : 'Retry saving plan',
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      startButtons(),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Exercises',
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: trainingCardBlue,
                            ),
                            onPressed: busy ? null : edit,
                            icon: const Icon(Icons.chevron_right),
                            label: const Text('Edit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverReorderableList(
                onReorderItem: (oldIndex, newIndex) {
                  if (busy || inProgress) return;
                  final entries = [...day!.entries];
                  entries.insert(newIndex, entries.removeAt(oldIndex));
                  setState(() => day = ChallengeDay(entries: entries));
                  savePlan(entries);
                },
                itemCount: day!.entries.length,
                itemBuilder: (context, index) {
                  final entry = day!.entries[index];
                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(entry.id),
                    index: index,
                    enabled: !busy && !inProgress,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          ListTile(
                            minTileHeight: 96,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Tooltip(
                                  message: 'Hold and drag to reorder',
                                  child: Icon(
                                    Icons.drag_handle,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 76,
                                  height: 76,
                                  child: ChallengeAvatar(
                                    exercise: entry.exercise,
                                    animate: false,
                                  ),
                                ),
                              ],
                            ),
                            title: Text(
                              entry.exercise.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(challengeTime(entry.seconds)),
                            onTap: busy ? null : () => details(index),
                            trailing: IconButton(
                              tooltip: 'Replace ${entry.exercise.name}',
                              onPressed: busy
                                  ? null
                                  : () async {
                                      if (!await confirmReset() ||
                                          !context.mounted) {
                                        return;
                                      }
                                      final replacement =
                                          await replaceChallengeExercise(
                                            context,
                                          );
                                      if (replacement != null && mounted) {
                                        final entries = [...day!.entries];
                                        entries[index] = entry.copyWith(
                                          exerciseId: replacement.id,
                                        );
                                        await savePlan(entries);
                                      }
                                    },
                              icon: const Icon(Icons.swap_horiz),
                            ),
                          ),
                          const Divider(indent: 108, color: Colors.black12),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
    bottomNavigationBar: day == null
        ? null
        : SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: trainingCardBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 52),
                ),
                onPressed: busy ? null : () => start(),
                child: Text(
                  day!.progress == null
                      ? 'Start workout'
                      : day!.progress!.credited
                      ? 'View completion'
                      : 'Continue workout',
                ),
              ),
            ),
          ),
  );
}
