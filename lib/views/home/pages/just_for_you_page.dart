import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JustForYouPage extends StatelessWidget {
  const JustForYouPage({super.key});

  static const List<Map<String, String>> _workouts = [
    {
      'title': 'Beginner Chest Sculpt',
      'subtitle': '26 mins · 23 exercises',
      'image': 'assets/images/workouts/massive_body.jpg',
    },
    {
      'title': 'Belly Fat Burner HIIT Advanced',
      'subtitle': '29 mins · 34 exercises',
      'image': 'assets/images/workouts/belly_fat_burn.jpg',
    },
    {
      'title': 'Full Body Muscle Growth',
      'subtitle': '26 mins · 24 exercises',
      'image': 'assets/images/workouts/full_body_muscle_growth.jpg',
    },
    {
      'title': 'Shoulder Tension Relief',
      'subtitle': '12 mins · 14 exercises',
      'image': 'assets/images/workouts/shoulder_tension_relief.jpg',
    },
    {
      'title': 'Bubble Butt Workout',
      'subtitle': '12 mins · 13 exercises',
      'image': 'assets/images/workouts/squat.jpg',
    },
    {
      'title': 'Build Wider Shoulders',
      'subtitle': '25 mins · 24 exercises',
      'image': 'assets/images/workouts/back_sb.jpg',
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
                    'Just For You',
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
                      fontWeight: FontWeight.w800,
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
            // Chevron
            const Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: Color(0xFFD1D5DB),
            ),
          ],
        ),
      ),
    );
  }
}
