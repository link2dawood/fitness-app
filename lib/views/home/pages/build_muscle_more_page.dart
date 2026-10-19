import 'package:flutter/material.dart';
import 'training_collection_page.dart';

class BuildMuscleMorePage extends StatelessWidget {
  const BuildMuscleMorePage({super.key});
  @override
  Widget build(BuildContext context) => TrainingCollectionPage(
    title: 'Build Muscle',
    workouts: goalWorkouts('Build Muscle'),
  );
}
