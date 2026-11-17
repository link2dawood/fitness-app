import 'package:flutter/material.dart';
import '../../../data/models/exercise.dart';
import '../../../data/models/training_workout.dart';
import '../../../data/models/challenge_artwork.dart';
import '../../../data/models/female_search_artwork.dart';
import '../../../data/models/user_profile.dart';
import '../../workouts/training_workout_page.dart';
import '../../workouts/challenge_day_page.dart';

class TrainingCollectionPage extends StatelessWidget {
  const TrainingCollectionPage({
    super.key,
    required this.title,
    required this.workouts,
    this.gender,
    this.useReferenceChallengeDay = false,
    this.artwork = const {},
  });
  final String title;
  final List<TrainingWorkout> workouts;
  final Gender? gender;
  final bool useReferenceChallengeDay;
  final Map<String, String> artwork;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workouts.length,
      itemBuilder: (context, i) => TrainingWorkoutTile(
        workout: workouts[i],
        gender: gender,
        imagePath: gender == Gender.female
            ? femaleSearchArtwork(workouts[i])
            : artwork[workouts[i].id],
        onOpen:
            useReferenceChallengeDay &&
                gender != Gender.female &&
                workouts[i].id == 'intense_belly_fat_burn'
            ? () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const ChallengeDayPage()),
              )
            : null,
      ),
    ),
  );
}

class TrainingWorkoutTile extends StatelessWidget {
  const TrainingWorkoutTile({
    super.key,
    required this.workout,
    this.gender,
    this.onOpen,
    this.imagePath,
    this.largeThumbnail = false,
  });
  final TrainingWorkout workout;
  final Gender? gender;
  final VoidCallback? onOpen;
  final String? imagePath;
  final bool largeThumbnail;
  VoidCallback _open(BuildContext context) =>
      onOpen ??
      () => openTrainingWorkout(
        context,
        workout,
        imageOverride: gender == Gender.female
            ? imagePath ?? femaleSearchArtwork(workout)
            : null,
      );

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    button: true,
    label: 'Open workout: ${workout.title}. ${workout.summary}',
    onTap: _open(context),
    child: ExcludeSemantics(
      child: MediaQuery.textScalerOf(context).scale(16) > 24
          ? Card(
              child: InkWell(
                onTap: _open(context),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(workout.summary),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
            )
          : largeThumbnail
          ? InkWell(
              onTap: _open(context),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        imagePath ??
                            (gender == Gender.female
                                ? femaleSearchArtwork(workout)
                                : challengeArtwork(workout, gender)),
                        cacheWidth: 256,
                        width: 86,
                        height: 86,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${workout.estimatedMinutes} mins • ${workout.exerciseIds.length} Exercises',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              for (var i = 0; i < 3; i++)
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 18,
                                  color: i <= workout.difficulty.index
                                      ? const Color(0xFF0057F5)
                                      : const Color(0xFFDADDE3),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: SizedBox(
                  width: 56,
                  height: 56,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagePath ??
                          (gender == Gender.female
                              ? femaleSearchArtwork(workout)
                              : challengeArtwork(workout, gender)),
                      cacheWidth: 224,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(
                            color: Color(0xFFE8ECF2),
                            child: Icon(Icons.fitness_center, size: 24),
                          ),
                    ),
                  ),
                ),
                title: Text(workout.title),
                subtitle: Text(workout.summary),
                trailing: const Icon(Icons.chevron_right),
                onTap: _open(context),
              ),
            ),
    ),
  );
}

List<TrainingWorkout> goalWorkouts(String goal) => trainingWorkouts
    .where(
      (w) => goal == 'Keep Fit'
          ? w.type != ExerciseType.training
          : goal == 'Burn Fat'
          ? w.title.toLowerCase().contains(
              RegExp('hiit|burn|shred|tabata|lose'),
            )
          : w.type == ExerciseType.training,
    )
    .toList();
