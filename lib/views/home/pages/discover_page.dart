import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/routes/app_routes.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 20,
            title: const Text(
              'DISCOVER',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
                color: Color(0xFF111827),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF111827),
                  size: 26,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pushNamed(AppRoutes.search);
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.history_rounded,
                  color: Color(0xFF111827),
                  size: 26,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // ── 1. Hero Banner ───────────────────────────────────────
                _HeroBanner(),

                const SizedBox(height: 28),

                // ── 2. Picks For You ────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Picks for you',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _PicksForYouList(),

                const SizedBox(height: 28),

                // ── 3. Stay Active Promo Banner ──────────────────────────
                _PromoBanner(),

                const SizedBox(height: 28),

                // ── 4. For Beginners ────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'For beginners',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _BeginnersList(),

                const SizedBox(height: 28),

                // ── 5. Fast Workout ──────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Fast workout',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _FastWorkoutList(),

                const SizedBox(height: 28),

                // ── 6. Challenge ─────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Challenge',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _ChallengeList(),

                const SizedBox(height: 28),

                // ── 7. Body Focus Badges ─────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Body Focus',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _BodyFocusGrid(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Banner ─────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => HapticFeedback.selectionClick(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Image.asset(
                'assets/images/workouts/hiit_fat_burning.jpg',
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.75),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
              ),
              const Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get Rid of Man\nBoobs HIIT',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Target your chest fat with high intensity workout.\nNo embarrassing man boobs when taking T-shirt...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

