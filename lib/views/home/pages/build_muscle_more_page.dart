import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BuildMuscleMorePage extends StatelessWidget {
  const BuildMuscleMorePage({super.key});

  static const List<Map<String, String>> _workouts = [
    {
      'title': 'Intense Belly Fat Burn',
      'subtitle': '14 days plan',
      'image': 'assets/images/workouts/abs.jpg',
    },
    {
      'title': 'Get ripped with dumbbell',
      'subtitle': '30 days plan',
      'image': 'assets/images/workouts/dumbbell_abs_shaper.jpg',
    },
    {
      'title': 'Full body challenge',
      'subtitle': '28 days plan',
      'image': 'assets/images/workouts/full_body_muscle_growth.jpg',
    },
    {
      'title': 'Massive Body Challenge',
      'subtitle': '28 days plan',
      'image': 'assets/images/workouts/massive_body.jpg',
    },
    {
      'title': 'LOWER BODY',
      'subtitle': '28 days plan',
      'image': 'assets/images/workouts/lower_body.jpg',
    },
    {
      'title': 'Build Wider Shoulders - intermediate',
      'subtitle': '17 mins · 20 exercises',
      'image': 'assets/images/workouts/back_sb.jpg',
    },
    {
      'title': 'Build Wider Shoulders - advanced',
      'subtitle': '26 mins · 26 exercises',
      'image': 'assets/images/workouts/back_sb.jpg',
    },
    {
      'title': 'Quick Bigger Chest Building',
      'subtitle': '11 mins · 12 exercises',
      'image': 'assets/images/workouts/beginner_chest_workout.jpg',
    },
    {
      'title': 'Beginner Chest Workout',
      'subtitle': '7 mins · 8 exercises',
      'image': 'assets/images/workouts/beginner_chest_workout.jpg',
    },
    {
      'title': 'Arm Building Circuit',
      'subtitle': '21 mins · 24 exercises',
      'image': 'assets/images/workouts/stretch_shoulder.jpg',
    },
    {
      'title': 'Intense Leg Transformation',
      'subtitle': '31 mins · 30 exercises',
      'image': 'assets/images/workouts/massive_body.jpg',
    },
    {
      'title': 'Rounder Booty Shaping',
      'subtitle': '20 mins · 23 exercises',
      'image': 'assets/images/workouts/squat.jpg',
    },
    {
      'title': 'Killer Chest Routine',
      'subtitle': '9 mins · 8 exercises',
      'image': 'assets/images/workouts/abs.jpg',
    },
    {
      'title': '10 Min Leg Workout',
      'subtitle': '10 mins · 12 exercises',
      'image': 'assets/images/workouts/stretch_warmup.jpg',
    },
    {
      'title': 'Strong Legs Routine',
      'subtitle': '13 mins · 12 exercises',
      'image': 'assets/images/workouts/lower_body.jpg',
    },
    {
      'title': '7 Min Strong Arms',
      'subtitle': '7 mins · 8 exercises',
      'image': 'assets/images/workouts/build_triceps.jpg',
    },
    {
      'title': 'Defined Arms with Dumbbells',
      'subtitle': '21 mins · 15 exercises',
      'image': 'assets/images/workouts/dumbbell_abs_shaper.jpg',
    },
    {
      'title': 'Dumbbell Abs Shaper',
      'subtitle': '22 mins · 16 exercises',
      'image': 'assets/images/workouts/dumbbell_abs_shaper.jpg',
    },
    {
      'title': 'Beginner Abs Shred',
      'subtitle': '17 mins · 13 exercises',
      'image': 'assets/images/workouts/belly_fat_burn.jpg',
    },
    {
      'title': 'Beginner Back Builder',
      'subtitle': '16 mins · 12 exercises',
      'image': 'assets/images/workouts/beginner_back_builder.jpg',
    },
    {
      'title': 'Easy Arm Workout with Dumbbells',
      'subtitle': '17 mins · 12 exercises',
      'image': 'assets/images/workouts/build_triceps.jpg',
    },
    {
      'title': 'Sculpted Arms Workout',
      'subtitle': '9 mins · 8 exercises',
      'image': 'assets/images/workouts/shredded_arms.jpg',
    },
    {
      'title': 'Bigger Strong Quads Leg Workout',
      'subtitle': '11 mins · 12 exercises',
      'image': 'assets/images/workouts/squat.jpg',
    },
    {
      'title': 'Butt Lift & Rounder Booty',
      'subtitle': '9 mins · 9 exercises',
      'image': 'assets/images/workouts/back_builder.jpg',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 26,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Build Muscle',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),

            // ── Workout List ─────────────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: _workouts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final w = _workouts[index];
                  return _WorkoutListTile(
                    title: w['title']!,
                    subtitle: w['subtitle']!,
                    imagePath: w['image']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single list-tile card ─────────────────────────────────────────────────────

class _WorkoutListTile extends StatelessWidget {
  const _WorkoutListTile({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  final String title;
  final String subtitle;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
