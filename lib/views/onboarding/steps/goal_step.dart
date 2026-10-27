import '../../../widgets/app_action.dart';
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
  Widget build(BuildContext context) => AppAction(
    selected: selected,
    onTap: () {
      HapticFeedback.selectionClick();
      onTap();
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      constraints: const BoxConstraints(minHeight: 115),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: .10)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selected)
                    const Icon(Icons.check_circle, color: AppColors.primary),
                  Text(
                    goal.label,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              _getPrimaryAsset(goal, gender),
              width: 95,
              height: 115,
              fit: BoxFit.cover,
              errorBuilder: (_, error, stack) => Image.asset(
                _getFallbackAsset(goal),
                width: 95,
                height: 115,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
