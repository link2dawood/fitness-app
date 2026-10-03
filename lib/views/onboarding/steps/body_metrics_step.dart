import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';
import '../widgets/step_scaffold.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Conversion helpers
// ─────────────────────────────────────────────────────────────────────────────

({int feet, int inches}) _cmToFtIn(int cm) {
  final totalIn = (cm / 2.54).round();
  return (feet: totalIn ~/ 12, inches: totalIn % 12);
}

int _ftInToCm(int feet, int inches) => ((feet * 12 + inches) * 2.54).round();
int _kgToLb(int kg) => (kg * 2.20462).round();
int _lbToKg(int lb) => (lb / 2.20462).round();

// ─────────────────────────────────────────────────────────────────────────────
// Step
// ─────────────────────────────────────────────────────────────────────────────

class BodyMetricsStep extends StatefulWidget {
  const BodyMetricsStep({super.key});

  @override
  State<BodyMetricsStep> createState() => _BodyMetricsStepState();
}

class _BodyMetricsStepState extends State<BodyMetricsStep> {
  bool _heightImperial = false;
  bool _weightImperial = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    final p = vm.profile;
    final ftIn = _cmToFtIn(p.heightCm);
    final lb = _kgToLb(p.weightKg);

    return StepScaffold(
      title: 'Tell us about your body',
      subtitle: 'Tap + / − to adjust your stats.',
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Age ──────────────────────────────────────────────────────────
            _MetricCard(
              icon: Icons.cake_rounded,
              iconColor: const Color(0xFF9C27B0),
              label: 'Age',
              displayValue: '${p.age}',
              displayUnit: 'years',
              child: _StepCounter(
                value: p.age,
                min: 13,
                max: 90,
                onChanged: vm.updateAge,
              ),
            ),

            const SizedBox(height: 14),

            // ── Height ───────────────────────────────────────────────────────
            _MetricCard(
              icon: Icons.height_rounded,
              iconColor: const Color(0xFF2196F3),
              label: 'Height',
              displayValue: _heightImperial
                  ? "${ftIn.feet}' ${ftIn.inches}\""
                  : '${p.heightCm}',
              displayUnit: _heightImperial ? '' : 'cm',
              unitToggle: _UnitToggle(
                leftLabel: 'cm',
                rightLabel: 'ft / in',
                isRight: _heightImperial,
                onChanged: (v) => setState(() => _heightImperial = v),
              ),
              child: _heightImperial
                  ? _FtInCounter(
                      feet: ftIn.feet,
                      inches: ftIn.inches,
                      onChanged: (f, i) => vm.updateHeight(_ftInToCm(f, i)),
                    )
                  : _StepCounter(
                      value: p.heightCm,
                      min: 120,
                      max: 220,
                      onChanged: vm.updateHeight,
                    ),
            ),

            const SizedBox(height: 14),

            // ── Weight ───────────────────────────────────────────────────────
            _MetricCard(
              icon: Icons.monitor_weight_rounded,
              iconColor: const Color(0xFFFF5722),
              label: 'Weight',
              displayValue: _weightImperial ? '$lb' : '${p.weightKg}',
              displayUnit: _weightImperial ? 'lb' : 'kg',
              unitToggle: _UnitToggle(
                leftLabel: 'kg',
                rightLabel: 'lb',
                isRight: _weightImperial,
                onChanged: (v) => setState(() => _weightImperial = v),
              ),
              child: _weightImperial
                  ? _StepCounter(
                      value: lb,
                      min: 66,
                      max: 441,
                      onChanged: (v) => vm.updateWeight(_lbToKg(v)),
                    )
                  : _StepCounter(
                      value: p.weightKg,
                      min: 30,
                      max: 200,
                      onChanged: vm.updateWeight,
                    ),
            ),

            const SizedBox(height: 18),

            // ── BMI ──────────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.analytics_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Your BMI',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    p.bmi.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metric Card
// ─────────────────────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.displayValue,
    required this.displayUnit,
    required this.child,
    this.unitToggle,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String displayValue;
  final String displayUnit;
  final Widget child;
  final Widget? unitToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card header: icon + label + optional unit toggle ────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              ?unitToggle,
            ],
          ),

          const SizedBox(height: 14),

          // ── Large value display ─────────────────────────────────────────
          Center(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: displayValue,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1,
                    ),
                  ),
                  if (displayUnit.isNotEmpty)
                    TextSpan(
                      text: ' $displayUnit',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        height: 1,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Counter / picker ────────────────────────────────────────────
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step Counter  (– value +)
// ─────────────────────────────────────────────────────────────────────────────

class _StepCounter extends StatelessWidget {
  const _StepCounter({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  void _tap(int delta) {
    HapticFeedback.selectionClick();
    final next = (value + delta).clamp(min, max);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Minus
        _CounterBtn(
          icon: Icons.remove_rounded,
          enabled: value > min,
          onTap: () => _tap(-1),
        ),

        // Progress bar
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (value - min) / (max - min),
                minHeight: 8,
                backgroundColor: AppColors.surfaceLight,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
        ),

        // Plus
        _CounterBtn(
          icon: Icons.add_rounded,
          enabled: value < max,
          onTap: () => _tap(1),
        ),
      ],
    );
  }
}

class _CounterBtn extends StatelessWidget {
  const _CounterBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feet + Inches dual counter
// ─────────────────────────────────────────────────────────────────────────────

class _FtInCounter extends StatelessWidget {
  const _FtInCounter({
    required this.feet,
    required this.inches,
    required this.onChanged,
  });

  final int feet;
  final int inches;
  final void Function(int feet, int inches) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Feet
        Expanded(
          child: Column(
            children: [
              Text(
                'ft',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              _StepCounter(
                value: feet,
                min: 4,
                max: 7,
                onChanged: (f) => onChanged(f, inches),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Inches
        Expanded(
          child: Column(
            children: [
              const Text(
                'in',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              _StepCounter(
                value: inches,
                min: 0,
                max: 11,
                onChanged: (i) => onChanged(feet, i),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Unit Toggle pill
// ─────────────────────────────────────────────────────────────────────────────

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({
    required this.leftLabel,
    required this.rightLabel,
    required this.isRight,
    required this.onChanged,
  });

  final String leftLabel;
  final String rightLabel;
  final bool isRight;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!isRight);
      },
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToggleTab(label: leftLabel, active: !isRight),
            _ToggleTab(label: rightLabel, active: isRight),
          ],
        ),
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: active ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}
