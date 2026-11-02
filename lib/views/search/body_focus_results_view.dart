import 'package:flutter/material.dart';

import '../../data/models/exercise.dart';
import '../../data/models/training_workout.dart';
import '../workouts/training_workout_page.dart';

/// Data model for a single workout entry shown in the results list.
class WorkoutEntry {
  const WorkoutEntry({
    required this.title,
    required this.durationMins,
    required this.exerciseCount,
    required this.imagePath,
    this.workoutId,
  });

  final String title;
  final int durationMins;
  final int exerciseCount;
  final String imagePath;
  final String? workoutId;
}

/// Map of body-focus label → list of workouts.
const Map<String, List<WorkoutEntry>> bodyFocusWorkouts = {
  'Butt & Leg': [
    WorkoutEntry(
      title: 'Leg Beginner',
      durationMins: 23,
      exerciseCount: 23,
      imagePath: 'assets/images/workouts/lower_body.jpg',
      workoutId: 'leg_beginner',
    ),
    WorkoutEntry(
      title: 'Leg Intermediate',
      durationMins: 31,
      exerciseCount: 36,
      imagePath: 'assets/images/workouts/squat.jpg',
      workoutId: 'leg_intermediate',
    ),
    WorkoutEntry(
      title: 'Leg Advanced',
      durationMins: 40,
      exerciseCount: 43,
      imagePath: 'assets/images/workouts/lower_body.jpg',
      workoutId: 'leg_advanced',
    ),
    WorkoutEntry(
      title: 'Lower Body Strength',
      durationMins: 22,
      exerciseCount: 27,
      imagePath: 'assets/images/workouts/squat.jpg',
      workoutId: 'lower_body',
    ),
    WorkoutEntry(
      title: 'Leg Workout (No Jumping!)',
      durationMins: 13,
      exerciseCount: 13,
      imagePath: 'assets/images/workouts/knee_pain_relief.jpg',
      workoutId: 'lose_fat_no_jumping',
    ),
    WorkoutEntry(
      title: 'Butt Blaster Challenge',
      durationMins: 21,
      exerciseCount: 25,
      imagePath: 'assets/images/workouts/lower_body.jpg',
      workoutId: 'lower_body_challenge',
    ),
    WorkoutEntry(
      title: 'Intense Leg Power Challenge',
      durationMins: 21,
      exerciseCount: 25,
      imagePath: 'assets/images/workouts/discover_warmup_lunge.jpg',
      workoutId: 'lower_body_challenge',
    ),
    WorkoutEntry(
      title: '10 Min Butt Workout',
      durationMins: 10,
      exerciseCount: 12,
      imagePath: 'assets/images/workouts/squat.jpg',
      workoutId: 'legs_glutes',
    ),
    WorkoutEntry(
      title: 'Bigger Strong Quads Leg Workout',
      durationMins: 11,
      exerciseCount: 12,
      imagePath: 'assets/images/workouts/discover_warmup_lunge.jpg',
      workoutId: 'bigger_strong_quads_leg_workout',
    ),
    WorkoutEntry(
      title: 'Shred Your Quads',
      durationMins: 19,
      exerciseCount: 22,
      imagePath: 'assets/images/workouts/squat.jpg',
      workoutId: 'shred_your_quads',
    ),
    WorkoutEntry(
      title: 'Intense Leg Transformation',
      durationMins: 31,
      exerciseCount: 30,
      imagePath: 'assets/images/workouts/lower_body.jpg',
      workoutId: 'intense_leg_transformation',
    ),
    WorkoutEntry(
      title: '10 Min Leg Workout',
      durationMins: 10,
      exerciseCount: 12,
      imagePath: 'assets/images/workouts/stretch_warmup.jpg',
      workoutId: '10_min_leg_workout',
    ),
    WorkoutEntry(
      title: 'Butt Lift & Rounder Booty',
      durationMins: 9,
      exerciseCount: 9,
      imagePath: 'assets/images/workouts/lower_body.jpg',
      workoutId: 'butt_lift_rounder_booty',
    ),
    WorkoutEntry(
      title: 'Rounder Booty Shaping',
      durationMins: 20,
      exerciseCount: 23,
      imagePath: 'assets/images/workouts/squat.jpg',
      workoutId: 'rounder_booty_shaping',
    ),
    WorkoutEntry(
      title: 'Strong Legs Routine',
      durationMins: 13,
      exerciseCount: 12,
      imagePath: 'assets/images/workouts/squat.jpg',
      workoutId: 'strong_legs_routine',
    ),
    WorkoutEntry(
      title: 'Shape and Tighten Butt',
      durationMins: 14,
      exerciseCount: 15,
      imagePath: 'assets/images/workouts/lower_body.jpg',
      workoutId: 'legs_glutes',
    ),
    WorkoutEntry(
      title: 'Bubble Butt Workout',
      durationMins: 12,
      exerciseCount: 13,
      imagePath: 'assets/images/workouts/lower_body.jpg',
      workoutId: 'bubble_butt_workout',
    ),
    WorkoutEntry(
      title: 'Booty Shaping & Butt Lifting',
      durationMins: 30,
      exerciseCount: 32,
      imagePath: 'assets/images/workouts/squat.jpg',
      workoutId: 'rounder_booty_shaping',
    ),
    WorkoutEntry(
      title: 'Butt Beginner',
      durationMins: 15,
      exerciseCount: 15,
      imagePath: 'assets/images/workouts/lower_body.jpg',
      workoutId: 'butt_beginner',
    ),
    WorkoutEntry(
      title: 'Butt Intermediate',
      durationMins: 19,
      exerciseCount: 17,
      imagePath: 'assets/images/workouts/lower_body.jpg',
      workoutId: 'butt_intermediate',
    ),
    WorkoutEntry(
      title: 'Butt Advanced',
      durationMins: 21,
      exerciseCount: 18,
      imagePath: 'assets/images/workouts/lower_body.jpg',
      workoutId: 'butt_advanced',
    ),
  ],
  'Chest': [
    WorkoutEntry(
      title: 'Chest Beginner',
      durationMins: 9,
      exerciseCount: 11,
      imagePath: 'assets/images/workouts/massive_body.jpg',
      workoutId: 'chest_beginner',
    ),
    WorkoutEntry(
      title: 'Chest Intermediate',
      durationMins: 13,
      exerciseCount: 14,
      imagePath: 'assets/images/workouts/massive_body.jpg',
      workoutId: 'chest_intermediate',
    ),
    WorkoutEntry(
      title: 'Chest Advanced',
      durationMins: 18,
      exerciseCount: 16,
      imagePath: 'assets/images/workouts/massive_body.jpg',
      workoutId: 'chest_advanced',
    ),
    WorkoutEntry(
      title: 'Killer Chest Workout',
      durationMins: 29,
      exerciseCount: 25,
      imagePath: 'assets/images/workouts/discover_abs_outdoor.jpg',
      workoutId: 'killer_chest_routine',
    ),
    WorkoutEntry(
      title: 'Get Rid of Man Boobs HIIT - beginner',
      durationMins: 17,
      exerciseCount: 19,
      imagePath: 'assets/images/workouts/discover_12min_classic.jpg',
      workoutId: 'beginner_chest_sculpt',
    ),
    WorkoutEntry(
      title: 'Get Rid of Man Boobs HIIT - intermediate',
      durationMins: 18,
      exerciseCount: 19,
      imagePath: 'assets/images/workouts/discover_12min_classic.jpg',
      workoutId: 'chest_intermediate',
    ),
    WorkoutEntry(
      title: 'Get Rid of Man Boobs HIIT - advanced',
      durationMins: 22,
      exerciseCount: 25,
      imagePath: 'assets/images/workouts/discover_12min_classic.jpg',
      workoutId: 'chest_advanced',
    ),
    WorkoutEntry(
      title: 'Quick Bigger Chest Building',
      durationMins: 11,
      exerciseCount: 12,
      imagePath: 'assets/images/workouts/discover_brutal_hiit.jpg',
      workoutId: 'quick_bigger_chest_building',
    ),
    WorkoutEntry(
      title: 'Beginner Chest Workout',
      durationMins: 7,
      exerciseCount: 8,
      imagePath: 'assets/images/workouts/beginner_chest_workout.jpg',
      workoutId: 'beginner_chest_workout',
    ),
    WorkoutEntry(
      title: 'Killer Chest Routine',
      durationMins: 9,
      exerciseCount: 8,
      imagePath: 'assets/images/workouts/massive_body.jpg',
      workoutId: 'killer_chest_routine',
    ),
  ],
  'Back': [
    WorkoutEntry(
      title: 'Shoulder & Back Beginner',
      durationMins: 15,
      exerciseCount: 17,
      imagePath: 'assets/images/workouts/back_sb.jpg',
      workoutId: 'shoulder_back_beginner',
    ),
    WorkoutEntry(
      title: 'Shoulder & Back Intermediate',
      durationMins: 19,
      exerciseCount: 17,
      imagePath: 'assets/images/workouts/back_builder.jpg',
      workoutId: 'shoulder_back_intermediate',
    ),
    WorkoutEntry(
      title: 'Shoulder & Back Advanced',
      durationMins: 21,
      exerciseCount: 17,
      imagePath: 'assets/images/workouts/back_sb.jpg',
      workoutId: 'shoulder_back_advanced',
    ),
    WorkoutEntry(
      title: 'Beginner Back Builder',
      durationMins: 16,
      exerciseCount: 12,
      imagePath: 'assets/images/workouts/beginner_back_builder.jpg',
      workoutId: 'beginner_back_builder',
    ),
  ],
  'Shoulder': [
    WorkoutEntry(
      title: 'Shoulder & Back Beginner',
      durationMins: 15,
      exerciseCount: 17,
      imagePath: 'assets/images/workouts/back_sb.jpg',
      workoutId: 'shoulder_back_beginner',
    ),
    WorkoutEntry(
      title: 'Shoulder & Back Intermediate',
      durationMins: 19,
      exerciseCount: 17,
      imagePath: 'assets/images/workouts/back_builder.jpg',
      workoutId: 'shoulder_back_intermediate',
    ),
    WorkoutEntry(
      title: 'Shoulder & Back Advanced',
      durationMins: 21,
      exerciseCount: 17,
      imagePath: 'assets/images/workouts/back_sb.jpg',
      workoutId: 'shoulder_back_advanced',
    ),
    WorkoutEntry(
      title: 'Build Wider Shoulders - beginner',
      durationMins: 15,
      exerciseCount: 15,
      imagePath: 'assets/images/workouts/discover_12min_classic.jpg',
      workoutId: 'build_wider_shoulders',
    ),
    WorkoutEntry(
      title: 'Build Wider Shoulders - intermediate',
      durationMins: 17,
      exerciseCount: 20,
      imagePath: 'assets/images/workouts/discover_12min_classic.jpg',
      workoutId: 'build_wider_shoulders_intermediate',
    ),
    WorkoutEntry(
      title: 'Build Wider Shoulders - advanced',
      durationMins: 26,
      exerciseCount: 26,
      imagePath: 'assets/images/workouts/discover_12min_classic.jpg',
      workoutId: 'build_wider_shoulders_advanced',
    ),
  ],
};

