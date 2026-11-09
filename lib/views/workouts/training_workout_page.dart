import 'package:shared_preferences/shared_preferences.dart';
import '../../core/settings/settings_record.dart';
import '../../core/settings/challenge_audio.dart';
import '../../core/settings/tts_service.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/training_workout.dart';
import '../../data/repositories/training_history_repository.dart';
import '../../widgets/exercises/challenge_avatar.dart';
import '../../widgets/rate_collection_dialog.dart';
import 'exercise_detail.dart';
import '../../data/models/challenge_poster.dart';
import '../../widgets/workout_session_view.dart';
import '../../core/routes/app_routes.dart';

Future<void> openTrainingWorkout(
  BuildContext context,
  TrainingWorkout workout, {
  String? challengeImage,
}) => Navigator.of(context).push<void>(
  MaterialPageRoute(
    builder: (_) =>
        TrainingWorkoutPage(workout: workout, challengeImage: challengeImage),
  ),
);

class TrainingWorkoutPage extends StatefulWidget {
  const TrainingWorkoutPage({
    super.key,
    required this.workout,
    this.challengeImage,
  });
  final String? challengeImage;
  final TrainingWorkout workout;
  @override
  State<TrainingWorkoutPage> createState() => _TrainingWorkoutPageState();
}

class _TrainingWorkoutPageState extends State<TrainingWorkoutPage> {
  bool get isChallenge =>
      widget.challengeImage != null ||
      challengePosterIds.contains(widget.workout.id);

