import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_profile.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';

class GenderStep extends StatelessWidget {
  const GenderStep({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    final selected = vm.profile.gender;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // ── Title & Subtitle ──────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "What's your gender?",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111),
                    height: 1.2,
                  ),
                ),
                 SizedBox(height: 6),
                Text(
                  'Let us know you better',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Single shared frame with both avatars side by side ────────
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Male
                  _AvatarOption(
                    label: 'Male',
                    imagePath: 'assets/images/male-Avatar.png',
                    selected: selected == Gender.male,
                    onTap: () => vm.selectGender(Gender.male),
                  ),
                  const SizedBox(width: 12),
                  // Female
                  _AvatarOption(
                    label: 'Female',
                    imagePath: 'assets/images/female-Avatar.png',
                    selected: selected == Gender.female,
                    onTap: () => vm.selectGender(Gender.female),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      );
  }
}

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.label,
    required this.imagePath,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String imagePath;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.primary;
    const darkAccent = AppColors.primary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // ── Figure + blob selection ring ──────────────────────────
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated selection blob behind the figure
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      margin: EdgeInsets.only(
                        top: selected ? 12 : 28,
                        bottom: selected ? 12 : 28,
                        left: selected ? 8 : 20,
                        right: selected ? 8 : 20,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? accent.withValues(alpha: 0.14)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(32),
                        border: selected
                            ? Border.all(
                                color: accent.withValues(alpha: 0.35),
                                width: 1.5,
                              )
                            : null,
                      ),
                    ),
                  ),

                  // Avatar image — no padding so it fills the full height
                  Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      errorBuilder: (_, _, _) => const SizedBox.expand(),
                  ),

                  // Checkmark badge when selected
                  if (selected)
                    Positioned(
                      top: 10,
                      right: 16,
                      child: AnimatedScale(
                        scale: selected ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: darkAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Label ─────────────────────────────────────────────────
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: selected ? darkAccent : const Color(0xFF1A1A1A),
              ),
              child: Text(label),
            ),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
