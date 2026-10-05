import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_profile.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';
import '../widgets/step_scaffold.dart';

class GenderStep extends StatelessWidget {
  const GenderStep({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    final selected = vm.profile.gender;

    return StepScaffold(
      title: "What's your gender?",
      subtitle: 'Let us know you better to customize your plan.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Bounded height ensures the cards stay balanced and proportional
          // on tall Android screens instead of stretching excessively.
          final cardHeight =
              (constraints.maxHeight * 0.72).clamp(270.0, 330.0);

          return Center(
            child: SizedBox(
              height: cardHeight,
              child: Row(
                children: [
                  // Male
                  Expanded(
                    child: _AvatarCard(
                      label: 'Male',
                      gender: Gender.male,
                      imagePath: 'assets/images/avatars/male/avatar.png',
                      selected: selected == Gender.male,
                      onTap: () => vm.selectGender(Gender.male),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Female
                  Expanded(
                    child: _AvatarCard(
                      label: 'Female',
                      gender: Gender.female,
                      imagePath: 'assets/images/avatars/female/avatar.png',
                      selected: selected == Gender.female,
                      onTap: () => vm.selectGender(Gender.female),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({
    required this.label,
    required this.gender,
    required this.imagePath,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Gender gender;
  final String imagePath;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.primary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.10)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? activeColor : AppColors.border,
            width: selected ? 2.0 : 1.2,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: activeColor.withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Top-left: Gender Icon Badge
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selected
                        ? activeColor.withValues(alpha: 0.16)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    gender == Gender.male
                        ? Icons.male_rounded
                        : Icons.female_rounded,
                    size: 18,
                    color: selected ? activeColor : AppColors.textSecondary,
                  ),
                ),
              ),

              // Top-right: Selection Checkmark Badge
              Positioned(
                top: 14,
                right: 14,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selected ? activeColor : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? activeColor : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ),

              // Avatar Figure + Label
              Column(
                children: [
                  const SizedBox(height: 34),
                  // Avatar Figure
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Label
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                      color: selected ? activeColor : AppColors.textPrimary,
                    ),
                    child: Text(label),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
