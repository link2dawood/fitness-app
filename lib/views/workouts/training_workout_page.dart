import '../../core/settings/settings_record.dart';
import '../../core/settings/challenge_audio.dart';
import '../../core/settings/tts_service.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/training_workout.dart';
import '../../data/repositories/training_history_repository.dart';
import '../../widgets/exercises/exercise_avatar.dart';
import 'exercise_detail.dart';

Future<void> openTrainingWorkout(
  BuildContext context,
  TrainingWorkout workout,
) => Navigator.of(context).push<void>(
  MaterialPageRoute(builder: (_) => TrainingWorkoutPage(workout: workout)),
);

class TrainingWorkoutPage extends StatefulWidget {
  const TrainingWorkoutPage({super.key, required this.workout});
  final TrainingWorkout workout;
  @override
  State<TrainingWorkoutPage> createState() => _TrainingWorkoutPageState();
}

class _TrainingWorkoutPageState extends State<TrainingWorkoutPage> {
  bool loading = true;
  String? error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await TrainingHistoryRepository.instance.load();
      if (mounted) {
        setState(() {
          loading = false;
          error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'Could not load history. Retry to protect saved progress.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.workout.title)),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(error!, textAlign: TextAlign.center),
                TextButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          )
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                widget.workout.summary,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Estimated time includes rest between exercises. Rep pace may vary.',
              ),
              const SizedBox(height: 12),
              for (final (entryIndex, exercise)
                  in widget.workout.exercises.indexed)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 56,
                    height: 56,
                    child: ExerciseAvatar(exercise: exercise, animate: false),
                  ),
                  title: Text(exercise.name),
                  subtitle: Text(
                    exercise.timed
                        ? '${widget.workout.targetAt(entryIndex)} seconds'
                        : '${widget.workout.targetAt(entryIndex)} reps',
                  ),
                  trailing: const Icon(Icons.info_outline),
                  onTap: () => showExercisePreview(context, exercise),
                ),
            ],
          ),
    bottomNavigationBar: loading || error != null
        ? null
        : SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) =>
                        TrainingSessionPage(workout: widget.workout),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Start workout'),
                ),
              ),
            ),
          ),
  );
}

class TrainingSessionPage extends StatefulWidget {
  const TrainingSessionPage({
    super.key,
    required this.workout,
    this.createStopwatch,
  });
  final Stopwatch Function()? createStopwatch;
  final TrainingWorkout workout;
  @override
  State<TrainingSessionPage> createState() => _TrainingSessionPageState();
}

