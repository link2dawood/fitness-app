import 'package:flutter/material.dart';
import '../data/models/training_workout.dart';
import '../views/workouts/training_workout_page.dart';

class ChallengeCardWidgets {
  static Widget buildCustomizedChallengeCard({
    required String levelText,
    required String targetAreaText,
    double? width = 295,
  }) => _card('Full Body Shred', width: width);
  static Widget buildGenericChallengeCard({
    required String topText,
    required String titleText,
    required String description,
    required Color baseColor,
    required String imagePath,
    double? width = 295,
  }) => _card(titleText.replaceAll(RegExp(r'\s+'), ' ').trim(), width: width);
  static Widget _card(String title, {double? width}) => Builder(
    builder: (context) {
      final matches = trainingWorkouts
          .where((w) => w.title.toLowerCase() == title.toLowerCase())
          .toList();
      return SizedBox(
        width: width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (matches.isEmpty)
                  const Text('This routine is not available yet.')
                else ...[
                  Text(matches.first.summary),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        openTrainingWorkout(context, matches.first),
                    child: const Text('View workout'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}
