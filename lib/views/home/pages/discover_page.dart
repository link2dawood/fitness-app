import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/routes/app_routes.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        title: const Text(
          'DISCOVER',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            GestureDetector(
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
                      hintText: 'Search exercises, coaches, articles...',
                      hintStyle: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Offer Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'LIMITED OFFER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Only 4 Moves for Abs',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Target all core zones in 7 mins',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/workouts/abs.jpg',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'Body Focus Badges',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final focus in [
                  'Full Body',
                  'ABS',
                  'Arm',
                  'Butt & Leg',
                  'Chest',
                  'Back',
                  'Shoulder',
                ])
                  ActionChip(
                    label: Text(focus),
                    backgroundColor: const Color(0xFFF3F4F6),
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                    onPressed: () {},
                  ),
              ],
            ),
            const SizedBox(height: 28),

            const Text(
              'Workout Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in [
                  'Build Muscle',
                  'Warm-Up',
                  'HIIT',
                  'Low Impact',
                  'Fat Burning',
                  'With Equipment',
                  'Stretch',
                ])
                  ActionChip(
                    label: Text(type),
                    backgroundColor: const Color(0xFFF3F4F6),
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                    onPressed: () {},
                  ),
              ],
            ),
            const SizedBox(height: 28),

            const Text(
              'Duration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                for (final dur in ['10 mins', '11-20 mins', '21-30 mins']) ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Text(
                        dur,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
