import 'package:flutter/material.dart';
import '../data/models/challenge_poster.dart';
import 'challenge_poster_card.dart';
import '../data/models/user_profile.dart';
import '../data/models/training_workout.dart';
import '../views/workouts/training_workout_page.dart';

const trainingCardBlue = Color(0xFF0062FF);

/// Content-sized versions of the original illustrated Training cards.
class TrainingChallengeCard extends StatelessWidget {
  const TrainingChallengeCard({
    super.key,
    required this.workout,
    this.customized = false,
    this.color = trainingCardBlue,
    this.compact = true,
    this.gender,
  });
  final TrainingWorkout workout;
  final Gender? gender;
  final bool customized;
  final Color color;
  final bool compact;
  @override
  Widget build(BuildContext context) => ChallengePosterCard(
    title: challengePosterTitle(workout),
    kicker: customized ? 'CUSTOMIZED FOR YOU' : 'CHALLENGE',
    description: challengePosterDescription(workout),
    metadata:
        '~${workout.estimatedMinutes} min • ${workout.exerciseIds.length} exercises • ${workout.difficulty.label}',
    image: challengePosterArtwork(workout, gender),
    color: customized ? color : challengePosterColor(workout.id),
    actionLabel: 'START WORKOUT',
    onTap: () => openTrainingWorkout(
      context,
      workout,
      challengeImage: challengePosterArtwork(workout, gender),
    ),
  );
}

class TrainingCustomCard extends StatelessWidget {
  const TrainingCustomCard({super.key, required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Create your own workout',
    onTap: onTap,
    child: ExcludeSemantics(
      child: Material(
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        color: trainingCardBlue,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFF004BD6)],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CREATE\nYOUR OWN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          'GO',
                          style: TextStyle(
                            color: trainingCardBlue,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class TrainingPhotoCard extends StatelessWidget {
  const TrainingPhotoCard({
    super.key,
    required this.title,
    required this.image,
    required this.subtitle,
    required this.onTap,
    this.recommended = false,
    this.collage = false,
    this.compact = false,
    this.actionLabel,
  });
  final String title, image, subtitle;
  final VoidCallback onTap;
  final bool recommended, collage, compact;
  final String? actionLabel;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$title. $subtitle',
    onTap: onTap,
    child: ExcludeSemantics(
      child: Material(
        borderRadius: BorderRadius.circular(compact ? 20 : 22),
        clipBehavior: Clip.antiAlias,
        color: recommended ? const Color(0xFF86B5E7) : Colors.black,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            alignment: compact
                ? AlignmentDirectional.bottomStart
                : AlignmentDirectional.topStart,
            children: [
              Positioned.fill(
                child: collage
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final path in [
                            'assets/images/workouts/hiit_fat_burning.jpg',
                            'assets/images/workouts/dumbbell_abs_shaper.jpg',
                            'assets/images/workouts/massive_body.jpg',
                          ])
                            Expanded(
                              child: Image.asset(path, fit: BoxFit.cover),
                            ),
                        ],
                      )
                    : Image.asset(
                        image,
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                      ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: compact
                          ? Alignment.bottomCenter
                          : Alignment.centerLeft,
                      end: compact
                          ? Alignment.topCenter
                          : Alignment.centerRight,
                      colors: recommended
                          ? [
                              const Color(0xFF548FD2),
                              const Color(0xFF548FD2).withValues(alpha: .35),
                            ]
                          : compact
                          ? [
                              Colors.black.withValues(alpha: .9),
                              Colors.black.withValues(alpha: .55),
                              Colors.black.withValues(alpha: .05),
                            ]
                          : [
                              Colors.black.withValues(alpha: .8),
                              Colors.black.withValues(alpha: .25),
                            ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(compact ? 14 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (recommended) ...[
                      const Text(
                        'RECOMMENDED FOR YOU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Text(
                      title,
                      maxLines: compact ? 2 : null,
                      overflow: compact ? TextOverflow.ellipsis : null,
                      style: TextStyle(
                        fontSize: compact
                            ? 17
                            : (recommended || collage ? 23 : 19),
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: compact ? 6 : 12),
                    Text(
                      subtitle,
                      maxLines: compact ? 3 : null,
                      overflow: compact ? TextOverflow.ellipsis : null,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 12 : 14,
                        height: compact ? 1.3 : 1.4,
                      ),
                    ),
                    if (actionLabel != null) ...[
                      SizedBox(height: compact ? 10 : 16),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 16 : 20,
                          vertical: compact ? 7 : 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          actionLabel!,
                          style: TextStyle(
                            fontSize: compact ? 11 : 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
