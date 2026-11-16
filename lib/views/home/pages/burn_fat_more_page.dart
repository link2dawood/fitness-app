import 'package:flutter/material.dart';
import '../../../data/models/user_profile.dart';
import 'training_collection_page.dart';
import 'training_profile_builder.dart';

class BurnFatMorePage extends StatelessWidget {
  const BurnFatMorePage({super.key, this.profile});
  final UserProfile? profile;
  @override
  Widget build(BuildContext context) => TrainingProfileBuilder(
    profile: profile,
    builder: (context, current) => TrainingCollectionPage(
      title: 'Burn Fat',
      workouts: goalWorkouts('Burn Fat'),
      gender: current?.gender,
    ),
  );
}
