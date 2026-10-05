import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_profile.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';
import '../widgets/step_scaffold.dart';

class GoalStep extends StatelessWidget {
  const GoalStep({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return StepScaffold(
      title: 'What are your main goals?',
      subtitle: 'Pick what you want to achieve with your workouts.',
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: FitnessGoal.values.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (_, i) {
          final goal = FitnessGoal.values[i];
          return _GoalCard(
            goal: goal,
            selected: vm.profile.goal == goal,
            gender: vm.profile.gender,
            onTap: () => vm.selectGoal(goal),
          );
        },
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.selected,
    required this.onTap,
    this.gender,
  });

  final FitnessGoal goal;
  final bool selected;
  final VoidCallback onTap;
  final Gender? gender;

  String _getPrimaryAsset(FitnessGoal goal, Gender? gender) {
    if (gender == Gender.female) {
       switch (goal) {
        case FitnessGoal.loseWeight:
          return 'assets/images/ui/goal_female_lose_weight.jpg';
        case FitnessGoal.buildMuscle:
          return 'assets/images/ui/goal_female_build_muscle.jpg';
        case FitnessGoal.keepFit:
          return 'assets/images/ui/goal_female_keep_fit.jpg';
        case FitnessGoal.endurance:
          return 'assets/images/ui/goal_female_endurance.jpg';
      }
    }

    switch (goal) {
      case FitnessGoal.loseWeight:
        return 'assets/images/goal_lose_weight.png';
      case FitnessGoal.buildMuscle:
        return 'assets/images/goal_build_muscle.png';
      case FitnessGoal.keepFit:
        return 'assets/images/goal_keep_fit.png';
      case FitnessGoal.endurance:
        return 'assets/images/goal_endurance.png';
    }
  }

  String _getFallbackAsset(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.loseWeight:
        return 'assets/images/ui/pro_before_after.jpg';
      case FitnessGoal.buildMuscle:
        return 'assets/images/workouts/abs.jpg';
      case FitnessGoal.keepFit:
        return 'assets/images/ui/plan_athlete.jpg';
      case FitnessGoal.endurance:
        return 'assets/images/workouts/stretch_warmup.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.primary; // Fitness green – consistent with all other steps

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 115,
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.10)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? activeColor : AppColors.border,
            width: selected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: activeColor.withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 6),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Left side: Goal Label
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                right: 145,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    goal.label,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: selected ? activeColor : AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                ),
              ),

              // Right side: Goal Image
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 145,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                  ),
                  child: Image.asset(
                    _getPrimaryAsset(goal, gender),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        _getFallbackAsset(goal),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      );
                    },
                  ),
                ),
              ),

              // Selected checkmark badge
              if (selected)
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
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
