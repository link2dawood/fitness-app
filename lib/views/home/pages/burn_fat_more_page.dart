import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BurnFatMorePage extends StatelessWidget {
  const BurnFatMorePage({super.key});

  static const List<Map<String, String>> _workouts = [
    {
      'title': 'Intense Belly Fat Burn',
      'subtitle': '14 days plan',
      'image': 'assets/images/workouts/abs.jpg',
    },
    {
      'title': 'Lose Weight for Men',
      'subtitle': '30 days plan',
      'image': 'assets/images/workouts/abs.jpg',
    },
    {
      'title': 'Lose Weight for Women',
      'subtitle': '28 days plan',
      'image': 'assets/images/workouts/lower_body.jpg',
    },
    {
      'title': '10 Min Shredded Arms',
      'subtitle': '11 mins · 12 exercises',
      'image': 'assets/images/workouts/shredded_arms.jpg',
    },
    {
      'title': 'Belly Fat Burner HIIT Beginner',
      'subtitle': '20 mins · 24 exercises',
      'image': 'assets/images/workouts/belly_fat_burn.jpg',
    },
    {
      'title': 'Belly Fat Burner HIIT Intermediate',
      'subtitle': '26 mins · 30 exercises',
      'image': 'assets/images/workouts/belly_fat_burn.jpg',
    },
    {
      'title': 'Belly Fat Burner HIIT Advanced',
      'subtitle': '29 mins · 34 exercises',
      'image': 'assets/images/workouts/belly_fat_burn.jpg',
    },
    {
      'title': 'Lose Fat (No Jumping!)',
      'subtitle': '20 mins · 22 exercises',
      'image': 'assets/images/workouts/hiit_fat_burning.jpg',
    },
    {
      'title': 'Fat Burning HIIT',
      'subtitle': '14 mins · 17 exercises',
      'image': 'assets/images/workouts/hiit_fat_burning.jpg',
    },
    {
      'title': '3 Exercises Lose Belly Fat',
      'subtitle': '9 mins · 9 exercises',
      'image': 'assets/images/workouts/belly_fat_burn.jpg',
    },
    {
      'title': '7 Min HIIT Fat Burning',
      'subtitle': '8 mins · 7 exercises',
      'image': 'assets/images/workouts/hiit_fat_burning.jpg',
    },
    {
      'title': 'Body Calorie Burner',
      'subtitle': '28 mins · 30 exercises',
      'image': 'assets/images/workouts/abs.jpg',
    },
    {
      'title': 'Burn 100 Calories',
      'subtitle': '13 mins · 14 exercises',
      'image': 'assets/images/workouts/abs.jpg',
    },
    {
      'title': 'Build Strong Triceps',
      'subtitle': '7 mins · 7 exercises',
      'image': 'assets/images/workouts/build_triceps.jpg',
    },
    {
      'title': 'Beginner Arm Routine',
      'subtitle': '8 mins · 8 exercises',
      'image': 'assets/images/workouts/build_triceps.jpg',
    },
    {
      'title': 'Shred Your Quads',
      'subtitle': '19 mins · 22 exercises',
      'image': 'assets/images/workouts/squat.jpg',
    },
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
                    'Burn Fat',
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
