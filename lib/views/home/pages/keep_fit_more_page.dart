import 'package:flutter/material.dart';
import 'training_collection_page.dart';

class KeepFitMorePage extends StatelessWidget {
  const KeepFitMorePage({super.key});
  @override
  Widget build(BuildContext context) => TrainingCollectionPage(
    title: 'Keep Fit',
    workouts: goalWorkouts('Keep Fit'),
  );
}