/// Screen that displays workouts for a selected body focus area.
/// Navigated to from [SearchView] when the user taps a body focus badge.
class BodyFocusResultsView extends StatelessWidget {
  const BodyFocusResultsView({super.key, required this.focusLabel});

  /// The body focus label, e.g. "Butt & Leg", "Back", "Arm", "Chest".
  final String focusLabel;

  List<WorkoutEntry> get _workouts => bodyFocusWorkouts[focusLabel] ?? const [];

  @override
  Widget build(BuildContext context) {
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
              child: _workouts.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _workouts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _WorkoutCard(entry: _workouts[index]),
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
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.entry});

  final WorkoutEntry entry;

  TrainingWorkout _resolveWorkout() {
    final normalizedTitle = entry.title.toLowerCase();
    for (final w in trainingWorkouts) {
      if (w.title.toLowerCase() == normalizedTitle) {
        return w;
      }
    }
    if (entry.workoutId != null) {
      for (final w in trainingWorkouts) {
        if (w.id == entry.workoutId) {
          return TrainingWorkout(
            id: w.id,
            title: entry.title,
            difficulty: w.difficulty,
            type: w.type,
            image: entry.imagePath,
            exerciseIds: w.exerciseIds,
            targets: w.targets,
            restSeconds: w.restSeconds,
            planVersion: w.planVersion,
          );
        }
      }
    }
    return TrainingWorkout(
      id: entry.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_'),
      title: entry.title,
      difficulty: ExerciseDifficulty.medium,
      type: ExerciseType.training,
      image: entry.imagePath,
      exerciseIds: trainingWorkouts.first.exerciseIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F7FA),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => openTrainingWorkout(context, _resolveWorkout()),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Inset rounded-square thumbnail matching reference style
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  entry.imagePath,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),

              // Title and duration · exercise count
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${entry.durationMins} mins · ${entry.exerciseCount} exercises',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
