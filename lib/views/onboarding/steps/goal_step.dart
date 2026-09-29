import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_profile.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';
import '../widgets/enum_visuals.dart';
import '../widgets/selectable_card.dart';
import '../widgets/step_scaffold.dart';

class GoalStep extends StatelessWidget {
  const GoalStep({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return StepScaffold(
      title: "What's your main goal?",
      subtitle: 'We will build your plan around it.',
      child: ListView.separated(
        itemCount: FitnessGoal.values.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final goal = FitnessGoal.values[i];
          return SelectableCard(
            title: goal.label,
            subtitle: goal.description,
            icon: goal.icon,
            selected: vm.profile.goal == goal,
            onTap: () => vm.selectGoal(goal),
          );
        },
      ),
    );
  }
}
