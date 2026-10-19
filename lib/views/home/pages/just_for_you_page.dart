import 'package:flutter/material.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/training_recommendations.dart';
import 'training_collection_page.dart';
import 'training_profile_builder.dart';

class JustForYouPage extends StatelessWidget {
  const JustForYouPage({super.key, this.profile});
  final UserProfile? profile;
  @override
  Widget build(BuildContext context) => TrainingProfileBuilder(
    profile: profile,
    builder: (context, current) {
      final workouts = TrainingRecommendations.forProfile(current);
      if (workouts.isEmpty) {
        return Scaffold(
          appBar: AppBar(title: const Text('Just For You')),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Complete your fitness profile to see personalized workouts.',
              ),
            ),
          ),
        );
      }
      return TrainingCollectionPage(
        title: 'Just For You',
        workouts: workouts.take(12).toList(),
      );
    },
  );
}
