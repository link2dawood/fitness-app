import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/routes/app_routes.dart';
import '../../core/settings/challenge_audio.dart';
import '../../core/settings/tts_service.dart';
import '../../data/models/challenge_day.dart';
import '../../data/repositories/challenge_day_repository.dart';
import '../../data/repositories/training_history_repository.dart';
import '../../viewmodels/challenge_session_controller.dart';
import '../../widgets/exercises/challenge_avatar.dart';
import '../../widgets/training_feature_cards.dart';
import 'challenge_plan_editor.dart';

class ChallengeSessionPage extends StatefulWidget {
  const ChallengeSessionPage({
    super.key,
    required this.day,
    required this.prep,
    required this.rest,
    this.restart = false,
    this.enableMedia = true,
  });
  final ChallengeDay day;
  final int prep, rest;
  final bool restart, enableMedia;
  @override
  State<ChallengeSessionPage> createState() => _ChallengeSessionPageState();
}

class _ChallengeSessionPageState extends State<ChallengeSessionPage>
    with WidgetsBindingObserver {
  late final controller = ChallengeSessionController(
    day: widget.day,
    prepSeconds: widget.prep,
    restSeconds: widget.rest,
    restart: widget.restart,
  );
  final repository = ChallengeDayRepository.instance;
  final clock = Stopwatch();
  int previousMs = 0, checkpointMs = 0;
  Timer? timer;
  ChallengeAudio? audio;
  bool leaving = false,
      saving = false,
      exiting = false,
      voice = true,
      effects = true,
      mute = false;
  double voiceVolume = .8;
  String? error, spokenPhase;
  bool? mediaWanted;
  bool mediaReady = false;
  bool? lastPaused;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.addListener(changed);
    clock.start();
    if (widget.enableMedia) {
      audio = ChallengeAudio();
      unawaited(loadMedia());
    }
    timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final elapsed = clock.elapsedMilliseconds, delta = elapsed - previousMs;
      previousMs = elapsed;
      controller.tick(Duration(milliseconds: delta));
      if (elapsed - checkpointMs >= 1000 &&
          controller.phase != ChallengePhase.complete) {
        checkpointMs = elapsed;
        unawaited(checkpoint());
      }
    });
    unawaited(checkpoint());
    if (controller.phase == ChallengePhase.complete && !controller.credited) {
      unawaited(complete());
    }
  }

  Future<void> loadMedia() async {
    try {
      await audio?.load();
      final prefs = await SharedPreferences.getInstance();
      voice = prefs.getBool('settings_voice') ?? true;
      effects = prefs.getBool('settings_effect') ?? true;
      mute = prefs.getBool('settings_mute') ?? false;
      voiceVolume = prefs.getDouble('settings_voice_volume') ?? .8;
      mediaWanted = null;
      spokenPhase = null;
      mediaReady = true;
      if (mounted) changed();
    } catch (_) {
      /* Audio support does not block the exercise timer. */
    }
  }

  void changed() {
    if (!mounted) return;
    if (lastPaused != controller.paused) {
      previousMs = clock.elapsedMilliseconds;
      lastPaused = controller.paused;
    }
    setState(() {});
    final wanted =
        !controller.paused && controller.phase != ChallengePhase.complete;
    if (mediaReady && wanted != mediaWanted) {
      mediaWanted = wanted;
      unawaited(audio?.play(wanted) ?? Future.value());
    }
    final phaseKey = '${controller.index}:${controller.phase.name}';
    if (phaseKey != spokenPhase) {
      spokenPhase = phaseKey;
      unawaited(checkpoint());
      if (widget.enableMedia && mediaReady && !controller.paused) {
        final text = switch (controller.phase) {
          ChallengePhase.prep =>
            'Get ready. ${widget.day.entries.first.exercise.name}',
          ChallengePhase.exercise =>
            widget.day.entries[controller.index].exercise.name,
          ChallengePhase.rest =>
            'Rest. Next, ${widget.day.entries[controller.displayIndex].exercise.name}',
          ChallengePhase.complete => 'Workout complete. Well done.',
        };
        if (voice && !mute) unawaited(speak(text, phaseKey));
        if (effects && !mute) {
          unawaited(
            SystemSound.play(SystemSoundType.click).catchError((Object _) {}),
          );
        }
      }
    }
    if (controller.phase == ChallengePhase.complete &&
        !controller.credited &&
        !saving) {
      unawaited(complete());
    }
  }

  Future<void> speak(String text, String phaseKey) async {
    try {
      await TtsService().state();
      if (!mounted || controller.paused || mute || spokenPhase != phaseKey) {
        return;
      }
      await TtsService().action('speak', {'text': text, 'volume': voiceVolume});
    } catch (_) {
      /* An unavailable voice never blocks the timer. */
    }
  }

  Future<void> checkpoint() async {
    try {
      await repository.save(controller.snapshot());
      if (mounted && error?.startsWith('Progress') == true) {
        setState(() => error = null);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Progress could not be saved. Retry before leaving.',
        );
      }
    }
  }

  Future<void> complete() async {
    if (saving || controller.credited) return;
    saving = true;
    try {
      await TrainingHistoryRepository.instance.complete(
        TrainingCompletion(
          id: controller.id,
          workoutId: referenceChallengeId,
          title: '$referenceChallengeTitle • Day 1',
          finishedAt: controller.finishedAt ?? DateTime.now(),
          seconds: controller.activeMs ~/ 1000,
        ),
      );
      controller.credited = true;
      await repository.save(controller.snapshot());
      if (mounted) setState(() => error = null);
    } catch (_) {
      controller.credited = false;
      if (mounted) {
        setState(
          () => error =
              'Completion could not be saved. Retry to record this workout.',
        );
      }
    } finally {
      saving = false;
      if (mounted) setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      controller.pause();
      unawaited(checkpoint());
      unawaited(audio?.play(false) ?? Future.value());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.removeListener(changed);
    controller.dispose();
    clock.stop();
    audio?.dispose();
    if (widget.enableMedia) {
      TtsService().action('stop').catchError((Object _) {});
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> exit() async {
    if (saving || exiting) return;
    exiting = true;
    controller.pause();
    final close =
        controller.phase == ChallengePhase.complete ||
        await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Save and leave?'),
                content: const Text(
                  'Your current exercise and countdown will be saved for Continue.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Keep training'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Save and leave'),
                  ),
                ],
              ),
            ) ==
            true;
    if (close) {
      try {
        await repository.save(controller.snapshot());
        if (mounted) {
          setState(() => leaving = true);
          Navigator.pop(context);
        }
      } catch (_) {
        if (mounted) {
          setState(
            () => error = 'Progress could not be saved. Retry before leaving.',
          );
        }
      }
    }
    exiting = false;
  }

  Future<void> settings() async {
    controller.pause();
    await Navigator.pushNamed(context, AppRoutes.workoutSettings);
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getString('settings_rest_mode') == 'Custom'
        ? (prefs.getInt('settings_rest_seconds') ?? 30).clamp(0, 600)
        : 30;
    if (seconds != controller.restSeconds) controller.setRest(seconds);
    await loadMedia();
  }

  Future<void> editRest() async {
    controller.pause();
    var seconds = controller.restSeconds;
    final result = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit rest time',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Shorter rest',
                      onPressed: seconds <= 0
                          ? null
                          : () => update(
                              () => seconds = (seconds - 5).clamp(0, 600),
                            ),
                      icon: const Icon(Icons.remove),
                    ),
                    Text('$seconds seconds'),
                    IconButton(
                      tooltip: 'Longer rest',
                      onPressed: seconds >= 600
                          ? null
                          : () => update(() => seconds += 5),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, seconds),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null && mounted) {
      final prefs = await SharedPreferences.getInstance();
      final saved =
          await prefs.setString('settings_rest_mode', 'Custom') &&
          await prefs.setInt('settings_rest_seconds', result);
      if (saved) {
        controller.setRest(result);
      } else {
        setState(() => error = 'Rest time could not be saved.');
      }
    }
  }

  Future<void> music() async {
    controller.pause();
    final media = audio;
    if (media == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: AnimatedBuilder(
          animation: media,
          builder: (ctx, _) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Music'),
                  value: media.enabled,
                  onChanged: (value) => media.toggle(value),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    media.cover,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  media.tracks[media.index].$1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const Text('Saved workout music'),
                Wrap(
                  children: [
                    IconButton(
                      tooltip: media.repeat
                          ? 'Repeat current song'
                          : 'Play queue in order',
                      onPressed: media.toggleRepeat,
                      icon: Icon(
                        media.repeat ? Icons.repeat_one : Icons.repeat,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Previous song',
                      onPressed: () => media.select(media.index - 1),
                      icon: const Icon(Icons.skip_previous),
                    ),
                    IconButton(
                      tooltip: media.playing ? 'Pause music' : 'Play music',
                      onPressed: () => media.play(!media.playing),
                      icon: Icon(
                        media.playing ? Icons.pause_circle : Icons.play_circle,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Next song',
                      onPressed: () => media.select(media.index + 1),
                      icon: const Icon(Icons.skip_next),
                    ),
                  ],
                ),
                Slider(
                  label: 'Music volume',
                  value: media.volume,
                  onChanged: (value) => media.setVolume(value),
                ),
                for (var i = 0; i < media.tracks.length; i++)
                  ListTile(
                    selected: i == media.index,
                    title: Text(media.tracks[i].$1),
                    trailing: i == media.index ? const Icon(Icons.check) : null,
                    onTap: () => media.select(i),
                  ),
                if (media.error != null) Text(media.error!),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await media.play(false);
  }

  Widget sessionControls(bool rest) => Wrap(
    spacing: 12,
    runSpacing: 12,
    alignment: WrapAlignment.center,
    children: [
      if (rest)
        OutlinedButton(
          onPressed: controller.addRest,
          style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
          child: const Text('+20s'),
        )
      else
        IconButton.filledTonal(
          tooltip: 'Previous exercise',
          onPressed: controller.index == 0 ? null : controller.previous,
          icon: const Icon(Icons.skip_previous),
        ),
      FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: rest ? Colors.white : trainingCardBlue,
          foregroundColor: rest ? trainingCardBlue : Colors.white,
          minimumSize: const Size(120, 52),
        ),
        onPressed: () => controller.pause(!controller.paused),
        icon: Icon(controller.paused ? Icons.play_arrow : Icons.pause),
        label: Text(controller.paused ? 'Resume' : 'Pause'),
      ),
      if (rest)
        FilledButton(
          onPressed: controller.next,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: trainingCardBlue,
          ),
          child: const Text('Skip'),
        )
      else
        IconButton.filledTonal(
          tooltip: controller.phase == ChallengePhase.prep
              ? 'Skip preparation'
              : 'Next exercise',
          onPressed: controller.next,
          icon: const Icon(Icons.skip_next),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final rest = controller.phase == ChallengePhase.rest,
        completePhase = controller.phase == ChallengePhase.complete;
    final entry = widget.day.entries[controller.displayIndex];
    return PopScope(
      canPop: leaving,
      onPopInvokedWithResult: (popped, _) {
        if (!popped) exit();
      },
      child: Scaffold(
        backgroundColor: rest ? trainingCardBlue : Colors.white,
        appBar: AppBar(
          backgroundColor: rest ? trainingCardBlue : Colors.white,
          foregroundColor: rest ? Colors.white : Colors.black,
          leading: IconButton(
            style: IconButton.styleFrom(
              foregroundColor: rest ? Colors.white : Colors.black,
            ),
            tooltip: 'Save and leave challenge',
            onPressed: exit,
            icon: Icon(
              Icons.arrow_back,
              color: rest ? Colors.white : Colors.black,
            ),
          ),
          title: Text(
            'Day 1 • ${controller.displayIndex + 1}/${widget.day.entries.length}',
          ),
          actions: [
            IconButton(
              tooltip: 'Workout music',
              style: IconButton.styleFrom(
                foregroundColor: rest ? Colors.white : Colors.black,
              ),
              onPressed: music,
              icon: Icon(
                Icons.music_note,
                color: rest ? Colors.white : Colors.black,
              ),
            ),
            IconButton(
              tooltip: mute ? 'Unmute coaching' : 'Mute coaching',
              style: IconButton.styleFrom(
                foregroundColor: rest ? Colors.white : Colors.black,
              ),
              onPressed: () async {
                setState(() => mute = !mute);
                await (await SharedPreferences.getInstance()).setBool(
                  'settings_mute',
                  mute,
                );
                if (audio != null) await audio!.setVolume(audio!.volume);
                if (mute && widget.enableMedia) {
                  await TtsService().action('stop').catchError((Object _) {});
                }
              },
              icon: Icon(
                mute ? Icons.volume_off : Icons.volume_up,
                color: rest ? Colors.white : Colors.black,
              ),
            ),
            IconButton(
              tooltip: 'Workout settings',
              style: IconButton.styleFrom(
                foregroundColor: rest ? Colors.white : Colors.black,
              ),
              onPressed: settings,
              icon: Icon(
                Icons.settings,
                color: rest ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        bottomNavigationBar: completePhase
            ? null
            : SafeArea(
                minimum: const EdgeInsets.all(16),
                child: sessionControls(rest),
              ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (error != null)
                MaterialBanner(
                  content: Text(error!),
                  actions: [
                    TextButton(
                      onPressed: completePhase ? complete : checkpoint,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              if (!completePhase)
                AspectRatio(
                  aspectRatio: 1.5,
                  child: ChallengeAvatar(
                    exercise: entry.exercise,
                    animate: !controller.paused,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (completePhase) ...[
                      const Icon(
                        Icons.check_circle,
                        size: 80,
                        color: trainingCardBlue,
                      ),
                      const Text(
                        'DAY 1 COMPLETE',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${widget.day.entries.length} exercises • ${challengeTime(controller.activeMs ~/ 1000)}',
                      ),
                      Text(
                        controller.credited
                            ? 'Workout saved to your history'
                            : saving
                            ? 'Saving completion…'
                            : 'Completion not saved yet',
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: saving
                            ? null
                            : controller.credited
                            ? exit
                            : complete,
                        child: Text(
                          controller.credited ? 'Done' : 'Save completion',
                        ),
                      ),
                    ] else ...[
                      if (rest)
                        Text(
                          'NEXT ${controller.displayIndex + 1}/${widget.day.entries.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      Text(
                        entry.exercise.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: rest ? Colors.white : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Exercise instructions',
                        onPressed: () {
                          controller.pause();
                          showChallengeExerciseDetails(
                            context,
                            widget.day.entries,
                            controller.displayIndex,
                            editable: false,
                          );
                        },
                        icon: Icon(
                          Icons.help_outline,
                          color: rest ? Colors.white : Colors.grey,
                        ),
                      ),
                      if (controller.phase == ChallengePhase.prep)
                        const Text(
                          'READY TO GO!',
                          style: TextStyle(
                            color: trainingCardBlue,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      if (rest)
                        const Text(
                          'REST',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          challengeTime(controller.remainingSeconds),
                          style: TextStyle(
                            color: rest ? Colors.white : Colors.black,
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (controller.paused)
                        Text(
                          'Paused',
                          style: TextStyle(
                            color: rest ? Colors.white : Colors.grey,
                          ),
                        ),
                      if (rest)
                        TextButton(
                          onPressed: editRest,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Edit Rest Time'),
                        ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: controller.progress,
                        color: rest ? Colors.white : trainingCardBlue,
                        backgroundColor: rest ? Colors.white24 : Colors.black12,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