class _TrainingSessionPageState extends State<TrainingSessionPage>
    with WidgetsBindingObserver {
  final sessionId = DateTime.now().toUtc().microsecondsSinceEpoch.toString();
  late final active = widget.createStopwatch?.call() ?? Stopwatch();
  late final phase = widget.createStopwatch?.call() ?? Stopwatch();
  Timer? timer;
  int index = 0;
  SettingsRecord? preferences;
  bool preparing = false;
  String? settingsError;
  ChallengeAudio? audio;
  final tts = TtsService();
  Future<void> _loadSettings() async {
    try {
      final settings = await SettingsRecord.load('settings_');
      if (!mounted) return;
      setState(() {
        preferences = settings;
        settingsError = null;
        preparing = (settings.getInt('settings_prep') ?? 15).clamp(0, 60) > 0;
      });
      if (!paused) {
        active.start();
        phase.start();
      }
      // Missing media plugins must never prevent a workout from starting.
      try {
        await tts.state();
        if (!mounted) return;
        audio = ChallengeAudio();
        await audio!.load();
        if (!mounted) return;
        await audio!.play(!paused);
      } catch (_) {
        /* Media is optional on unsupported platforms. */
      }
      if (mounted) _announce();
    } catch (_) {
      if (mounted) {
        setState(
          () => settingsError =
              'Could not load workout settings. Retry before starting.',
        );
      }
    }
  }

  void _announce() {
    final settings = preferences;
    if (settings == null || paused) return;
    if (settings.getBool('settings_mute') == true) return;
    if (settings.getBool('settings_effect') ?? true) {
      unawaited(
        SystemSound.play(SystemSoundType.click).catchError((Object _) {}),
      );
    }
    if (settings.getBool('settings_voice') ?? true) {
      unawaited(
        tts
            .action('speak', {
              'text': finished
                  ? 'Workout complete'
                  : preparing
                  ? 'Get ready'
                  : rest
                  ? 'Rest'
                  : widget.workout.exercises[index].name,
              'volume': settings.getDouble('settings_voice_volume') ?? .8,
            })
            .catchError((Object _) {}),
      );
    }
  }

  bool rest = false,
      paused = false,
      finished = false,
      saving = false,
      saved = false,
      leaving = false;
  String? error;
  DateTime? completedAt;
  bool confirmingExit = false;
  int get phaseSeconds => preparing
      ? (preferences?.getInt('settings_prep') ?? 15).clamp(0, 60)
      : rest
      ? (preferences?.restFor(widget.workout.restAfter(index)) ??
            widget.workout.restAfter(index))
      : widget.workout.exercises[index].timed
      ? widget.workout.targetAt(index)
      : 0;
  int get remaining =>
      (phaseSeconds - phase.elapsed.inSeconds).clamp(0, phaseSeconds);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
    timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted && preferences != null && !paused && !finished) {
        if (preparing && remaining == 0) {
          setState(() {
            preparing = false;
            phase.reset();
          });
          _announce();
        } else {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    audio?.dispose();
    unawaited(tts.action('stop').catchError((Object _) {}));
    active.stop();
    phase.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && !paused && !finished) _pause();
  }

  void _pause() => setState(() {
    unawaited(audio?.play(paused) ?? Future.value());
    unawaited(tts.action('stop').catchError((Object _) {}));
    paused = !paused;
    if (paused) {
      active.stop();
      phase.stop();
    } else {
      active.start();
      phase.start();
    }
  });
  void _next() {
    if (preferences == null ||
        preparing ||
        paused ||
        finished ||
        saving ||
        (!rest && widget.workout.exercises[index].timed && remaining > 0)) {
      return;
    }
    setState(() {
      if (rest) {
        rest = false;
        index++;
      } else if (index == widget.workout.exercises.length - 1) {
        finished = true;
        completedAt = DateTime.now();
        active.stop();
        phase.stop();
      } else {
        rest = preferences!.restFor(widget.workout.restAfter(index)) > 0;
        if (!rest) index++;
      }
      phase.reset();
    });
    if (finished) unawaited(audio?.play(false) ?? Future.value());
    _announce();
  }

  Future<void> _save() async {
    if (saving || saved) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await TrainingHistoryRepository.instance.complete(
        TrainingCompletion(
          id: sessionId,
          workoutId: widget.workout.id,
          title: widget.workout.title,
          finishedAt: completedAt!,
          seconds: active.elapsed.inSeconds,
        ),
      );
      if (mounted) {
        setState(() {
          saved = true;
          saving = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          error = 'Completion was not saved. Retry to save your progress.';
        });
      }
    }
  }

  Future<void> _exit() async {
    if (saving || confirmingExit) return;
    if (saved) {
      setState(() => leaving = true);
      if (mounted) Navigator.pop(context);
      return;
    }
    if (!paused && !finished) _pause();
    confirmingExit = true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave workout?'),
        content: const Text('This session will not count as completed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    confirmingExit = false;
    if (leave == true && mounted) {
      setState(() => leaving = true);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.workout.exercises[index];
    return PopScope(
      canPop: leaving || saved,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exit();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(finished ? 'Workout complete' : widget.workout.title),
          leading: IconButton(
            tooltip: 'Leave workout',
            onPressed: _exit,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: preferences == null
            ? Center(
                child: settingsError == null
                    ? const CircularProgressIndicator()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(settingsError!),
                          TextButton(
                            onPressed: _loadSettings,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (finished) ...[
                      const Icon(
                        Icons.check_circle,
                        size: 80,
                        color: AppColors.primary,
                      ),
                      Text(
                        saved ? 'Progress saved' : 'All exercises completed',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        '${widget.workout.exercises.length} exercises completed',
                      ),
                      if (error != null)
                        Text(error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: saving
                            ? null
                            : saved
                            ? _exit
                            : _save,
                        child: Text(
                          saving
                              ? 'Saving…'
                              : saved
                              ? 'Done'
                              : 'Save completion',
                        ),
                      ),
                    ] else ...[
                      LinearProgressIndicator(
                        value: index / widget.workout.exercises.length,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Exercise ${index + 1} of ${widget.workout.exercises.length}',
                      ),
                      Text(
                        preparing
                            ? 'Get ready'
                            : rest
                            ? 'Rest'
                            : exercise.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (rest)
                        Text(
                          'Next: ${widget.workout.exercises[index + 1].name}',
                        )
                      else
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: ExerciseAvatar(
                            exercise: exercise,
                            animate: !paused,
                          ),
                        ),
                      Text(
                        preparing || rest || exercise.timed
                            ? '$remaining seconds'
                            : '${widget.workout.targetAt(index)} reps',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      if (paused) const Text('Paused'),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton(
                            onPressed: _pause,
                            child: Text(paused ? 'Resume' : 'Pause'),
                          ),
                          FilledButton(
                            onPressed:
                                preparing ||
                                    paused ||
                                    (!rest && exercise.timed && remaining > 0)
                                ? null
                                : _next,
                            child: Text(
                              rest
                                  ? (remaining > 0 ? 'Skip rest' : 'Continue')
                                  : index == widget.workout.exercises.length - 1
                                  ? 'Finish exercise'
                                  : 'Exercise done',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
