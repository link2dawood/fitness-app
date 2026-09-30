import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../data/models/user_profile.dart';

class PlanReadyView extends StatelessWidget {
  const PlanReadyView({super.key, this.profile});

  final UserProfile? profile;

  String _getPlanTitle() {
    final goal = profile?.goal;
    switch (goal) {
      case FitnessGoal.loseWeight:
        return 'FULL BODY\nSHRED';
      case FitnessGoal.buildMuscle:
        return 'MUSCLE BUILD\nBLAST';
      case FitnessGoal.keepFit:
        return 'FULL BODY\nFITNESS';
      case FitnessGoal.endurance:
        return 'ENDURANCE\nBOOST';
      default:
        return 'FULL BODY\nSHRED';
    }
  }

  String _getTargetArea() {
    if (profile != null && profile!.focusAreas.isNotEmpty) {
      return profile!.focusAreas.first.label;
    }
    return 'Full Body';
  }

  String _getFitnessLevel() {
    return profile?.level?.label ?? 'Advanced';
  }

  @override
  Widget build(BuildContext context) {
    final planTitle = _getPlanTitle();
    final targetArea = _getTargetArea();
    final fitnessLevel = _getFitnessLevel();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // ── Top Coach Avatar ───────────────────────────────────────────
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/plan_coach.jpg',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Header Title & Subtitle ────────────────────────────────────
              const Text(
                'Your plan is ready!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We have selected this plan that suits you best',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 28),

              // ── Customized Plan Card ───────────────────────────────────────
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFF004CE8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0052CC).withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Badge + Title and Athlete Avatar
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFDFB5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'CUSTOMIZED FOR YOU',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  planTitle,
                                  style: const TextStyle(
                                    fontSize: 27,
                                    fontWeight: FontWeight.w900,
                                    height: 1.15,
                                    letterSpacing: 0.3,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Athlete avatar on right
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              'assets/images/plan_athlete.jpg',
                              width: 135,
                              height: 145,
                              fit: BoxFit.cover,
                              alignment: const Alignment(0, -0.3),
                            ),
                          ),
                        ],
                      ),

                      // Bottom 2x2 Grid of Metrics
                      Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: _CardMetric(
                                  icon: Icons.calendar_month_rounded,
                                  value: '10-22 Min',
                                  label: 'Daily Time',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _CardMetric(
                                  icon: Icons.bar_chart_rounded,
                                  value: fitnessLevel,
                                  label: 'Level',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _CardMetric(
                                  icon: Icons.track_changes_rounded,
                                  value: targetArea,
                                  label: 'Target area',
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: _CardMetric(
                                  icon: Icons.check_circle_outline_rounded,
                                  value: 'No Equipment',
                                  label: 'Equipment',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Action Buttons ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0062FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  child: const Text('START NOW'),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                },
                child: const Text(
                  'Go to homepage',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardMetric extends StatelessWidget {
  const _CardMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
