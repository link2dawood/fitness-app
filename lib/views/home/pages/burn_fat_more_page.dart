import 'package:flutter/material.dart';
import 'training_collection_page.dart';

class BurnFatMorePage extends StatelessWidget {
  const BurnFatMorePage({super.key});
  @override
  Widget build(BuildContext context) => TrainingCollectionPage(
    title: 'Burn Fat',
    workouts: goalWorkouts('Burn Fat'),
  );
}
