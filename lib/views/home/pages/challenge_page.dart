import 'package:flutter/material.dart';
import '../../../widgets/challenge_cards.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({Key? key}) : super(key: key);

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  final List<String> categories = [
    'All',
    'Lose Weight',
    'Build Muscle',
    'Full Body',
    'Abs',
    'Upper Body',
    'Lower Body',
    'Height Increase',
    'Calisthenics',
    'Kegel',
    'Dumbbell'
  ];

  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Challenge',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Horizontal Badges list
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0062FF) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF374151),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Vertical Cards list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              children: [
                if (selectedCategory == 'All' || selectedCategory == 'Full Body' || selectedCategory == 'Lose Weight') ...[
                  ChallengeCardWidgets.buildCustomizedChallengeCard(
                    levelText: 'Beginner',
                    targetAreaText: 'Full Body',
                    width: double.infinity,
                  ),
                  const SizedBox(height: 20),
                ],
                if (selectedCategory == 'All' || selectedCategory == 'Dumbbell' || selectedCategory == 'Build Muscle' || selectedCategory == 'Full Body') ...[
                  ChallengeCardWidgets.buildGenericChallengeCard(
                    topText: '30 DAYS',
                    titleText: 'GET RIPPED\nWITH\nDUMBBELL ',
                    description: 'Use dumbbells to build bigger muscles and boost full-body strength in 30 days!',
                    baseColor: const Color(0xFF00ACC1),
                    imagePath: 'assets/images/workouts/back_builder.jpg',
                    width: double.infinity,
                  ),
                  const SizedBox(height: 20),
                ],
                if (selectedCategory == 'All' || selectedCategory == 'Calisthenics' || selectedCategory == 'Full Body' || selectedCategory == 'Build Muscle') ...[
                  ChallengeCardWidgets.buildGenericChallengeCard(
                    topText: '28 DAYS',
                    titleText: 'CALISTHENICS\nPLAN ',
                    description: 'Take on bodyweight exercises to maximize your muscle gain and fat loss!',
                    baseColor: const Color(0xFF7E22CE),
                    imagePath: 'assets/images/workouts/squat.jpg',
                    width: double.infinity,
                  ),
                  const SizedBox(height: 20),
                ],
                if (selectedCategory == 'All' || selectedCategory == 'Full Body' || selectedCategory == 'Build Muscle') ...[
                  ChallengeCardWidgets.buildGenericChallengeCard(
                    topText: '28 DAYS',
                    titleText: 'FULL BODY\nCHALLENGE ',
                    description: 'Start your body-toning journey to target all muscle groups and build your dream body in 4 weeks!',
                    baseColor: const Color(0xFF0062FF),
                    imagePath: 'assets/images/body/fullbody.png',
                    width: double.infinity,
                  ),
                  const SizedBox(height: 20),
                ],
                if (selectedCategory == 'All' || selectedCategory == 'Lose Weight' || selectedCategory == 'Full Body') ...[
                  ChallengeCardWidgets.buildGenericChallengeCard(
                    topText: '30 DAYS',
                    titleText: 'LOSE WEIGHT\nFOR MEN ',
                    description: 'Lose man boobs and love handles in just 5-10 min a day!',
                    baseColor: const Color(0xFFFF7043),
                    imagePath: 'assets/images/ui/plan_coach.jpg',
                    width: double.infinity,
                  ),
                  const SizedBox(height: 20),
                ],
                if (selectedCategory == 'All' || selectedCategory == 'Abs' || selectedCategory == 'Lose Weight') ...[
                  ChallengeCardWidgets.buildGenericChallengeCard(
                    topText: '30 DAYS',
                    titleText: 'SIX PACK\nCHALLENGE ',
                    description: 'Crush this challenge and carve out your six-pack in no time!',
                    baseColor: const Color(0xFF311B92),
                    imagePath: 'assets/images/workouts/abs.jpg',
                    width: double.infinity,
                  ),
                  const SizedBox(height: 20),
                ],
                if (selectedCategory == 'All' || selectedCategory == 'Kegel') ...[
                  ChallengeCardWidgets.buildGenericChallengeCard(
                    topText: '14 DAYS',
                    titleText: 'KEGEL POWER\nBOOST ',
                    description: 'Strengthen your pelvic floor with Kegel exercises for better sex and intimacy!',
                    baseColor: const Color(0xFF607D8B),
                    imagePath: 'assets/images/workouts/stretch_warmup.jpg',
                    width: double.infinity,
                  ),
                  const SizedBox(height: 20),
                ],
                if (selectedCategory == 'All' || selectedCategory == 'Abs' || selectedCategory == 'Lose Weight') ...[
                  ChallengeCardWidgets.buildGenericChallengeCard(
                    topText: '14 DAYS',
                    titleText: 'INTENSE\nBELLY FAT\nBURN ',
                    description: 'Feel the burn, lose the fat—killer abs exercises that work your core fast!',
                    baseColor: const Color(0xFF796B6B),
                    imagePath: 'assets/images/workouts/belly_fat_burn.jpg',
                    width: double.infinity,
                  ),
                  const SizedBox(height: 20),
                ],
                if (selectedCategory == 'All' || selectedCategory == 'Height Increase') ...[
                  ChallengeCardWidgets.buildGenericChallengeCard(
                    topText: '28 DAYS',
                    titleText: 'HEIGHT\nINCREASE\nCHALLENGE ',
                    description: 'Stretch, strengthen, and reveal a taller, more confident you!',
                    baseColor: const Color(0xFF329D8F),
                    imagePath: 'assets/images/workouts/height_increase.jpg',
                    width: double.infinity,
                  ),
                  const SizedBox(height: 20),
                ],
                if (selectedCategory == 'All' || selectedCategory == 'Lower Body' || selectedCategory == 'Build Muscle') ...[
                  ChallengeCardWidgets.buildGenericChallengeCard(
                    topText: '28 DAYS',
                    titleText: 'LOWER BODY\nCHALLENGE ',
                    description: 'In just 4 weeks, power up your legs, boost lower body strength, and enhance your overall strength!',
                    baseColor: const Color(0xFF0077EE),
                    imagePath: 'assets/images/workouts/lower_body.jpg',
                    width: double.infinity,
                  ),
                  const SizedBox(height: 20),
                ],
                if (selectedCategory == 'All' || selectedCategory == 'Upper Body' || selectedCategory == 'Build Muscle' || selectedCategory == 'Full Body') ...[
                  ChallengeCardWidgets.buildGenericChallengeCard(
                    topText: '28 DAYS',
                    titleText: 'MASSIVE\nBODY\nCHALLENGE ',
                    description: 'Sculpt your upper body and shred your abs in 4 weeks—no equipment needed!',
                    baseColor: const Color(0xFF3A506B),
                    imagePath: 'assets/images/workouts/massive_body.jpg',
                    width: double.infinity,
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
