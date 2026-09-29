import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../viewmodels/onboarding_viewmodel.dart';
import 'steps/body_metrics_step.dart';
import 'steps/fitness_level_step.dart';
import 'steps/focus_area_step.dart';
import 'steps/gender_step.dart';
import 'steps/goal_step.dart';
import 'steps/motivation_step.dart';
import 'steps/schedule_step.dart';
import 'widgets/onboarding_header.dart';
import 'widgets/primary_button.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  Widget _stepFor(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.gender:
        return const GenderStep();
      case OnboardingStep.focusArea:
        return const FocusAreaStep();
      case OnboardingStep.goal:
        return const GoalStep();
      case OnboardingStep.motivation:
        return const MotivationStep();
      case OnboardingStep.fitnessLevel:
        return const FitnessLevelStep();
      case OnboardingStep.bodyMetrics:
        return const BodyMetricsStep();
      case OnboardingStep.schedule:
        return const ScheduleStep();
    }
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  Future<void> _onContinue(BuildContext context, OnboardingViewModel vm) async {
    if (!vm.isLast) {
      vm.next();
      return;
    }
    final saved = await vm.complete();
    if (!context.mounted) return;
    if (saved) {
      _goHome(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save your data. Try again.')),
      );
    }
  }

  Future<void> _onSkip(BuildContext context, OnboardingViewModel vm) async {
    final finished = await vm.skip();
    if (!context.mounted) return;
    if (finished) _goHome(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return PopScope(
      canPop: vm.isFirst,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) vm.back();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              OnboardingHeader(
                progress: vm.progress,
                stepLabel: 'Step ${vm.stepNumber} of ${vm.totalSteps}',
                showBack: !vm.isFirst,
                onBack: vm.back,
                onSkip: () => _onSkip(context, vm),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(vm.currentStep),
                    child: _stepFor(vm.currentStep),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: PrimaryButton(
                  label: vm.isLast ? 'Finish' : 'Continue',
                  isLoading: vm.isSaving,
                  onPressed:
                      vm.canProceed ? () => _onContinue(context, vm) : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
