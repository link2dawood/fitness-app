import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_profile.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';
import '../widgets/enum_visuals.dart';
import '../widgets/selectable_card.dart';
import '../widgets/step_scaffold.dart';

class FitnessLevelStep extends StatelessWidget {
  const FitnessLevelStep({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return StepScaffold(
      title: 'What is your fitness level?',
      subtitle: 'Be honest. A quick push-up test is a good guide.',
      child: ListView.separated(
        itemCount: FitnessLevel.values.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final level = FitnessLevel.values[i];
          return SelectableCard(
            title: level.label,
            subtitle: level.description,
            icon: level.icon,
            iconColor: level.iconColor,
            selected: vm.profile.level == level,
            onTap: () => vm.selectLevel(level),
          );
        },
      ),
    );
  }
}
