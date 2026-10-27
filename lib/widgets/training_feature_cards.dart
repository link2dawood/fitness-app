import 'package:flutter/material.dart';
import '../data/models/exercise.dart';
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
  });
  final TrainingWorkout workout;
  final bool customized;
  final Color color;
  final bool compact;
  Widget stat(
    IconData icon,
    String value,
    String caption, {
    bool compact = false,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: compact ? 16 : 20, color: Colors.white),
      SizedBox(width: compact ? 6 : 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              maxLines: compact ? 1 : null,
              overflow: compact ? TextOverflow.ellipsis : null,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: compact ? 12 : 14,
              ),
            ),
            Text(
              caption,
              maxLines: compact ? 1 : null,
              overflow: compact ? TextOverflow.ellipsis : null,
              style: TextStyle(
                color: Colors.white70,
                fontSize: compact ? 10 : 12,
              ),
            ),
          ],
        ),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    final equipment = workout.equipment
        .where((e) => e != ExerciseEquipment.none && e != ExerciseEquipment.mat)
        .map((e) => e.label)
        .join(', ');
    final large = MediaQuery.textScalerOf(context).scale(16) > 22;
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 7 : 8,
            vertical: compact ? 3 : 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFDFB5),
            borderRadius: BorderRadius.circular(compact ? 5 : 6),
          ),
          child: Text(
            customized ? 'CUSTOMIZED FOR YOU' : 'CHALLENGE',
            style: TextStyle(
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
        SizedBox(height: compact ? 6 : 12),
        Text(
          workout.title.toUpperCase(),
          maxLines: compact ? 2 : null,
          overflow: compact ? TextOverflow.ellipsis : null,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 16 : 22,
            height: 1.15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.black, .25)!],
        ),
        borderRadius: BorderRadius.circular(compact ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (large) ...[
            title,
            SizedBox(height: compact ? 8 : 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(compact ? 10 : 14),
              child: Image.asset(
                customized
                    ? 'assets/images/ui/plan_athlete.jpg'
                    : workout.image,
                height: compact ? 70 : 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: title),
                SizedBox(width: compact ? 8 : 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(compact ? 10 : 14),
                  child: Image.asset(
                    customized
                        ? 'assets/images/ui/plan_athlete.jpg'
                        : workout.image,
                    width: compact ? 56 : 94,
                    height: compact ? 56 : 110,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          SizedBox(height: compact ? 10 : 20),
          for (
            var row = 0;
            row < (compact ? (large ? 2 : 1) : (large ? 4 : 2));
            row++
          ) ...[
            if (row > 0) SizedBox(height: compact ? 6 : 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var column = 0; column < (large ? 1 : 2); column++) ...[
                  if (column > 0) SizedBox(width: compact ? 8 : 12),
                  Expanded(
                    child: switch (row * (large ? 1 : 2) + column) {
                      0 => stat(
                        Icons.schedule,
                        '~${workout.estimatedMinutes} min',
                        'Workout time',
                        compact: compact,
                      ),
                      1 =>
                        compact
                            ? stat(
                                Icons.track_changes,
                                workout.focus
                                    .map((f) => f.label)
                                    .take(2)
                                    .join(' & '),
                                'Target area',
                                compact: compact,
                              )
                            : stat(
                                Icons.bar_chart,
                                workout.difficulty.label,
                                'Level',
                                compact: compact,
                              ),
                      2 => stat(
                        Icons.track_changes,
                        workout.focus.map((f) => f.label).take(2).join(' & '),
                        'Target area',
                        compact: compact,
                      ),
                      _ => stat(
                        Icons.fitness_center,
                        equipment.isEmpty ? 'No equipment' : equipment,
                        'Equipment',
                        compact: compact,
                      ),
                    },
                  ),
                ],
              ],
            ),
          ],
          SizedBox(height: compact ? 8 : 16),
          Text(
            compact
                ? '${workout.exerciseIds.length} exercises with animations'
                : '${workout.exerciseIds.length} exercises with animated demonstrations',
            maxLines: compact ? 1 : null,
            overflow: compact ? TextOverflow.ellipsis : null,
            style: TextStyle(
              color: Colors.white.withValues(alpha: compact ? 0.85 : 1.0),
              fontSize: compact ? 11 : 14,
              height: compact ? 1.2 : 1.4,
            ),
          ),
          SizedBox(height: compact ? 10 : 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
                minimumSize: Size(0, compact ? 36 : 48),
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 16,
                  vertical: compact ? 6 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(compact ? 20 : 24),
                ),
              ),
              onPressed: () => openTrainingWorkout(context, workout),
              icon: Icon(Icons.arrow_circle_right, size: compact ? 16 : 20),
              label: Text(
                'START WORKOUT',
                style: TextStyle(
                  fontSize: compact ? 11 : 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
                      colors: recommended
                          ? [
                              const Color(0xFF548FD2),
                              const Color(0xFF548FD2).withValues(alpha: .35),
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
                      maxLines: compact ? 2 : null,
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
