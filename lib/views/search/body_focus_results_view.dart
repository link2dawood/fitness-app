import 'package:flutter/material.dart';

import '../../data/models/female_search_artwork.dart';
import '../../data/models/training_workout.dart';
import '../../data/models/user_profile.dart';
import '../home/pages/training_collection_page.dart';

/// Stable catalog workout IDs for each body-focus badge.
const bodyFocusWorkouts = <String, List<String>>{
  'Butt & Leg': [
    'leg_beginner',
    'leg_intermediate',
    'leg_advanced',
    'lower_body_strength',
    'leg_workout_no_jumping',
    'butt_blaster_challenge',
    'intense_leg_power_challenge',
    '10_min_butt_workout',
    'bigger_strong_quads_leg_workout',
    'shred_your_quads',
    'intense_leg_transformation',
    '10_min_leg_workout',
    'butt_lift_rounder_booty',
    'rounder_booty_shaping',
    'strong_legs_routine',
    'shape_and_tighten_butt',
    'bubble_butt_workout',
    'booty_shaping_butt_lifting',
    'butt_beginner',
    'butt_intermediate',
    'butt_advanced',
  ],
  'Chest': [
    'chest_beginner',
    'chest_intermediate',
    'chest_advanced',
    'killer_chest_workout',
    'man_boobs_hiit_beginner',
    'man_boobs_hiit_intermediate',
    'man_boobs_hiit_advanced',
    'quick_bigger_chest_building',
    'beginner_chest_workout',
    'killer_chest_routine',
  ],
  'Back': [
    'shoulder_back_beginner',
    'shoulder_back_intermediate',
    'shoulder_back_advanced',
    'beginner_back_builder',
  ],
  'Shoulder': [
    'shoulder_back_beginner',
    'shoulder_back_intermediate',
    'shoulder_back_advanced',
    'build_wider_shoulders',
    'build_wider_shoulders_intermediate',
    'build_wider_shoulders_strength',
  ],
};

/// Screen that displays workouts for a selected body focus area.
/// Navigated to from [SearchView] when the user taps a body focus badge.
class BodyFocusResultsView extends StatelessWidget {
  const BodyFocusResultsView({
    super.key,
    required this.focusLabel,
    this.gender,
    this.workoutIds,
  });

  /// The body focus label, e.g. "Butt & Leg", "Back", "Arm", "Chest".
  final String focusLabel;
  final Gender? gender;
  final List<String>? workoutIds;

  @override
  Widget build(BuildContext context) {
    final ids = workoutIds ?? bodyFocusWorkouts[focusLabel] ?? const [];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF111827),
                      size: 24,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      focusLabel,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Workout List
            Expanded(
              child: ids.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: ids.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _buildWorkout(context, ids[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: 56,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts yet for $focusLabel',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkout(BuildContext context, String id) {
    final workout = trainingWorkouts.where((item) => item.id == id).firstOrNull;
    if (workout == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Workout unavailable'),
        ),
      );
    }

    return TrainingWorkoutTile(
      workout: workout,
      gender: gender,
      imagePath: gender == Gender.female
          ? femaleSearchArtwork(workout, focusLabel: focusLabel)
          : null,
    );
  }
}
