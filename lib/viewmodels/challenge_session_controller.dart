import 'package:flutter/foundation.dart';
import '../data/models/challenge_day.dart';

class ChallengeSessionController extends ChangeNotifier {
  ChallengeSessionController({
    required this.day,
    required this.prepSeconds,
    required this.restSeconds,
    bool restart = false,
    String? sessionId,
  }) {
    final saved = restart ? null : day.progress;
    id =
        saved?.sessionId ??
        sessionId ??
        DateTime.now().toUtc().microsecondsSinceEpoch.toString();
    index = saved?.index ?? 0;
    phase =
        saved?.phase ??
        (prepSeconds == 0 ? ChallengePhase.exercise : ChallengePhase.prep);
    remainingMs =
        saved?.remainingMs ??
        (phase == ChallengePhase.prep
                ? prepSeconds
                : day.entries.first.seconds) *
            1000;
    activeMs = saved?.activeMs ?? 0;
    credited = saved?.credited ?? false;
    finishedAt = saved?.finishedAt;
    paused = saved != null && phase != ChallengePhase.complete;
  }
  final ChallengeDay day;
  final int prepSeconds;
  int restSeconds;
  late String id;
  late int index, remainingMs, activeMs;
  late ChallengePhase phase;
  late bool paused, credited;
  DateTime? finishedAt;
  int get displayIndex => phase == ChallengePhase.rest
      ? (index + 1).clamp(0, day.entries.length - 1)
      : index;
  int get remainingSeconds => (remainingMs / 1000).ceil();
  double get progress => phase == ChallengePhase.complete
      ? 1
      : ((index +
                    (phase == ChallengePhase.rest
                        ? 1
                        : phase == ChallengePhase.exercise
                        ? 1 - remainingMs / (day.entries[index].seconds * 1000)
                        : 0)) /
                day.entries.length)
            .clamp(0, 1);
  void tick(Duration elapsed) {
    if (paused ||
        phase == ChallengePhase.complete ||
        elapsed <= Duration.zero) {
      return;
    }
    var ms = elapsed.inMilliseconds;
    while (ms > 0 && phase != ChallengePhase.complete) {
      final used = ms < remainingMs ? ms : remainingMs;
      remainingMs -= used;
      activeMs += used;
      ms -= used;
      if (remainingMs == 0) _advance();
    }
    notifyListeners();
  }

  void _advance() {
    if (phase == ChallengePhase.prep) {
      phase = ChallengePhase.exercise;
      remainingMs = day.entries[index].seconds * 1000;
    } else if (phase == ChallengePhase.exercise) {
      if (index == day.entries.length - 1) {
        phase = ChallengePhase.complete;
        remainingMs = 0;
        finishedAt = DateTime.now();
      } else if (restSeconds > 0) {
        phase = ChallengePhase.rest;
        remainingMs = restSeconds * 1000;
      } else {
        index++;
        remainingMs = day.entries[index].seconds * 1000;
      }
    } else if (phase == ChallengePhase.rest) {
      index++;
      phase = ChallengePhase.exercise;
      remainingMs = day.entries[index].seconds * 1000;
    }
  }

  void next() {
    if (phase == ChallengePhase.complete) return;
    _advance();
    notifyListeners();
  }

  void previous() {
    if (phase == ChallengePhase.complete) return;
    if (phase != ChallengePhase.rest && index > 0) index--;
    phase = ChallengePhase.exercise;
    remainingMs = day.entries[index].seconds * 1000;
    notifyListeners();
  }

  void pause([bool value = true]) {
    if (phase == ChallengePhase.complete) return;
    paused = value;
    notifyListeners();
  }

  void addRest() {
    if (phase == ChallengePhase.rest) {
      remainingMs = (remainingMs + 20000).clamp(0, 3600000);
      notifyListeners();
    }
  }

  void setRest(int seconds) {
    restSeconds = seconds.clamp(0, 600);
    if (phase == ChallengePhase.rest) remainingMs = restSeconds * 1000;
    notifyListeners();
  }

  ChallengeDay snapshot() => ChallengeDay(
    entries: day.entries,
    progress: ChallengeProgress(
      sessionId: id,
      index: index,
      phase: phase,
      remainingMs: remainingMs,
      activeMs: activeMs,
      credited: credited,
      finishedAt: finishedAt,
    ),
  );
}
