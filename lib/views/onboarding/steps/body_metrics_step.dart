import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';
import '../widgets/step_scaffold.dart';
import '../widgets/ruler_picker.dart';

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
      title: 'Let us know you better',
      subtitle: 'Let us know you better to help boost your\nworkout results',
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // ── Weight ───────────────────────────────────────────────────────
            _HeaderRow(
              title: 'Weight',
              toggle: _UnitToggle(
                leftLabel: 'kg',
                rightLabel: 'lbs',
                isRight: _weightImperial,
                onChanged: (v) => setState(() => _weightImperial = v),
              ),
            ),
            const SizedBox(height: 20),
            _ValueDisplay(
              value: _weightImperial ? '$lb.0' : '${p.weightKg}.0',
              unit: _weightImperial ? 'lbs' : 'kg',
            ),
            const SizedBox(height: 20),
            _weightImperial
                ? RulerPicker(
                    value: lb,
                    min: 66,
                    max: 441,
                    stepWidth: 80.0,
                    labelInterval: 1,
                    visualTicksPerStep: 10,
                    onChanged: (v) => vm.updateWeight(_lbToKg(v)),
                  )
                : RulerPicker(
                    value: p.weightKg,
                    min: 30,
                    max: 200,
                    stepWidth: 80.0,
                    labelInterval: 1,
                    visualTicksPerStep: 10,
                    onChanged: vm.updateWeight,
                  ),

            const SizedBox(height: 50),

            // ── Height ───────────────────────────────────────────────────────
            _HeaderRow(
              title: 'Height',
              toggle: _UnitToggle(
                leftLabel: 'cm',
                rightLabel: 'ft',
                isRight: _heightImperial,
                onChanged: (v) => setState(() => _heightImperial = v),
              ),
            ),
            const SizedBox(height: 20),
            _ValueDisplay(
              value: _heightImperial ? "${ftIn.feet}' ${ftIn.inches}\"" : '${p.heightCm}',
              unit: _heightImperial ? '' : 'cm',
            ),
            const SizedBox(height: 20),
            _heightImperial
                ? _FtInRuler(
                    feet: ftIn.feet,
                    inches: ftIn.inches,
                    onChanged: (f, i) => vm.updateHeight(_ftInToCm(f, i)),
                  )
                : RulerPicker(
                    value: p.heightCm,
                    min: 120,
                    max: 220,
                    stepWidth: 12.0,
                    labelInterval: 10,
                    visualTicksPerStep: 1,
                    onChanged: vm.updateHeight,
                  ),
            
            const SizedBox(height: 50),

            // ── Age ──────────────────────────────────────────────────────────
            _HeaderRow(
              title: 'Age',
              toggle: const SizedBox(),
            ),
            const SizedBox(height: 20),
            _ValueDisplay(
              value: '${p.age}',
              unit: 'years',
            ),
            const SizedBox(height: 20),
            RulerPicker(
              value: p.age,
              min: 13,
              max: 90,
              stepWidth: 80.0,
              labelInterval: 1,
              visualTicksPerStep: 10,
              onChanged: vm.updateAge,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.title, required this.toggle});
  final String title;
  final Widget toggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          toggle,
        ],
      ),
    );
  }
}

class _ValueDisplay extends StatelessWidget {
  const _ValueDisplay({required this.value, required this.unit});
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                height: 1,
              ),
            ),
            if (unit.isNotEmpty)
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feet + Inches dual counter
// ─────────────────────────────────────────────────────────────────────────────

class _FtInRuler extends StatelessWidget {
  const _FtInRuler({
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
              const Text(
                'ft',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              RulerPicker(
                value: feet,
                min: 4,
                max: 7,
                stepWidth: 60.0,
                labelInterval: 1,
                visualTicksPerStep: 1,
                onChanged: (f) => onChanged(f, inches),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Inches
        Expanded(
          child: Column(
            children: [
              const Text(
                'in',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              RulerPicker(
                value: inches,
                min: 0,
                max: 11,
                stepWidth: 40.0,
                labelInterval: 1,
                visualTicksPerStep: 1,
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
        height: 34,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(17),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: active ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}
