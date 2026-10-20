import 'exercise.dart';

const referenceChallengeId = 'intense_belly_fat_burn_day1';
const referenceChallengeTitle = 'Intense Belly Fat Burn';
const challengeBodySaw = ExerciseDefinition(
  id: 'challenge_body_saw',
  name: 'Body Saw',
  motion: ExerciseMotion.plank,
  area: ExerciseArea.abs,
  focus: {ExerciseFocus.abs, ExerciseFocus.shoulder},
  difficulty: ExerciseDifficulty.medium,
  type: ExerciseType.training,
  equipment: {ExerciseEquipment.none, ExerciseEquipment.mat},
  timed: true,
  target: 30,
  description:
      'From a forearm plank, keep your trunk steady and gently glide your body forward and backward around your planted elbows.',
);

class ChallengeEntry {
  const ChallengeEntry({
    required this.id,
    required this.exerciseId,
    this.seconds = 30,
  });
  final String id, exerciseId;
  final int seconds;
  ExerciseDefinition get base => exerciseId == challengeBodySaw.id
      ? challengeBodySaw
      : exerciseById(exerciseId);
  ExerciseDefinition get exercise => ExerciseDefinition(
    id: base.id,
    name: base.name,
    motion: base.motion,
    area: base.area,
    timed: true,
    target: seconds,
    description: base.description,
    focus: base.focus,
    difficulty: base.difficulty,
    type: base.type,
    equipment: base.equipment,
  );
  ChallengeEntry copyWith({String? exerciseId, int? seconds}) => ChallengeEntry(
    id: id,
    exerciseId: exerciseId ?? this.exerciseId,
    seconds: seconds ?? this.seconds,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseId': exerciseId,
    'seconds': seconds,
  };
  factory ChallengeEntry.fromJson(Map<String, dynamic> json) {
    final entry = ChallengeEntry(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      seconds: json['seconds'] as int,
    );
    if (entry.id.isEmpty || entry.seconds < 5 || entry.seconds > 3600) {
      throw const FormatException('Invalid challenge entry');
    }
    entry.base;
    return entry;
  }
}

List<ChallengeEntry> referenceDayEntries() {
  const ids = [
    'jumping_jacks',
    'oblique_crossover_crunch_left',
    'oblique_crossover_crunch_right',
    'inchworms',
    'single_leg_drops',
    'challenge_body_saw',
    'bicycle_crunches',
    'side_crunches_left',
    'side_crunches_right',
    'jumping_jacks',
    'oblique_crossover_crunch_left',
    'oblique_crossover_crunch_right',
    'inchworms',
    'single_leg_drops',
    'challenge_body_saw',
    'bicycle_crunches',
    'bent_knee_side_hip_raises_left',
    'bent_knee_side_hip_raises_right',
    'cat_cow_pose',
    'lying_twist_stretch_left',
    'lying_twist_stretch_right',
  ];
  return [
    for (var i = 0; i < ids.length; i++)
      ChallengeEntry(id: 'day1-$i', exerciseId: ids[i]),
  ];
}

enum ChallengePhase { prep, exercise, rest, complete }

class ChallengeProgress {
  const ChallengeProgress({
    required this.sessionId,
    required this.index,
    required this.phase,
    required this.remainingMs,
    required this.activeMs,
    this.credited = false,
    this.finishedAt,
  });
  final String sessionId;
  final int index, remainingMs, activeMs;
  final ChallengePhase phase;
  final bool credited;
  final DateTime? finishedAt;
  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'index': index,
    'phase': phase.name,
    'remainingMs': remainingMs,
    'activeMs': activeMs,
    'credited': credited,
    'finishedAt': finishedAt?.toUtc().toIso8601String(),
  };
  factory ChallengeProgress.fromJson(Map<String, dynamic> json) =>
      ChallengeProgress(
        sessionId: json['sessionId'] as String,
        index: json['index'] as int,
        phase: ChallengePhase.values.byName(json['phase'] as String),
        remainingMs: json['remainingMs'] as int,
        activeMs: json['activeMs'] as int,
        credited: json['credited'] as bool,
        finishedAt: json['finishedAt'] == null
            ? null
            : DateTime.parse(json['finishedAt'] as String).toLocal(),
      );
}

class ChallengeDay {
  ChallengeDay({required List<ChallengeEntry> entries, this.progress})
    : entries = List.unmodifiable(entries);
  factory ChallengeDay.initial() =>
      ChallengeDay(entries: referenceDayEntries());
  final List<ChallengeEntry> entries;
  final ChallengeProgress? progress;
  int estimatedMinutes(int rest, int prep) =>
      ((entries.fold<int>(0, (sum, e) => sum + e.seconds) +
                  (entries.length - 1) * rest +
                  prep) /
              60)
          .ceil();
  Map<String, dynamic> toJson() => {
    'version': 1,
    'entries': entries.map((e) => e.toJson()).toList(),
    'progress': progress?.toJson(),
  };
  factory ChallengeDay.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1) {
      throw const FormatException('Unknown challenge version');
    }
    final entries = (json['entries'] as List)
        .map(
          (e) => ChallengeEntry.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
    if (entries.isEmpty ||
        entries.length > 100 ||
        entries.map((e) => e.id).toSet().length != entries.length) {
      throw const FormatException('Invalid challenge plan');
    }
    final progress = json['progress'] == null
        ? null
        : ChallengeProgress.fromJson(
            Map<String, dynamic>.from(json['progress'] as Map),
          );
    if (progress != null &&
        (progress.sessionId.isEmpty ||
            progress.index < 0 ||
            progress.index >= entries.length ||
            progress.remainingMs < 0 ||
            progress.remainingMs > 3600000 ||
            (progress.phase == ChallengePhase.rest &&
                progress.index == entries.length - 1) ||
            (progress.phase == ChallengePhase.exercise &&
                progress.remainingMs >
                    entries[progress.index].seconds * 1000) ||
            progress.activeMs < 0 ||
            (progress.credited && progress.phase != ChallengePhase.complete))) {
      throw const FormatException('Invalid challenge progress');
    }
    return ChallengeDay(entries: entries, progress: progress);
  }
}