// ── Picks For You ─────────────────────────────────────────────────────────
class _PicksForYouList extends StatelessWidget {
  // Each inner list = one card (2 items stacked). Swiped horizontally.
  static const List<List<Map<String, String>>> _groups = [
    [
      {
        'title': 'Get Rid of Man Boobs HIIT',
        'subtitle': '17 min \u2022 Beginner',
        'image': 'assets/images/workouts/hiit_fat_burning.jpg',
      },
      {
        'title': 'Killer Core HIIT Beginner',
        'subtitle': '20 min \u2022 Beginner',
        'image': 'assets/images/workouts/abs.jpg',
      },
    ],
    [
      {
        'title': 'Build Wider Shoulders',
        'subtitle': '17 min \u2022 Intermediate',
        'image': 'assets/images/workouts/shoulder_tension_relief.jpg',
      },
      {
        'title': 'HIIT Intermediate',
        'subtitle': '19 min \u2022 Intermediate',
        'image': 'assets/images/workouts/squat.jpg',
      },
    ],
    [
      {
        'title': 'Last Longer in Bed',
        'subtitle': '13 min \u2022 Intermediate',
        'image': 'assets/images/workouts/full_body_muscle_growth.jpg',
      },
      {
        'title': 'Ripped V-Cut Abs Sculpting',
        'subtitle': '16 min \u2022 Beginner',
        'image': 'assets/images/workouts/dumbbell_abs_shaper.jpg',
      },
    ],
    [
      {
        'title': 'Fat Burning HIIT',
        'subtitle': '14 min \u2022 Intermediate',
        'image': 'assets/images/workouts/belly_fat_burn.jpg',
      },
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final cardW = screenW - 56.0; // peek of ~28px on right

    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _groups.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, gi) {
          final group = _groups[gi];
          return Container(
            width: cardW,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(group.length, (i) {
                return Column(
                  children: [
                    _PicksItem(
                      title: group[i]['title']!,
                      subtitle: group[i]['subtitle']!,
                      imagePath: group[i]['image']!,
                    ),
                    if (i < group.length - 1)
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFF3F4F6),
                      ),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

class _PicksItem extends StatelessWidget {
  const _PicksItem({
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: 80,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
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

// ── Stay Active Promo Banner ──────────────────────────────────────────────
class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => HapticFeedback.selectionClick(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Image.asset(
                'assets/images/workouts/stretch_warmup.jpg',
                width: double.infinity,
                height: 170,
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                  ),
                ),
              ),
              const Positioned(
                left: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stay active,\nstay in shape',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '5 workouts',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
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

// ── For Beginners (large overlay cards) ──────────────────────────────────
class _BeginnersList extends StatelessWidget {
  static const List<Map<String, String>> _items = [
    {
      'title': 'Arm Workout\n(No Push-Ups!)',
      'image': 'assets/images/workouts/discover_arm_workout.jpg',
    },
    {
      'title': 'Abs Workout\n(No Crunch!)',
      'image': 'assets/images/workouts/discover_abs_outdoor.jpg',
    },
    {
      'title': 'Build Wider\nShoulders',
      'image': 'assets/images/workouts/shoulder_tension_relief.jpg',
    },
    {
      'title': 'Leg Workout\n(No Jumping!)',
      'image': 'assets/images/workouts/lower_body.jpg',
    },
    {
      'title': 'Beginner\nBack Builder',
      'image': 'assets/images/workouts/beginner_back_builder.jpg',
    },
    {
      'title': 'Beginner\nChest Workout',
      'image': 'assets/images/workouts/beginner_chest_workout.jpg',
    },
    {
      'title': 'Beginner\nPush-Up',
      'image': 'assets/images/workouts/shredded_arms.jpg',
    },
    {
      'title': 'Beginner Core\nWorkout',
      'image': 'assets/images/workouts/discover_12min_classic.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _BegOverlayCard(
          title: _items[i]['title']!,
          imagePath: _items[i]['image']!,
        ),
      ),
    );
  }
}

class _BegOverlayCard extends StatelessWidget {
  const _BegOverlayCard({required this.title, required this.imagePath});

  final String title;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 130,
          height: 170,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(imagePath, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.72),
                    ],
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Fast Workout ──────────────────────────────────────────────────────────
class _FastWorkoutList extends StatelessWidget {
  static const List<List<Map<String, String>>> _groups = [
    [
      {
        'title': 'Before Workout Warm-Up',
        'subtitle': '5 min \u2022 Beginner',
        'image': 'assets/images/workouts/discover_warmup_lunge.jpg',
      },
      {
        'title': '12 Min Classic',
        'subtitle': '12 min \u2022 Beginner',
        'image': 'assets/images/workouts/discover_12min_classic.jpg',
      },
    ],
    [
      {
        'title': '6 Min Tabata',
        'subtitle': '6 min \u2022 Intermediate',
        'image': 'assets/images/workouts/squat.jpg',
      },
      {
        'title': '3 Exercises Lose Belly Fat',
        'subtitle': '9 min \u2022 Beginner',
        'image': 'assets/images/workouts/belly_fat_burn.jpg',
      },
    ],
    [
      {
        'title': '7 Min HIIT No Equipment',
        'subtitle': '7 min \u2022 Beginner',
        'image': 'assets/images/workouts/hiit_fat_burning.jpg',
      },
      {
        'title': 'Quick Abs Blast',
        'subtitle': '8 min \u2022 Intermediate',
        'image': 'assets/images/workouts/abs.jpg',
      },
    ],
    [
      {
        'title': '7 Min HIIT Fat Burning',
        'subtitle': '8 min \u2022 Beginner',
        'image': 'assets/images/workouts/hiit_fat_burning.jpg',
      },
      {
        'title': '10 Min Abs Workout',
        'subtitle': '9 min \u2022 Beginner',
        'image': 'assets/images/workouts/abs.jpg',
      },
    ],
    [
      {
        'title': 'Express Full Body',
        'subtitle': '10 min \u2022 Beginner',
        'image': 'assets/images/workouts/full_body_muscle_growth.jpg',
      },
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final cardW = screenW - 56.0;

    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _groups.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, gi) {
          final group = _groups[gi];
          return Container(
            width: cardW,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(group.length, (i) {
                return Column(
                  children: [
                    _FastWorkoutItem(
                      title: group[i]['title']!,
                      subtitle: group[i]['subtitle']!,
                      imagePath: group[i]['image']!,
                    ),
                    if (i < group.length - 1)
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFF3F4F6),
                      ),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

class _FastWorkoutItem extends StatelessWidget {
  const _FastWorkoutItem({
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: 80,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
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

// ── Challenge (large square overlay cards) ────────────────────────────────
class _ChallengeList extends StatelessWidget {
  static const List<Map<String, String>> _items = [
    {
      'title': 'Killer Core HIIT\nAdvanced',
      'image': 'assets/images/workouts/discover_killer_core.jpg',
    },
    {
      'title': 'Brutal Ladder HIIT',
      'image': 'assets/images/workouts/discover_brutal_hiit.jpg',
    },
    {
      'title': 'Build Wider\nShoulders',
      'image': 'assets/images/workouts/shoulder_tension_relief.jpg',
    },
    {'title': 'Plank Challenge', 'image': 'assets/images/workouts/abs.jpg'},
    {
      'title': 'Killer Chest Workout',
      'image': 'assets/images/workouts/beginner_chest_workout.jpg',
    },
    {
      'title': 'Mass Builder',
      'image': 'assets/images/workouts/massive_body.jpg',
    },
    {
      'title': 'Shred Arms',
      'image': 'assets/images/workouts/discover_arm_workout.jpg',
    },
    {
      'title': 'Belly Fat Burner\nHIIT Advanced',
      'image': 'assets/images/workouts/belly_fat_burn.jpg',
    },
    {
      'title': 'Body Calorie\nBurner',
      'image': 'assets/images/workouts/full_body_muscle_growth.jpg',
    },
    {
      'title': 'Burn 100 Calories',
      'image': 'assets/images/workouts/discover_brutal_hiit.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _ChallengeCard(
          title: _items[i]['title']!,
          imagePath: _items[i]['image']!,
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.title, required this.imagePath});

  final String title;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 150,
          height: 170,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(imagePath, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.78),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 12,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyFocusGrid extends StatelessWidget {
  static const List<Map<String, dynamic>> _focuses = [
    {'label': 'Full Body', 'icon': Icons.accessibility_new_rounded},
    {'label': 'ABS', 'icon': Icons.self_improvement_rounded},
    {'label': 'Arms', 'icon': Icons.fitness_center_rounded},
    {'label': 'Butt & Legs', 'icon': Icons.directions_run_rounded},
    {'label': 'Chest', 'icon': Icons.sports_gymnastics_rounded},
    {'label': 'Back', 'icon': Icons.sports_martial_arts_rounded},
    {'label': 'Shoulder', 'icon': Icons.sports_handball_rounded},
    {'label': 'Stretch', 'icon': Icons.airline_seat_flat_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _focuses.length,
        itemBuilder: (context, i) {
          final item = _focuses[i];
          return GestureDetector(
            onTap: () => HapticFeedback.selectionClick(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: const Color(0xFF0062FF),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['label'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
