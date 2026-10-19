import 'package:flutter/material.dart';
import '../../../data/models/exercise.dart';
import '../../../data/models/training_workout.dart';
import 'training_collection_page.dart';
import 'training_profile_builder.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/training_recommendations.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key, this.profile});
  final UserProfile? profile;
  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  String category = 'All';
  @override
  Widget build(BuildContext context) {
    final routines = trainingWorkouts
        .where(
          (w) => w.title.toLowerCase().contains(
            RegExp('challenge|shred|calisthenics|ripped'),
          ),
        )
        .where((w) {
          final name = w.title.toLowerCase();
          return switch (category) {
            'Abs' => w.focus.contains(ExerciseFocus.abs),
            'Upper Body' => w.focus.any(
              (e) => [
                ExerciseFocus.arm,
                ExerciseFocus.chest,
                ExerciseFocus.shoulder,
                ExerciseFocus.back,
              ].contains(e),
            ),
            'Lower Body' => w.focus.any(
              (e) => [ExerciseFocus.leg, ExerciseFocus.glutes].contains(e),
            ),
            'Dumbbell' => w.equipment.contains(ExerciseEquipment.dumbbell),
            'Calisthenics' => name.contains('calisthenics'),
            'Lose Weight' => name.contains(RegExp('lose|burn|shred')),
            'Build Muscle' => name.contains(RegExp('muscle|body|ripped')),
            'Full Body' => w.focus.length > 3,
            _ => true,
          };
        })
        .toList();
    return TrainingProfileBuilder(
      profile: widget.profile,
      builder: (context, profile) {
        final recommended = TrainingRecommendations.forProfile(profile);
        return Scaffold(
          appBar: AppBar(title: const Text('Challenge')),
          body: CustomScrollView(
            slivers: [
              if (category == 'All')
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customized for you',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        if (recommended.isEmpty)
                          const Text(
                            'Complete your fitness profile to see personalized workouts.',
                          )
                        else
                          TrainingWorkoutTile(workout: recommended.first),
                      ],
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final value in [
                        'All',
                        'Lose Weight',
                        'Build Muscle',
                        'Full Body',
                        'Abs',
                        'Upper Body',
                        'Lower Body',
                        'Calisthenics',
                        'Dumbbell',
                      ])
                        ChoiceChip(
                          label: Text(value),
                          selected: value == category,
                          onSelected: (_) => setState(() => category = value),
                        ),
                    ],
                  ),
                ),
              ),
              if (routines.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No routines match this category.'),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.builder(
                  itemCount: routines.length,
                  itemBuilder: (_, i) =>
                      TrainingWorkoutTile(workout: routines[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
