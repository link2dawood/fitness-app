import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_profile.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';
import '../widgets/enum_visuals.dart';
import '../widgets/selectable_card.dart';
import '../widgets/step_scaffold.dart';

class MotivationStep extends StatelessWidget {
  const MotivationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return StepScaffold(
      title: 'What motivates you most?',
      subtitle: 'Knowing your why helps us keep you on track.',
      child: ListView.separated(
        itemCount: Motivation.values.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final item = Motivation.values[i];
          return SelectableCard(
            title: item.label,
            subtitle: item.description,
            icon: item.icon,
            selected: vm.profile.motivation == item,
            onTap: () => vm.selectMotivation(item),
          );
        },
      ),
    );
  }
}
