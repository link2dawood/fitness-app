import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeepFitMorePage extends StatelessWidget {
  const KeepFitMorePage({super.key});

  static const List<Map<String, String>> _workouts = [
    {
      'title': 'Before Workout Warm-Up',
      'subtitle': '5 mins · 5 exercises',
      'image': 'assets/images/workouts/stretch_warmup.jpg',
    },
    {
      'title': 'Full Body Stretching',
      'subtitle': '11 mins · 14 exercises',
      'image': 'assets/images/workouts/upper_body_stretching.jpg',
    },
    {
      'title': 'Lower Body Stretching',
      'subtitle': '15 mins · 18 exercises',
      'image': 'assets/images/workouts/lower_body.jpg',
    },
    {
      'title': 'Upper Body Stretching',
      'subtitle': '13 mins · 16 exercises',
      'image': 'assets/images/workouts/stretch_shoulder.jpg',
    },
    {
      'title': 'Lower Back Pain Relief',
      'subtitle': '15 mins · 18 exercises',
      'image': 'assets/images/workouts/back_builder.jpg',
    },
    {
      'title': 'Morning Warm-Up',
      'subtitle': '9 mins · 10 exercises',
      'image': 'assets/images/workouts/stretch_sleepy.jpg',
    },
    {
      'title': 'Neck & Shoulder Tension Relief',
      'subtitle': '16 mins · 17 exercises',
      'image': 'assets/images/workouts/neck_shoulder_tension_relief.jpg',
    },
    {
      'title': 'Sleepy Time Stretching',
      'subtitle': '12 mins · 13 exercises',
      'image': 'assets/images/workouts/stretch_sleepy.jpg',
    },
    {
      'title': 'Back Stretching',
      'subtitle': '14 mins · 15 exercises',
      'image': 'assets/images/workouts/beginner_back_builder.jpg',
    },
    {
      'title': 'Knee Pain Relief',
      'subtitle': '14 mins · 16 exercises',
      'image': 'assets/images/workouts/knee_pain_relief.jpg',
    },
    {
      'title': 'Shoulder Tension Relief',
      'subtitle': '12 mins · 14 exercises',
      'image': 'assets/images/workouts/shoulder_tension_relief.jpg',
    },
    {
      'title': 'Last Longer in Bed',
      'subtitle': '13 mins · 12 exercises',
      'image': 'assets/images/workouts/abs.jpg',
    },
    {
      'title': 'Immunity Booster at Home',
      'subtitle': '11 mins · 9 exercises',
      'image': 'assets/images/workouts/build_triceps.jpg',
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
                    'Keep Fit',
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