  Future<void> _start() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TrainingSessionPage(workout: widget.workout),
      ),
    );
    if (mounted) await _load();
  }

  Widget _workoutHeader() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Stack(
        children: [
          Container(
            height: 260,
            width: double.infinity,
            color: const Color(0xFFE0F2FE),
            child: Image.asset(
              widget.challengeImage ??
                  (isChallenge
                      ? challengePosterArtwork(widget.workout, null)
                      : widget.workout.image),
              fit: isChallenge ? BoxFit.contain : BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: IconButton(
                tooltip: 'Back',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          ),
        ],
      ),
      ColoredBox(
        color: const Color(0xFFE0F2FE),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isChallenge ? 'DAY 1' : widget.workout.title,
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
              ),
              Text(
                isChallenge ? widget.workout.title : widget.workout.summary,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 22,
                runSpacing: 8,
                children: [
                  Text(
                    '~${widget.workout.estimatedMinutes} mins',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${widget.workout.exercises.length} Exercises',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10CFE3), Color(0xFF004BFF)],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(0, 60),
                    ),
                    onPressed: _start,
                    child: Text(
                      isChallenge ? 'Start' : 'Start workout',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Exercises',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    ],
  );
  bool loading = true;
  String? error;
  Set<int> _completedIndices = {};
  String get _storageKey => widget.workout.progressStorageKey;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await TrainingHistoryRepository.instance.load();
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList(_storageKey);
      final historyDone = TrainingHistoryRepository.instance.entries.any(
        (e) => e.workoutId == widget.workout.id,
      );

      final Set<int> indices;
      if (savedList != null) {
        indices = savedList.map(int.tryParse).whereType<int>().toSet();
      } else if (historyDone && widget.workout.planVersion == 1) {
        indices = List.generate(
          widget.workout.exercises.length,
          (i) => i,
        ).toSet();
      } else {
        indices = {};
      }

      if (mounted) {
        setState(() {
          _completedIndices = indices;
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

  Future<void> _toggleDone(int index) async {
    setState(() {
      if (_completedIndices.contains(index)) {
        _completedIndices.remove(index);
      } else {
        _completedIndices.add(index);
      }
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _storageKey,
        _completedIndices.map((i) => i.toString()).toList(),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: loading || error != null
        ? AppBar(title: Text(widget.workout.title))
        : null,
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
            padding: EdgeInsets.zero,
            children: [
              _workoutHeader(),
              for (final (entryIndex, exercise)
                  in widget.workout.exercises.indexed)
                () {
                  final isDone = _completedIndices.contains(entryIndex);
                  return ListTile(
                    key: ValueKey(
                      'training-exercise-${widget.workout.id}-$entryIndex',
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    leading: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          width: 76,
                          height: 76,
                          child: ChallengeAvatar(
                            exercise: exercise,
                            animate: false,
                          ),
                        ),
                        if (isDone)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      exercise.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDone
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      exercise.timed
                          ? '${widget.workout.targetAt(entryIndex)} seconds'
                          : '${widget.workout.targetAt(entryIndex)} reps',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: isDone
                              ? 'Mark as incomplete'
                              : 'Mark as completed',
                          icon: Icon(
                            isDone ? Icons.check_circle : Icons.circle_outlined,
                            color: isDone
                                ? AppColors.primary
                                : Colors.grey.shade400,
                            size: 26,
                          ),
                          onPressed: () => _toggleDone(entryIndex),
                        ),
                        IconButton(
                          tooltip: 'Exercise details',
                          icon: const Icon(
                            Icons.info_outline,
                            color: Colors.grey,
                          ),
                          onPressed: () => showExercisePreview(
                            context,
                            widget.workout.exerciseAt(entryIndex),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => showExercisePreview(
                      context,
                      widget.workout.exerciseAt(entryIndex),
                    ),
                  );
                }(),
            ],
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
  int restAdjustment = 0;
  int? sessionRest;
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
      ? (sessionRest ??
                preferences?.restFor(widget.workout.restAfter(index)) ??
                widget.workout.restAfter(index)) +
            restAdjustment
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
        } else if (!preparing &&
            remaining == 0 &&
            (rest || widget.workout.exercises[index].timed)) {
          _next();
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
  void _markExerciseDone(int exerciseIndex) {
    unawaited(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final key = widget.workout.progressStorageKey;
        final savedList = prefs.getStringList(key) ?? [];
        final set = savedList.map(int.tryParse).whereType<int>().toSet();
        set.add(exerciseIndex);
        await prefs.setStringList(key, set.map((i) => i.toString()).toList());
      } catch (_) {}
    }());
  }

  void _next({bool skip = false}) {
    if (preferences == null ||
        paused ||
        finished ||
        saving ||
        (!skip &&
            !rest &&
            !preparing &&
            widget.workout.exercises[index].timed &&
            remaining > 0)) {
      return;
    }
    setState(() {
      if (preparing) {
        preparing = false;
      } else if (rest) {
        rest = false;
        index++;
      } else if (index == widget.workout.exercises.length - 1) {
        _markExerciseDone(index);
        finished = true;
        completedAt = DateTime.now();
        active.stop();
        phase.stop();
      } else {
        _markExerciseDone(index);
        rest =
            (sessionRest ??
                preferences!.restFor(widget.workout.restAfter(index))) >
            0;
        if (!rest) index++;
      }
      restAdjustment = 0;
      phase.reset();
    });
    if (finished) unawaited(audio?.play(false) ?? Future.value());
    _announce();
  }

  Future<void> _details() async {
    final wasPaused = paused;
    if (!paused) _pause();
    await showExercisePreview(
      context,
      widget.workout.exerciseAt(rest ? index + 1 : index),
    );
    if (mounted && !wasPaused && paused) _pause();
  }

  Future<void> _editRest() async {
    final wasPaused = paused;
    if (!paused) _pause();
    final value = await showSessionRestEditor(
      context,
      sessionRest ?? preferences!.restFor(widget.workout.restAfter(index)),
      widget.workout.restAfter(index),
    );
    if (!mounted) return;
    if (value != null) {
      setState(() {
        sessionRest = value;
        restAdjustment = 0;
        phase.reset();
      });
    }
    if (!wasPaused && paused) _pause();
  }

  Future<void> _settings() async {
    final wasPaused = paused;
    if (!paused) _pause();
    await Navigator.pushNamed(context, AppRoutes.workoutSettings);
    if (!mounted) return;
    try {
      final updated = await SettingsRecord.load('settings_');
      if (!mounted) return;
      setState(() => preferences = updated);
    } catch (_) {
      if (mounted) setState(() => error = 'Could not reload workout settings.');
    }
    if (mounted && !wasPaused && paused) _pause();
  }

  void _previous() {
    if (index == 0 && !rest) return;
    setState(() {
      if (!rest) index--;
      rest = false;
      preparing = false;
      restAdjustment = 0;
      phase.reset();
    });
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
      try {
        final prefs = await SharedPreferences.getInstance();
        final all = List.generate(
          widget.workout.exercises.length,
          (i) => i.toString(),
        );
        await prefs.setStringList(widget.workout.progressStorageKey, all);
      } catch (_) {}
      if (mounted) {
        setState(() {
          saved = true;
          saving = false;
        });
        unawaited(showRateCollectionDialog(context));
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
    if (preferences != null && !finished) {
      final displayIndex = rest ? index + 1 : index;
      return PopScope(
        canPop: leaving,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _exit();
        },
        child: WorkoutSessionView(
          exercise: widget.workout.exerciseAt(displayIndex),
          index: displayIndex,
          count: widget.workout.exercises.length,
          remaining: remaining,
          target: widget.workout.targetAt(displayIndex),
          preparing: preparing,
          resting: rest,
          paused: paused,
          prepSeconds: preferences!.getInt('settings_prep') ?? 15,
          onExit: _exit,
          onPause: _pause,
          onNext: () => _next(skip: true),
          onPrevious: index == 0 && !rest ? null : _previous,
          onDetails: _details,
          onEditRest: _editRest,
          onAddRest: () => setState(
            () => restAdjustment = (restAdjustment + 20).clamp(0, 3600),
          ),
          onSettings: _settings,
          error: error,
          onRetry: () => setState(() => error = null),
        ),
      );
    }
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
                          child: ChallengeAvatar(
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
