import 'package:flutter/material.dart';
import '../data/models/exercise.dart';
import 'exercises/challenge_avatar.dart';

const sessionBlue = Color(0xFF0057FF);
const _green = Color(0xFF7AC143);

String sessionTime(int seconds) =>
    '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

// ─────────────────────────────────────────────────────────────────────────────
// Animated progress pill  (Pause / Resume + left-to-right green fill)
// ─────────────────────────────────────────────────────────────────────────────
class _PauseProgressButton extends StatelessWidget {
  const _PauseProgressButton({
    required this.paused,
    required this.remaining,
    required this.target,
    required this.isTimed,
    required this.preparing,
    required this.prepSeconds,
    required this.onPause,
  });

  final bool paused, isTimed, preparing;
  final int remaining, target, prepSeconds;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final int totalSecs =
        preparing ? prepSeconds : (isTimed ? target : 0);
    final double progress = totalSecs > 0
        ? ((totalSecs - remaining) / totalSecs).clamp(0.0, 1.0)
        : 0.0;
    final bool showProgress = isTimed && !paused && !preparing && totalSecs > 0;

    return GestureDetector(
      onTap: onPause,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: SizedBox(
          height: 56,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Track
              Container(color: const Color(0xFFEEEEEE)),
              // Green fill
              if (showProgress)
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(color: _green.withValues(alpha: 0.85)),
                ),
              // Label
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Colors.black87,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    paused ? 'Resume' : 'Pause',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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

// ─────────────────────────────────────────────────────────────────────────────
// WorkoutSessionView
// ─────────────────────────────────────────────────────────────────────────────

/// Shared ready/exercise/rest presentation, driven by each session's own clock.
class WorkoutSessionView extends StatelessWidget {
  const WorkoutSessionView({
    super.key,
    required this.exercise,
    required this.index,
    required this.count,
    required this.remaining,
    required this.target,
    required this.preparing,
    required this.resting,
    required this.paused,
    required this.onExit,
    required this.onPause,
    required this.onNext,
    required this.onDetails,
    required this.onAddRest,
    required this.onEditRest,
    this.onPrevious,
    this.onSettings,
    this.onMusic,
    this.error,
    this.onRetry,
    this.prepSeconds = 15,
    this.exitLabel = 'Leave workout',
  });

  final ExerciseDefinition exercise;
  final int index, count, remaining, target, prepSeconds;
  final bool preparing, resting, paused;
  final VoidCallback onExit, onPause, onNext, onDetails, onAddRest, onEditRest;
  final VoidCallback? onPrevious, onSettings, onMusic, onRetry;
  final String? error;
  final String exitLabel;

  @override
  Widget build(BuildContext context) {
    final foreground = resting ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: resting ? sessionBlue : Colors.white,

      // ── Bottom bar ──────────────────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        // Extra 20 px bottom so the pill clears the home indicator / bottom edge
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (resting)
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: onAddRest,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white24,
                      ),
                      child: const Text('+20s'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: FilledButton(
                      onPressed: onNext,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: sessionBlue,
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ◀  Previous
                  IconButton.filledTonal(
                    tooltip: 'Previous exercise',
                    onPressed: onPrevious,
                    icon: const Icon(Icons.skip_previous_rounded),
                  ),
                  const SizedBox(width: 12),

                  // ▌▌  Pause / Progress pill
                  Flexible(
                    child: _PauseProgressButton(
                      paused: paused,
                      remaining: remaining,
                      target: target,
                      isTimed: exercise.timed,
                      preparing: preparing,
                      prepSeconds: prepSeconds,
                      onPause: onPause,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ▶  Next — solid green
                  IconButton.filled(
                    tooltip: preparing ? 'Skip preparation' : 'Next exercise',
                    onPressed: onNext,
                    style: IconButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.skip_next_rounded),
                  ),
                ],
              ),

            if (resting)
              TextButton(
                onPressed: onPause,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: Text(paused ? 'Resume' : 'Pause'),
              ),

            if (!resting && !preparing && !exercise.timed)
              TextButton(
                onPressed: onNext,
                child: const Text('Exercise done'),
              ),
          ],
        ),
      ),

