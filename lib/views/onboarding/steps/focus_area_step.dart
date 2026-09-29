import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_profile.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';
import '../widgets/enum_visuals.dart';
import '../widgets/selectable_tile.dart';
import '../widgets/step_scaffold.dart';

class FocusAreaStep extends StatelessWidget {
  const FocusAreaStep({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return StepScaffold(
      title: 'Choose your focus areas',
      subtitle: 'Pick one or more body parts you want to train the most.',
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
        padding: const EdgeInsets.only(bottom: 12),
        children: [
          for (final area in FocusArea.values)
            SelectableTile(
              label: area.label,
              icon: area.icon,
              selected: vm.profile.focusAreas.contains(area),
              onTap: () => vm.toggleFocusArea(area),
            ),
        ],
      ),
    );
  }
}
