import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';
import '../widgets/step_scaffold.dart';
import '../widgets/wheel_picker.dart';

class BodyMetricsStep extends StatelessWidget {
  const BodyMetricsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    final profile = vm.profile;

    return StepScaffold(
      title: 'Tell us about your body',
      subtitle: 'Scroll each wheel to set your age, height and weight.',
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: WheelPicker(
                  label: 'Age',
                  unit: 'years',
                  min: 13,
                  max: 90,
                  value: profile.age,
                  onChanged: vm.updateAge,
                ),
              ),
              Expanded(
                child: WheelPicker(
                  label: 'Height',
                  unit: 'cm',
                  min: 120,
                  max: 220,
                  value: profile.heightCm,
                  onChanged: vm.updateHeight,
                ),
              ),
              Expanded(
                child: WheelPicker(
                  label: 'Weight',
                  unit: 'kg',
                  min: 30,
                  max: 200,
                  value: profile.weightKg,
                  onChanged: vm.updateWeight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your BMI',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  profile.bmi.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
