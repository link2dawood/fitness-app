import 'package:flutter/material.dart';
import '../../../data/models/exercise.dart';
import '../../../data/models/training_workout.dart';
import 'training_collection_page.dart';

class StretchWarmUpPage extends StatelessWidget {
  const StretchWarmUpPage({super.key});
  @override
  Widget build(BuildContext context) => TrainingCollectionPage(
    title: 'Stretch & Warm Up',
    workouts: trainingWorkouts
        .where((w) => w.type != ExerciseType.training)
        .toList(),
  );
}