      // ── Body ────────────────────────────────────────────────────────────────
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    // Error banner
                    if (error != null)
                      MaterialBanner(
                        content: Text(error!),
                        actions: [
                          TextButton(
                            onPressed: onRetry,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),

                    // ── Avatar card (half screen) ─────────────────────────────
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Top bar: back  |  music  |  settings
                          Row(
                            children: [
                              IconButton(
                                tooltip: exitLabel,
                                onPressed: onExit,
                                icon: const Icon(Icons.arrow_back),
                              ),
                              const Spacer(),
                              // Music button always next to settings
                              if (onMusic != null)
                                IconButton(
                                  tooltip: 'Workout music',
                                  onPressed: onMusic,
                                  icon: const Icon(Icons.music_note_outlined),
                                ),
                              if (onSettings != null)
                                IconButton(
                                  tooltip: 'Workout settings',
                                  onPressed: onSettings,
                                  icon: const Icon(Icons.settings_outlined),
                                ),
                            ],
                          ),

                          // Avatar = 50% of available screen height
                          SizedBox(
                            height: constraints.maxHeight * 0.50,
                            width: double.infinity,
                            child: ChallengeAvatar(
                              exercise: exercise,
                              animate: !paused,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),

                    // ── Info section ─────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          if (resting)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'NEXT ${index + 1}/$count',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                          if (preparing)
                            const Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 12),
                              child: Text(
                                'READY TO GO!',
                                style: TextStyle(
                                  color: sessionBlue,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),

                          // Exercise name + help icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  exercise.name.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: foreground,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Exercise instructions',
                                onPressed: onDetails,
                                icon: Icon(
                                  Icons.help_outline,
                                  size: 19,
                                  color: foreground,
                                ),
                              ),
                              if (resting)
                                Text(
                                  exercise.timed
                                      ? sessionTime(target)
                                      : '× $target',
                                  style: const TextStyle(color: Colors.white),
                                ),
                            ],
                          ),

                          SizedBox(height: resting ? 40 : 20),

                          if (resting)
                            const Text(
                              'REST',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                          // Timer / rep count
                          if (preparing)
                            SizedBox(
                              width: 96,
                              height: 96,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox.expand(
                                    child: CircularProgressIndicator(
                                      value: prepSeconds == 0
                                          ? 0
                                          : (remaining / prepSeconds)
                                              .clamp(0, 1),
                                      strokeWidth: 7,
                                      color: sessionBlue,
                                      backgroundColor: Colors.black12,
                                    ),
                                  ),
                                  Text(
                                    '$remaining',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Text(
                              resting || exercise.timed
                                  ? sessionTime(remaining)
                                  : '× $target',
                              style: TextStyle(
                                color: foreground,
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                          if (paused)
                            Text(
                              'Paused',
                              style: TextStyle(color: foreground),
                            ),

                          if (resting)
                            TextButton(
                              onPressed: onEditRest,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.white12,
                              ),
                              child: const Text('Edit Rest Time'),
                            ),

                          const SizedBox(height: 28),
                        ],
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Rest editor
// ─────────────────────────────────────────────────────────────────────────────

Future<int?> showSessionRestEditor(
  BuildContext context,
  int current,
  int defaultSeconds,
) {
  var seconds = current;
  var custom = current != defaultSeconds;
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, update) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Rest timer',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Default')),
                  ButtonSegment(value: true, label: Text('Custom')),
                ],
                selected: {custom},
                onSelectionChanged: (value) => update(() {
                  custom = value.single;
                  if (!custom) seconds = defaultSeconds;
                }),
              ),
              const SizedBox(height: 28),
              if (!custom) ...[
                const Icon(Icons.coffee_outlined, color: sessionBlue, size: 44),
                const Text(
                  'Smart Rest',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Use the recommended $defaultSeconds-second recovery interval.',
                  textAlign: TextAlign.center,
                ),
              ] else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Shorter rest',
                      onPressed: seconds == 0
                          ? null
                          : () => update(
                                () => seconds = (seconds - 5).clamp(0, 600),
                              ),
                      icon: const Icon(Icons.remove),
                    ),
                    Text('$seconds seconds'),
                    IconButton(
                      tooltip: 'Longer rest',
                      onPressed: seconds == 600
                          ? null
                          : () => update(
                                () => seconds = (seconds + 5).clamp(0, 600),
                              ),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, seconds),
                  style: FilledButton.styleFrom(backgroundColor: sessionBlue),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
