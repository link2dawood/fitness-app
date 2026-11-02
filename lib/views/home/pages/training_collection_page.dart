import 'package:flutter/material.dart';
import '../../../data/models/exercise.dart';
import '../../../data/models/training_workout.dart';
import '../../../data/models/challenge_artwork.dart';
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
  });
  final String title;
  final List<TrainingWorkout> workouts;
  final Gender? gender;
  final bool useReferenceChallengeDay;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workouts.length,
      itemBuilder: (context, i) => TrainingWorkoutTile(
        workout: workouts[i],
        gender: gender,
        onOpen:
            useReferenceChallengeDay &&
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
  });
  final TrainingWorkout workout;
  final Gender? gender;
  final VoidCallback? onOpen;
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    button: true,
    label: 'Open workout: ${workout.title}. ${workout.summary}',
    onTap: onOpen ?? () => openTrainingWorkout(context, workout),
    child: ExcludeSemantics(
      child: MediaQuery.textScalerOf(context).scale(16) > 24
          ? Card(
              child: InkWell(
                onTap: onOpen ?? () => openTrainingWorkout(context, workout),
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
          : Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    challengeArtwork(workout, gender),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(workout.title),
                subtitle: Text(workout.summary),
                trailing: const Icon(Icons.chevron_right),
                onTap: onOpen ?? () => openTrainingWorkout(context, workout),
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
