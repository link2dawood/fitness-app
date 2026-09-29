import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_profile.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';
import '../widgets/enum_visuals.dart';
import '../widgets/selectable_tile.dart';
import '../widgets/step_scaffold.dart';

class GenderStep extends StatelessWidget {
  const GenderStep({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return StepScaffold(
      title: "What's your gender?",
      subtitle: 'This helps us tailor workouts and calorie estimates to you.',
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: 190,
          child: Row(
            children: [
              for (final gender in Gender.values) ...[
                Expanded(
                  child: SelectableTile(
                    label: gender.label,
                    icon: gender.icon,
                    iconSize: 30,
                    selected: vm.profile.gender == gender,
                    onTap: () => vm.selectGender(gender),
                  ),
                ),
                if (gender != Gender.values.last) const SizedBox(width: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
