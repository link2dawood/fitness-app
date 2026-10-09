import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../widgets/challenge_cards.dart';
import 'challenge_page.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  PageController? _pageController;
  PageController get _bodyFocusPageController {
    _pageController ??= PageController(viewportFraction: 0.90);
    return _pageController!;
  }

  static const List<String> bodyFocusCategories = [
    'Abs',
    'Arm',
    'Forearm',
    'Chest',
    'Leg',
    'Butt',
    'Shoulder & Back',
  ];

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getBodyFocusData(String category) {
    switch (category) {
      case 'Abs':
        return [
          {
            'level': 'Beginner',
            'time': '16 mins',
            'exercises': '16 Exercises',
            'image': 'assets/images/workouts/abs.jpg',
            'intensity': 1,
          },
          {
            'level': 'Intermediate',
            'time': '25 mins',
            'exercises': '21 Exercises',
            'image': 'assets/images/workouts/belly_fat_burn.jpg',
            'intensity': 2,
          },
          {
            'level': 'Advanced',
            'time': '28 mins',
            'exercises': '21 Exercises',
            'image': 'assets/images/workouts/massive_body.jpg',
            'intensity': 3,
          },
        ];
      case 'Arm':
        return [
          {
            'level': 'Beginner',
            'time': '18 mins',
            'exercises': '19 Exercises',
            'image': 'assets/images/workouts/back_builder.jpg',
            'intensity': 1,
          },
          {
            'level': 'Intermediate',
            'time': '23 mins',
            'exercises': '25 Exercises',
            'image': 'assets/images/workouts/massive_body.jpg',
            'intensity': 2,
          },
          {
            'level': 'Advanced',
            'time': '31 mins',
            'exercises': '28 Exercises',
            'image': 'assets/images/workouts/back_sb.jpg',
            'intensity': 3,
          },
        ];
      case 'Forearm':
        return [
          {
            'level': 'Beginner',
            'time': '16 mins',
            'exercises': '24 Exercises',
            'image': 'assets/images/workouts/back_sb.jpg',
            'intensity': 1,
          },
          {
            'level': 'Intermediate',
            'time': '20 mins',
            'exercises': '24 Exercises',
            'image': 'assets/images/workouts/stretch_warmup.jpg',
            'intensity': 2,
          },
          {
            'level': 'Advanced',
            'time': '22 mins',
            'exercises': '24 Exercises',
            'image': 'assets/images/workouts/back_builder.jpg',
            'intensity': 3,
          },
        ];
      case 'Chest':
        return [
          {
            'level': 'Beginner',
            'time': '8 mins',
            'exercises': '11 Exercises',
            'image': 'assets/images/workouts/massive_body.jpg',
            'intensity': 1,
          },
          {
            'level': 'Intermediate',
            'time': '13 mins',
            'exercises': '14 Exercises',
            'image': 'assets/images/workouts/abs.jpg',
            'intensity': 2,
          },
          {
            'level': 'Advanced',
            'time': '18 mins',
            'exercises': '16 Exercises',
            'image': 'assets/images/workouts/belly_fat_burn.jpg',
            'intensity': 3,
          },
        ];
      case 'Leg':
        return [
          {
            'level': 'Beginner',
            'time': '23 mins',
            'exercises': '23 Exercises',
            'image': 'assets/images/workouts/squat.jpg',
            'intensity': 1,
          },
          {
            'level': 'Intermediate',
            'time': '31 mins',
            'exercises': '36 Exercises',
            'image': 'assets/images/workouts/lower_body.jpg',
            'intensity': 2,
          },
          {
            'level': 'Advanced',
            'time': '40 mins',
            'exercises': '43 Exercises',
            'image': 'assets/images/workouts/squat.jpg',
            'intensity': 3,
          },
        ];
      case 'Butt':
        return [
          {
            'level': 'Beginner',
            'time': '14 mins',
            'exercises': '15 Exercises',
            'image': 'assets/images/workouts/squat.jpg',
            'intensity': 1,
          },
          {
            'level': 'Intermediate',
            'time': '22 mins',
            'exercises': '20 Exercises',
            'image': 'assets/images/workouts/lower_body.jpg',
            'intensity': 2,
          },
          {
            'level': 'Advanced',
            'time': '30 mins',
            'exercises': '25 Exercises',
            'image': 'assets/images/workouts/squat.jpg',
            'intensity': 3,
          },
        ];
      case 'Shoulder & Back':
      default:
        return [
          {
            'level': 'Beginner',
            'time': '15 mins',
            'exercises': '14 Exercises',
            'image': 'assets/images/workouts/back_builder.jpg',
            'intensity': 1,
          },
          {
            'level': 'Intermediate',
            'time': '24 mins',
            'exercises': '22 Exercises',
            'image': 'assets/images/workouts/back_sb.jpg',
            'intensity': 2,
          },
          {
            'level': 'Advanced',
            'time': '32 mins',
            'exercises': '28 Exercises',
            'image': 'assets/images/workouts/massive_body.jpg',
            'intensity': 3,
          },
        ];
    }
  }

  void _onBodyFocusPageChanged(int index, HomeViewModel vm) {
    final category = bodyFocusCategories[index];
    if (vm.selectedBodyFocus != category) {
      vm.setBodyFocus(category);
    }
  }

  void _showProModal(BuildContext context) {
    HapticFeedback.selectionClick();
    Navigator.of(context).pushNamed(AppRoutes.pro);
  }

  void _showStreakModal(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  size: 52,
                  color: Color(0xFFFF5722),
                ),
                const SizedBox(height: 12),
                const Text(
                  '1 Day Streak!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You started strong! Complete your workout today to keep the fire burning.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0062FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('KEEP GOING'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHistoryCalendar(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5F5F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _HistoryCalendarSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final profile = vm.profile;

    final targetDays = profile?.workoutDaysPerWeek ?? 4;
    final levelText = profile?.level?.label ?? 'Advanced';
    final targetAreaText = (profile != null && profile.focusAreas.isNotEmpty)
        ? profile.focusAreas.first.label
        : 'Full Body';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. App Bar Header ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    const Text(
                      'HOME WORKOUT',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    // Streak flame icon button
                    GestureDetector(
                      onTap: () => _showStreakModal(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          size: 22,
                          color: Color(0xFFFF5722),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Pro button
                    GestureDetector(
                      onTap: () => _showProModal(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECC8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.workspace_premium_rounded,
                              size: 16,
                              color: Color(0xFFD4A017),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'PRO ↗',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF5B3900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 2. Search Bar ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pushNamed(AppRoutes.search);
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F7),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search workouts, plans...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Color(0xFF9CA3AF),
                            size: 22,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── 3. Weekly Goal Card ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Weekly Goal Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Weekly Goal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Row(
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: '0',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0062FF),
                                      ),
                                    ),
                                    TextSpan(
                                      text: '/$targetDays',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: Color(0xFF9CA3AF),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Dynamic current-week calendar row (tappable) ──────
                      Builder(
                        builder: (ctx) {
                          final today = DateTime.now();
                          // Compute Mon-based week containing today
                          final weekday = today.weekday; // 1=Mon … 7=Sun
                          final monday = today.subtract(
                            Duration(days: weekday - 1),
                          );
                          final weekDays = List.generate(
                            7,
                            (i) => monday.add(Duration(days: i)),
                          );

                          return GestureDetector(
                            onTap: () => _showHistoryCalendar(context),
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: weekDays.map((d) {
                                final isToday =
                                    d.day == today.day &&
                                    d.month == today.month &&
                                    d.year == today.year;
                                return _buildCalendarDay(
                                  d.day,
                                  isSelected: isToday,
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Motivational Coach Bubble
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ClipOval(
                              child: Image.asset(
                                'assets/images/ui/plan_coach.jpg',
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                alignment: const Alignment(0, -0.6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Welcome back! Today's your chance to shine.",
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── 4. Challenge Carousel ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Challenge',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChallengePage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0062FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Color(0xFF0062FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Horizontal Swipeable Challenge Cards
              SizedBox(
                height: 290,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Card 1: Customized For You
                    ChallengeCardWidgets.buildCustomizedChallengeCard(
                      levelText: levelText,
                      targetAreaText: targetAreaText,
                    ),
                    const SizedBox(width: 14),
                    ChallengeCardWidgets.buildGenericChallengeCard(
                      topText: '30 DAYS',
                      titleText: 'GET RIPPED\nWITH\nDUMBBELL ',
                      description:
                          'Use dumbbells to build bigger muscles and boost full-body strength in 30 days!',
                      baseColor: const Color(0xFF00ACC1),
                      imagePath: 'assets/images/workouts/back_builder.jpg',
                    ),
                    const SizedBox(width: 14),
                    ChallengeCardWidgets.buildGenericChallengeCard(
                      topText: '28 DAYS',
                      titleText: 'CALISTHENICS\nPLAN ',
                      description:
                          'Take on bodyweight exercises to maximize your muscle gain and fat loss!',
                      baseColor: const Color(0xFF7E22CE),
                      imagePath: 'assets/images/workouts/squat.jpg',
                    ),
                    const SizedBox(width: 14),
                    ChallengeCardWidgets.buildGenericChallengeCard(
                      topText: '28 DAYS',
                      titleText: 'FULL BODY\nCHALLENGE ',
                      description:
                          'Start your body-toning journey to target all muscle groups and build your dream body in 4 weeks!',
                      baseColor: const Color(0xFF0062FF),
                      imagePath: 'assets/images/body/fullbody.png',
                    ),
                    const SizedBox(width: 14),
                    ChallengeCardWidgets.buildGenericChallengeCard(
                      topText: '30 DAYS',
                      titleText: 'LOSE WEIGHT\nFOR MEN ',
                      description:
                          'Lose man boobs and love handles in just 5-10 min a day!',
                      baseColor: const Color(0xFFFF7043),
                      imagePath: 'assets/images/ui/plan_coach.jpg',
                    ),
                    const SizedBox(width: 14),
                    ChallengeCardWidgets.buildGenericChallengeCard(
                      topText: '30 DAYS',
                      titleText: 'SIX PACK\nCHALLENGE ',
                      description:
                          'Crush this challenge and carve out your six-pack in no time!',
                      baseColor: const Color(0xFF311B92),
                      imagePath: 'assets/images/workouts/abs.jpg',
                    ),
                    const SizedBox(width: 14),
                    ChallengeCardWidgets.buildGenericChallengeCard(
                      topText: '14 DAYS',
                      titleText: 'KEGEL POWER\nBOOST ',
                      description:
                          'Strengthen your pelvic floor with Kegel exercises for better sex and intimacy!',
                      baseColor: const Color(0xFF607D8B),
                      imagePath: 'assets/images/workouts/stretch_warmup.jpg',
                    ),
                    const SizedBox(width: 14),
                    ChallengeCardWidgets.buildGenericChallengeCard(
                      topText: '14 DAYS',
                      titleText: 'INTENSE\nBELLY FAT\nBURN ',
                      description:
                          'Feel the burn, lose the fat—killer abs exercises that work your core fast!',
                      baseColor: const Color(0xFF796B6B),
                      imagePath: 'assets/images/workouts/belly_fat_burn.jpg',
                    ),
                    const SizedBox(width: 14),
                    ChallengeCardWidgets.buildGenericChallengeCard(
                      topText: '28 DAYS',
                      titleText: 'HEIGHT\nINCREASE\nCHALLENGE ',
                      description:
                          'Stretch, strengthen, and reveal a taller, more confident you!',
                      baseColor: const Color(0xFF329D8F),
                      imagePath: 'assets/images/workouts/height_increase.jpg',
                    ),
                    const SizedBox(width: 14),
                    ChallengeCardWidgets.buildGenericChallengeCard(
                      topText: '28 DAYS',
                      titleText: 'LOWER BODY\nCHALLENGE ',
                      description:
                          'In just 4 weeks, power up your legs, boost lower body strength, and enhance your overall strength!',
                      baseColor: const Color(0xFF0077EE),
                      imagePath: 'assets/images/workouts/lower_body.jpg',
                    ),
                    const SizedBox(width: 14),
                    ChallengeCardWidgets.buildGenericChallengeCard(
                      topText: '28 DAYS',
                      titleText: 'MASSIVE\nBODY\nCHALLENGE ',
                      description:
                          'Sculpt your upper body and shred your abs in 4 weeks—no equipment needed!',
                      baseColor: const Color(0xFF3A506B),
                      imagePath: 'assets/images/workouts/massive_body.jpg',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── 5. Body Focus Section ──────────────────────────────────────
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

              const SizedBox(height: 12),

              // Category Filter Chips
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    for (int i = 0; i < bodyFocusCategories.length; i++) ...[
                      _buildFilterChip(
                        label: bodyFocusCategories[i],
                        isSelected:
                            vm.selectedBodyFocus == bodyFocusCategories[i],
                        onTap: () {
                          vm.setBodyFocus(bodyFocusCategories[i]);
                          if (_bodyFocusPageController.hasClients) {
                            _bodyFocusPageController.animateToPage(
                              i,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Workouts under Body Focus
              SizedBox(
                height: 350,
                child: PageView.builder(
                  controller: _bodyFocusPageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) => _onBodyFocusPageChanged(index, vm),
                  itemCount: bodyFocusCategories.length,
                  itemBuilder: (context, index) {
                    final category = bodyFocusCategories[index];
                    final workouts = _getBodyFocusData(category);

                    return Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Column(
                        children: [
                          for (final workout in workouts) ...[
                            _buildWorkoutTile(
                              title: '$category ${workout['level']}',
                              subtitle:
                                  '${workout['time']} • ${workout['exercises']}',
                              imagePath: workout['image'],
                              intensity: workout['intensity'],
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ── 6. Badges (Workout Types) ──────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildBadgePill(
                          icon: Icons.sports_gymnastics_rounded,
                          label: 'Build Muscle',
                        ),
                        const SizedBox(width: 8),
                        _buildBadgePill(
                          icon: Icons.self_improvement_rounded,
                          label: 'Stretch',
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF0062FF)),
                              SizedBox(width: 2),
                              Icon(Icons.chevron_left_rounded, size: 16, color: Color(0xFF0062FF)),
                              Text(
                                '7 mins',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildBadgePill(
                          icon: Icons.local_fire_department_rounded,
                          label: 'Burn Fat',
                        ),
                        const SizedBox(width: 8),
                        _buildBadgePill(
                          icon: Icons.favorite_rounded,
                          label: 'Keep Fit',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildBadgePill(
                          icon: Icons.fitness_center_rounded,
                          label: 'With Equipment',
                        ),
                        const SizedBox(width: 8),
                        _buildBadgePill(
                          icon: Icons.layers_outlined,
                          label: 'Beginner',
                        ),
                        const SizedBox(width: 8),
                        _buildBadgePill(
                          icon: Icons.layers_outlined,
                          label: 'Intermediate',
                        ),
                        const SizedBox(width: 8),
                        _buildBadgePill(
                          icon: Icons.accessibility_new_rounded,
                          label: 'Warm-Up',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── 7. Custom Workout Section ──────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Custom Workout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 130,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFF004BD6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'CREATE\nYOUR OWN',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              height: 1.15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'GO',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0062FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Translucent 3D layered notepad icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── 8. Recommended Section ─────────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Recommended',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 150),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF86B5E7), Color(0xFFA5C9F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Right Image
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(22),
                          ),
                          child: Image.asset(
                            'assets/images/ui/recommended_height.jpg',
                            width: 175,
                            fit: BoxFit.cover,
                            alignment: Alignment.centerRight,
                          ),
                        ),
                      ),
                      // Left Content
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'HEIGHT\nINCREASE',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Unlock your maximum\nheight potential',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.28),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '7 Workouts',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── 9. Just For You Section ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Just For You',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pushNamed(AppRoutes.justForYou);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0062FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Color(0xFF0062FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Column(
                        children: [
                          _buildJustForYouItem(
                            title: 'Beginner Chest Sculpt',
                            subtitle: '26 min • Beginner',
                            imagePath:
                                'assets/images/workouts/massive_body.jpg',
                            showDivider: true,
                          ),
                          _buildJustForYouItem(
                            title: 'Belly Fat Burner HIIT Advanced',
                            subtitle: '29 min • Advanced',
                            imagePath:
                                'assets/images/workouts/belly_fat_burn.jpg',
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Column(
                        children: [
                          _buildJustForYouItem(
                            title: 'Full Body Shred',
                            subtitle: '30 min • Advanced',
                            imagePath: 'assets/images/workouts/abs.jpg',
                            showDivider: true,
                          ),
                          _buildJustForYouItem(
                            title: 'Legs & Glutes',
                            subtitle: '20 min • Intermediate',
                            imagePath: 'assets/images/workouts/squat.jpg',
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── 10. Stretch & Warm Up Section ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Stretch & Warm Up',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pushNamed(AppRoutes.stretchWarmUp);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0062FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Color(0xFF0062FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildStretchCard(
                      title: 'Before Workout Warm-Up',
                      imagePath: 'assets/images/workouts/stretch_warmup.jpg',
                    ),
                    const SizedBox(width: 14),
                    _buildStretchCard(
                      title: 'Sleepy Time Stretching',
                      imagePath: 'assets/images/workouts/stretch_sleepy.jpg',
                    ),
                    const SizedBox(width: 14),
                    _buildStretchCard(
                      title: 'Knee Pain Relief',
                      imagePath: 'assets/images/workouts/knee_pain_relief.jpg',
                    ),
                    const SizedBox(width: 14),
                    _buildStretchCard(
                      title: 'Neck & Shoulder Tension Relief',
                      imagePath: 'assets/images/workouts/neck_shoulder_tension_relief.jpg',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── 11. Popular Goals Section ──────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Popular Goals',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Goal filter chips
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    for (final goal in [
                      'Burn Fat',
                      'Build Muscle',
                      'Keep Fit',
                    ]) ...[
                      _buildFilterChip(
                        label: goal,
                        isSelected: vm.selectedPopularGoal == goal,
                        onTap: () => vm.setPopularGoal(goal),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Popular Goals Container Box with List (tab-driven)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: _buildPopularGoalsList(
                    key: ValueKey(vm.selectedPopularGoal),
                    goal: vm.selectedPopularGoal,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── 12. Explore More Workouts Banner ───────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    vm.setTab(1); // Switch to Discover tab
                  },
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background collage of workout images
                          Row(
                            children: [
                              Expanded(
                                child: Image.asset(
                                  'assets/images/workouts/hiit_fat_burning.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: Image.asset(
                                  'assets/images/workouts/dumbbell_abs_shaper.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: Image.asset(
                                  'assets/images/workouts/massive_body.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                          // Dark overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.72),
                                  Colors.black.withValues(alpha: 0.35),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Explore more\nworkouts',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Text(
                                    'Go',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── 13. "Can't find" hint row ──────────────────────────────────
              Center(
                child: Text(
                  "Can't find what you want?",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Color(0xFF0062FF),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Tell us what you need',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0062FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────────────────

  static Widget _buildCalendarDay(int day, {required bool isSelected}) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0062FF) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$day',
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
          color: isSelected ? Colors.white : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  static Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0062FF).withValues(alpha: 0.10)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0062FF) : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? const Color(0xFF0062FF)
                : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  static Widget _buildWorkoutTile({
    required String title,
    required String subtitle,
    required String imagePath,
    required int intensity,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (var i = 0; i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Icon(
                          Icons.bolt_rounded,
                          size: 16,
                          color: i < intensity
                              ? const Color(0xFF0062FF)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildBadgePill({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0062FF)),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildJustForYouItem({
    required String title,
    required String subtitle,
    required String imagePath,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(width: 96),
              Expanded(
                child: Container(height: 1, color: const Color(0xFFE5E7EB)),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  static Widget _buildStretchCard({
    required String title,
    required String imagePath,
  }) {
    return Container(
      width: 175,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              imagePath,
              width: 175,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
          // Dark gradient overlay for text readability
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.70),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            right: 12,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Popular Goals list factory (tab-driven) ─────────────────────────────────
  static Widget _buildPopularGoalsList({
    Key? key,
    required String goal,
  }) {
    // Data per tab – matches reference screenshots exactly
    final Map<String, List<Map<String, String>>> goalData = {
      'Burn Fat': [
        {
          'title': '7 Min HIIT Fat Burning',
          'subtitle': '8 min • Beginner',
          'image': 'assets/images/workouts/hiit_fat_burning.jpg',
        },
        {
          'title': 'Build Strong Triceps',
          'subtitle': '7 min • Beginner',
          'image': 'assets/images/workouts/build_triceps.jpg',
        },
        {
          'title': '10 Min Shredded Arms',
          'subtitle': '11 min • Beginner',
          'image': 'assets/images/workouts/shredded_arms.jpg',
        },
      ],
      'Build Muscle': [
        {
          'title': 'Dumbbell Abs Shaper',
          'subtitle': '22 min • Intermediate',
          'image': 'assets/images/workouts/dumbbell_abs_shaper.jpg',
        },
        {
          'title': 'Beginner Back Builder',
          'subtitle': '16 min • Beginner',
          'image': 'assets/images/workouts/beginner_back_builder.jpg',
        },
        {
          'title': 'Beginner Chest Workout',
          'subtitle': '7 min • Beginner',
          'image': 'assets/images/workouts/beginner_chest_workout.jpg',
        },
      ],
      'Keep Fit': [
        {
          'title': 'Upper Body Stretching',
          'subtitle': '13 min • Beginner',
          'image': 'assets/images/workouts/upper_body_stretching.jpg',
        },
        {
          'title': 'Lower Body Stretching',
          'subtitle': '15 min • Beginner',
          'image': 'assets/images/workouts/lower_body.jpg',
        },
        {
          'title': 'Neck & Shoulder Tension Relief',
          'subtitle': '16 min • Beginner',
          'image': 'assets/images/workouts/neck_shoulder_tension_relief.jpg',
        },
      ],
    };

    final items = goalData[goal] ?? goalData['Burn Fat']!;

    return Container(
      key: key,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildPopularGoalItem(
              title: items[i]['title']!,
              subtitle: items[i]['subtitle']!,
              imagePath: items[i]['image']!,
            ),
            if (i < items.length - 1)
              const Divider(height: 24, color: Color(0xFFF3F4F6)),
          ],
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (goal == 'Build Muscle') {
                    Navigator.of(context).pushNamed(AppRoutes.buildMuscleMore);
                  } else if (goal == 'Burn Fat') {
                    Navigator.of(context).pushNamed(AppRoutes.burnFatMore);
                  } else if (goal == 'Keep Fit') {
                    Navigator.of(context).pushNamed(AppRoutes.keepFitMore);
                  }
                },
                child: const Center(
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFF111827),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static Widget _buildPopularGoalItem({
    required String title,
    required String subtitle,
    required String imagePath,
  }) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            imagePath,
            width: 66,
            height: 66,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFF111827),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            size: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History Calendar Sheet  (matches reference image)
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryCalendarSheet extends StatefulWidget {
  const _HistoryCalendarSheet();

  @override
  State<_HistoryCalendarSheet> createState() => _HistoryCalendarSheetState();
}

class _HistoryCalendarSheetState extends State<_HistoryCalendarSheet> {
  late DateTime _month;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _month = DateTime(_today.year, _today.month);
  }

  void _prevMonth() =>
      setState(() => _month = DateTime(_month.year, _month.month - 1));
  void _nextMonth() =>
      setState(() => _month = DateTime(_month.year, _month.month + 1));

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    // All days to display (pad to start on Sunday)
    final firstDay = DateTime(_month.year, _month.month, 1);
    final startOffset = firstDay.weekday % 7; // Sun=0, Mon=1, …
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return SizedBox(
      height: screenH * 0.72,
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'History',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Month nav row  e.g.  ◀  2026/10  ▶
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _prevMonth,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      '◀',
                      style: TextStyle(fontSize: 16, color: Color(0xFF374151)),
                    ),
                  ),
                ),
                Text(
                  '${_month.year}/${_month.month.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                GestureDetector(
                  onTap: _nextMonth,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      '▶',
                      style: TextStyle(fontSize: 16, color: Color(0xFF374151)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Day-of-week header  S  M  T  W  T  F  S
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map(
                    (d) => SizedBox(
                      width: 40,
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Calendar grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(rows, (row) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (col) {
                      final cellIndex = row * 7 + col;
                      final day = cellIndex - startOffset + 1;
                      if (day < 1 || day > daysInMonth) {
                        return const SizedBox(width: 40, height: 40);
                      }

                      final isToday =
                          _month.year == _today.year &&
                          _month.month == _today.month &&
                          day == _today.day;

                      return GestureDetector(
                        onTap: () {}, // future: show day detail
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: isToday
                              ? const BoxDecoration(
                                  color: Color(0xFF111827),
                                  shape: BoxShape.circle,
                                )
                              : null,
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isToday
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: isToday
                                  ? Colors.white
                                  : const Color(0xFF374151),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
