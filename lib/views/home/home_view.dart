import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/home_viewmodel.dart';

/// Placeholder home screen. It shows the data collected during onboarding
/// so you can verify everything was saved correctly.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final profile = vm.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your profile'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            tooltip: 'Restart onboarding',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () async {
              await vm.resetOnboarding();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacementNamed(AppRoutes.splash);
            },
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
              ? const Center(child: Text('No profile saved yet.'))
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _row('Gender', profile.gender?.label ?? '-'),
                    _row(
                      'Focus areas',
                      profile.focusAreas.isEmpty
                          ? '-'
                          : profile.focusAreas.map((e) => e.label).join(', '),
                    ),
                    _row('Goal', profile.goal?.label ?? '-'),
                    _row('Motivation', profile.motivation?.label ?? '-'),
                    _row('Fitness level', profile.level?.label ?? '-'),
                    _row('Age', '${profile.age} years'),
                    _row('Height', '${profile.heightCm} cm'),
                    _row('Weight', '${profile.weightKg} kg'),
                    _row('BMI', profile.bmi.toStringAsFixed(1)),
                    _row('Workout days', '${profile.workoutDaysPerWeek} / week'),
                  ],
                ),
    );
  }

  Widget _row(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
