import 'package:flutter/material.dart';
import '../../../data/models/exercise.dart';
import '../../../data/models/training_workout.dart';
import '../../workouts/training_workout_page.dart';

class TrainingCollectionPage extends StatelessWidget {
  const TrainingCollectionPage({
    super.key,
    required this.title,
    required this.workouts,
  });
  final String title;
  final List<TrainingWorkout> workouts;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workouts.length,
      itemBuilder: (_, i) => TrainingWorkoutTile(workout: workouts[i]),
    ),
  );
}

class TrainingWorkoutTile extends StatelessWidget {
  const TrainingWorkoutTile({super.key, required this.workout});
  final TrainingWorkout workout;
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    button: true,
    label: 'Open workout: ${workout.title}. ${workout.summary}',
    onTap: () => openTrainingWorkout(context, workout),
    child: ExcludeSemantics(
      child: MediaQuery.textScalerOf(context).scale(16) > 24
          ? Card(
              child: InkWell(
                onTap: () => openTrainingWorkout(context, workout),
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
                    workout.image,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(workout.title),
                subtitle: Text(workout.summary),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openTrainingWorkout(context, workout),
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
