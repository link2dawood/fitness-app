import 'package:flutter/material.dart';
import '../../../data/models/exercise.dart';
import '../../../data/models/training_workout.dart';
import '../../../data/models/user_profile.dart';
import 'training_collection_page.dart';
import 'training_profile_builder.dart';

class StretchWarmUpPage extends StatelessWidget {
  const StretchWarmUpPage({super.key, this.profile});
  final UserProfile? profile;
  @override
  Widget build(BuildContext context) => TrainingProfileBuilder(
    profile: profile,
    builder: (context, current) => TrainingCollectionPage(
      title: 'Stretch & Warm Up',
      workouts: trainingWorkouts
          .where((w) => w.type != ExerciseType.training)
          .toList(),
      gender: current?.gender,
    ),
  );
}
