import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';
import '../widgets/step_scaffold.dart';

class WeeklyGoalStep extends StatelessWidget {
  const WeeklyGoalStep({super.key});

  static const List<String> _daysOfWeek = [
    'SUNDAY',
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
  ];

  void _showDayPicker(
      BuildContext context, OnboardingViewModel vm, String currentDay) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'First day of week',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF0F2F5)),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _daysOfWeek.length,
                    itemBuilder: (_, index) {
                      final day = _daysOfWeek[index];
                      final isSelected = day == currentDay;

                      return ListTile(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          vm.selectFirstDayOfWeek(day);
                          Navigator.of(ctx).pop();
                        },
                        title: Text(
                          day,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary, size: 22)
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    final selectedDays = vm.profile.workoutDaysPerWeek;
    final firstDay = vm.profile.firstDayOfWeek;

    return StepScaffold(
      title: 'Set your weekly goal',
      subtitle:
          'We recommend training at least 3 days\nweekly for a better result.',
      centerTitle: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        child: Column(
          children: [
            // ── Section 1: Weekly training days ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.track_changes_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Weekly training days',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            LayoutBuilder(
              builder: (context, constraints) {
                const double spacing = 12;
                final double itemWidth =
                    (constraints.maxWidth - (3 * spacing)) / 4;
                const double itemHeight = 58;

                return Column(
                  children: [
                    // Row 1: [1] [2] [3] [4]
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final day in [1, 2, 3, 4])
                          _DayButton(
                            day: day,
                            width: itemWidth,
                            height: itemHeight,
                            selected: selectedDays == day,
                            onTap: () => vm.selectWorkoutDays(day),
                          ),
                      ],
                    ),
                    const SizedBox(height: spacing),

                    // Row 2: [5] [6] [7] (centered)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < 3; i++) ...[
                          _DayButton(
                            day: 5 + i,
                            width: itemWidth,
                            height: itemHeight,
                            selected: selectedDays == (5 + i),
                            onTap: () => vm.selectWorkoutDays(5 + i),
                          ),
                          if (i < 2) const SizedBox(width: spacing),
                        ],
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // ── Divider ──────────────────────────────────────────────────────
            Container(
              height: 1,
              color: const Color(0xFFF0F2F5),
            ),

            const SizedBox(height: 28),

            // ── Section 2: First day of week ─────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: Color(0xFF0066FF),
                ),
                SizedBox(width: 8),
                Text(
                  'First day of week',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            GestureDetector(
              onTap: () => _showDayPicker(context, vm, firstDay),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 28),
                    Expanded(
                      child: Text(
                        firstDay,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 32,
                      color: Color(0xFF111827),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton({
    required this.day,
    required this.width,
    required this.height,
    required this.selected,
    required this.onTap,
  });

  final int day;
  final double width;
  final double height;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
            width: selected ? 1.8 : 1.2,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : const Color(0xFF111827),
          ),
        ),
      ),
    );
  }
}
