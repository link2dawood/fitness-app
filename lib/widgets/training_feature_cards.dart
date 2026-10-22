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
  });
  final TrainingWorkout workout;
  final bool customized;
  final Color color;
  Widget stat(IconData icon, String value, String caption) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: Colors.white),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              caption,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
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
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFDFB5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            customized ? 'CUSTOMIZED FOR YOU' : 'CHALLENGE',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          workout.title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            height: 1.15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.black, .25)!],
        ),
        borderRadius: BorderRadius.circular(24),
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
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                customized
                    ? 'assets/images/ui/plan_athlete.jpg'
                    : workout.image,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: title),
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    customized
                        ? 'assets/images/ui/plan_athlete.jpg'
                        : workout.image,
                    width: 94,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          for (var row = 0; row < (large ? 4 : 2); row++) ...[
            if (row > 0) const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var column = 0; column < (large ? 1 : 2); column++) ...[
                  if (column > 0) const SizedBox(width: 12),
                  Expanded(
                    child: switch (row * (large ? 1 : 2) + column) {
                      0 => stat(
                        Icons.schedule,
                        '~${workout.estimatedMinutes} min',
                        'Workout time',
                      ),
                      1 => stat(
                        Icons.bar_chart,
                        workout.difficulty.label,
                        'Level',
                      ),
                      2 => stat(
                        Icons.track_changes,
                        workout.focus.map((f) => f.label).take(2).join(' & '),
                        'Target area',
                      ),
                      _ => stat(
                        Icons.fitness_center,
                        equipment.isEmpty ? 'No equipment' : equipment,
                        'Equipment',
                      ),
                    },
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 16),
          Text(
            '${workout.exerciseIds.length} exercises with animated demonstrations',
            style: const TextStyle(color: Colors.white, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
                minimumSize: const Size(0, 48),
              ),
              onPressed: () => openTrainingWorkout(context, workout),
              icon: const Icon(Icons.arrow_circle_right),
              label: const Text('START WORKOUT'),
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
    this.actionLabel,
  });
  final String title, image, subtitle;
  final VoidCallback onTap;
  final bool recommended, collage;
  final String? actionLabel;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$title. $subtitle',
    onTap: onTap,
    child: ExcludeSemantics(
      child: Material(
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        color: recommended ? const Color(0xFF86B5E7) : Colors.black,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned.fill(
                child: collage
                    ? Row(
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
                padding: const EdgeInsets.all(20),
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
                      style: TextStyle(
                        fontSize: recommended || collage ? 23 : 19,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white, height: 1.4),
                    ),
                    if (actionLabel != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          actionLabel!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
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
